---
title: Gin 鉴权中间件
date: 2024-07-10T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
tags: [golang, gin, jwt, middleware]
---

记录一下记账项目后端使用 jwt 方案来鉴权的开发流程

> [github.com/golang-jwt/jwt/v5](https://pkg.go.dev/github.com/golang-jwt/jwt/v5@v5.2.1)

jwt 涉及到加密及解密的过程，将这两个逻辑抽离为两个工具函数

```golang
package jwt_helper

import (
	"log"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

// 辅助函数，从环境变量中获取加密私钥
func getHmacSecret() []byte {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		log.Fatal("JWT_SECRET is not set")
	}
	return []byte(secret)
}

// 加密，生成 jwt
func GenerateJWT(user_id uint) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": user_id,
    // 过期时间
		"exp":     time.Now().Add(time.Hour * 24 * 7).Unix(),
	})
	secret := getHmacSecret()

	return token.SignedString(secret)
}

// 解密，解析 jwt
func ParseJWT(jwtString string) (*jwt.Token, error) {
	secret := getHmacSecret()

	return jwt.Parse(jwtString, func(t *jwt.Token) (interface{}, error) {
    // 这里直接将结果返回，默认 error 为 nil
    // 报错交给中间件即可
		return secret, nil
	})
}
```

登录成功后，接口返回 jwt

```golang
func (ctrl *SessionController) Create(c *gin.Context) {
	// 获取与校验请求体数据..
  // 查询验证码是否有效..
	// 查询用户（无则创建）..
	// 生成并返回 jwt
	jwt, err := jwt_helper.GenerateJWT(uint(user.ID))
	if err != nil {
		log.Print("Generate JWT Error", err)
		c.JSON(http.StatusInternalServerError, api.Error{Error: "Failed to generate jwt"})
		return
	}

	res := api.SessionResponse{
		Jwt:    jwt,
		UserID: user.ID,
	}
	c.JSON(http.StatusOK, res)
}
```

其他接口的鉴权的过程即读取和解密 jwt 的过程

因为大部分接口都需要鉴权逻辑，可以将鉴权逻辑抽离为中间件

gin 的中间件结构如下：

```golang
func Middleware() gin.HandlerFunc {
  // 返回一个函数，接收上下文对象的指针
  return func(c *gin.Context) {
    // ...
    // 暴露到上下文中，作为全局变量
    c.Set("me", user)
    // 中间件是按照注册的顺序执行的
    // 移交控制权（下一个中间件或处理函数）
    c.Next()
  }
}
```

鉴权逻辑并非单纯返回 true 或 false，我们可以顺便将用户数据直接读取出来，放到 gin 上下文中。这样一来既可以起到鉴权的功能，也减少了 controller 中冗余的用户数据查询逻辑

首先将解析 jwt 及鉴权过程抽离为辅助函数 getMe，接收上下文指针，返回用户指针

```golang
package middleware

import (
// ...
)

func getMe(c *gin.Context) (*database.User, error) {
	var user database.User

  // 获取权限请求头，截取 jwt 字符串
	auth := c.GetHeader("Authorization")
	if len(auth) < 8 {
		return nil, fmt.Errorf("JWT is required")
	}
	jwtString := auth[7:]
  
  // 解析 jwt，得到 token
	t, err := jwt_helper.ParseJWT(jwtString)
	if err != nil {
		return nil, fmt.Errorf("invalid jwt")
	}
	
  // 解析 token 的 claims 部分，将其断言为 MapClaims 类型
	claims, ok := t.Claims.(jwt.MapClaims)
	if !ok {
		return nil, fmt.Errorf("invalid jwt")
	}

  // 从 claims 中提取用户 ID，并断言其类型为 float64
	userID, ok := claims["user_id"].(float64)
	if !ok {
		return nil, fmt.Errorf("invalid jwt")
	}

	// 超时校验
	exp, ok := claims["exp"].(float64)
	if !ok {
		return nil, fmt.Errorf("invalid jwt")
	}
	if float64(time.Now().Unix()) > exp {
		return nil, fmt.Errorf("invalid jwt")
	}

  // 数据库查询用户信息
	if tx := database.DB.Find(&user, userID); tx.Error != nil {
		return nil, fmt.Errorf("invalid jwt")
	}

  // 返回 user 地址
	return &user, nil
}
```

中间件接收一个白名单的切片（因为不是全部接口都要鉴权），返回 gin.HandlerFunc 函数

```golang
func Me(whiteList []string) gin.HandlerFunc {
	return func(c *gin.Context) {
		path := c.Request.URL.Path
		// 检测白名单
		for _, s := range whiteList {
			if has := strings.HasPrefix(path, s); has {
				c.Next()
				return
			}
		}
    // 调用 jwt 解析逻辑，获取用户
		user, err := getMe(c)
		if err != nil {
			c.AbortWithStatusJSON(401, gin.H{
				"error": err.Error(),
			})
			return
		}
		// 将 me 放到上下文中，作为「全局变量」
		c.Set("me", user)
		c.Next()
	}
}
```

中间件使用 r.Use 注册

```golang
// 创建路由
r := gin.Default()
// 应用中间件
r.Use(middleware.Me([]string{"/api/v1/session", "/api/v1/validation-codes", "/ping"}))
// 注册路由..
```

