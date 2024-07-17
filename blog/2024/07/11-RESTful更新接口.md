---
title: 更新接口讨论
date: 2024-07-11T14:15:00
authors:
  name: GSemir
  url: https://github.com/GSemir0418
  image_url: https://github.com/GSemir0418.png
  email: gsemir0418@gmail.com
tags: [restful, update, http, rails]
---

> 在更新接口联调时，前端还在纠结入参是传全部还是只传改动过的值？
> 
> 后端服务还在 get post 一把梭？

http 早就为开发者设计好更新接口的策略了：

- `patch` 是**部分更新**，没带的参数就**忽略**

- `put` 是**全量覆盖**，没带的参数就**删除或置空**

理论上增删改查应该去根据 http 动词选择更新策略，但是目前大多数的后端设计仍然是一个接口一个接口手写

再次夸赞 Rails，非常舒服的 RESTful 接口路由定义

```rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resource :session, only: [:create]
      resources :items, only: [:create, :index, :destroy]
      resource :me, only: [:show]
      # 也支持单独定义接口与方法的映射
      # post :validation_codes, to: 'validation_codes#create'
    end
  end
end
```
在 Rails 中，路由资源提供了 **HTTP 动词和 URL** 到**控制器操作**之间的映射。按照惯例，每个操作还映射到数据库中的特定 CRUD 操作。路由文件中的单个条目，例如我们在 routes 中定义了下面的路由：

```rb
resources :photos
```
Rails 会在应用程序中创建如下 7 种不同的路由，所有路由都映射到 Photos 控制器：


| HTTP Verb | Path             | Controller#Action | Used for                                     |
| --------- | ---------------- | ----------------- | -------------------------------------------- |
| GET       | /photos          | photos#index      | display a list of all photos                 |
| GET       | /photos/new      | photos#new        | return an HTML form for creating a new photo |
| POST      | /photos          | photos#create     | create a new photo                           |
| GET       | /photos/:id      | photos#show       | display a specific photo                     |
| GET       | /photos/:id/edit | photos#edit       | return an HTML form for editing a photo      |
| PATCH/PUT | /photos/:id      | photos#update     | update a specific photo                      |
| DELETE    | /photos/:id      | photos#destroy    | delete a specific photo                      |
