---
title: gorm基本使用
date: 2024-07-09T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
tags: [gorm, gin, mysql]
---

记录下记账项目后端的 orm 工具 Gorm 的基本使用

#### 1 连接数据库

在 database package 暴露数据库实例 DB。声明 ConnectDB 方法，内部使用 `gorm.Open` 连接数据库，并给 DB 赋值

```golang
package database

var DB *gorm.DB

func ConnectDB() {
	if DB != nil {
		return
	}

	// 从环境变量中获取数据库连接字符串
	dsn := os.Getenv("DB_DSN")
	if dsn == "" {
		log.Fatal("DB_DSN is not set")
	}
	
  // 连接数据库
	database, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})

	if err != nil {
		log.Fatal("Fail to connect database!", err)
	}

  // 赋值 DB
	DB = database
}
```

#### 2 model 定义

> https://gorm.io/zh_CN/docs/models.html

model 就是一个结构体，定义类型，后跟注释形式的字段配置，例如 `gorm:"<-:create" json:"createdAt"`

```go
type ValidationCode struct {
	ID        uint           `gorm:"primaryKey" json:"id"`
	Email     string         `gorm:"size:255;not null" json:"email"`
	Code      string         `gorm:"size:255;not null" json:"code"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"deletedAt"`
	UpdatedAt time.Time      `gorm:"<-:update" json:"updatedAt"`
	CreatedAt time.Time      `gorm:"<-:create" json:"createdAt"`
	UsedAt    *time.Time     `json:"usedAt"`
}
```

- 一对多

一个 user 可以创建多个 tag 和 item
使用外键约束，关联 tag 和 user 的关系即可

```go
type User struct {
	gorm.Model
	Email      string `gorm:"size:255;not null;unique"`
	Tags       []Tag
	Items      []Item
}
type Tag struct {
	gorm.Model
	UserID     uint       `gorm:"not null;index"`
	// ...
  // 只要遵守约定 模型名+ID 那么
  // GORM 能够自动识别这种外键关系，不需要显式地使用 foreignKey 标签指定。
	User       User       `gorm:"foreignKey:UserID"`
}
```

- 多对多

一个 item 可以属于多个 tag，同时一个 tag 下也可以有很多 item

使用连接表来定义多对多的关系，这种关系声明在一个表的一个字段就可以

会自动生成一个连接表

```go
type Tag struct {
	gorm.Model
	UserID     uint       `gorm:"not null;index"`
	User       User       `gorm:"foreignKey:UserID"`
}
type Item struct {
	gorm.Model
	UserID     uint      `gorm:"not null;index"`
	User       User      `gorm:"foreignKey:UserID"`
  // item_tags 多对多连接表的结构通常是由 GORM 自动生成的
  // 它会包含两个字段：item_id 和 tag_id 分别作为外键指向 items 表和 tags 表的主键
  // 通常，在处理数据库和关联关系时，推荐使用指针类型作为切片的元素类型，因为这可以更好地与ORM工作，并方便处理没有值（nil）的情形。因此推荐将 item 中的 Tags 定义为指向 Tag 的指针的切片
	Tags       []*Tag     `gorm:"many2many:item_tags;"`
}
```

若要重写外键，可以使用标签`foreignKey`、`references`、`joinforeignKey`、`joinReferences`。当然，您不需要使用全部的标签，你可以仅使用其中的一个重写部分的外键、引用，例如

```
Tags []Tag `gorm:"many2many:item_tags;foreignKey:ID;joinForeignKey:ItemID;References:ID;joinReferences:TagID"`
```

- `foreignKey:ID` 指的是Item模型的ID字段作为连接表（item_tags）的外键。

- `joinForeignKey:ItemID` 指的是在连接表中用于指向Item记录的字段名。
- `References:ID` 指的是Tag模型中的ID字段作为参照。
- `joinReferences:TagID` 指的是在连接表中用于指向Tag记录的字段名。

相当于如下 sql

```sql
CREATE TABLE `items` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    `user_id` BIGINT,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
);
CREATE TABLE `item_tags` (
    `item_id` BIGINT,
    `tag_id` BIGINT,
    PRIMARY KEY (`item_id`, `tag_id`),
    FOREIGN KEY (`item_id`) REFERENCES `items`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`tag_id`) REFERENCES `tags`(`id`) ON DELETE CASCADE
);
```

#### 3 同步数据库

使用 cobra 封装为一个指令

```go
func Migrate() {
	if DB != nil {
		// 迁移数据库
		err := DB.AutoMigrate(&User{}, &Item{}, &Tag{}, &ValidationCode{})
		if err != nil {
			log.Fatal("Fail to migrate database!", err)
		}
		// 创建测试用户
		DB.Save(&User{
			Email: "test@test.com",
		})
	}
}
```

#### 4 清空数据库

主要是关闭外键检查，方便测试

```go
func TruncateTables(t *testing.T, tables []string) {
	// 禁用外键检查
	err := DB.Exec("SET FOREIGN_KEY_CHECKS=0;").Error
	if err != nil {
		if t != nil {
			t.Fatalf("Failed to disable foreign key checks: %v", err)
		} else {
			log.Fatalf("Failed to disable foreign key checks: %v", err)
		}
	}

	// 清空所有给定的表
	for _, table := range tables {
		if err = DB.Exec("TRUNCATE TABLE " + table + ";").Error; err != nil {
			if t != nil {
				t.Fatalf("Failed to truncate table %s: %v", table, err)
			} else {
				log.Fatalf("Failed to truncate table %s: %v", table, err)
			}
		}
	}

	// 重新启用外键检查
	err = DB.Exec("SET FOREIGN_KEY_CHECKS=1;").Error
	if err != nil {
		if t != nil {
			t.Fatalf("Failed to enable foreign key checks: %v", err)
		} else {
			log.Fatalf("Failed to enable foreign key checks: %v", err)
		}
	}
}
```

