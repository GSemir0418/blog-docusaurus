---
sidebar-position: 2
title: Rails 项目总结
authors: gsemir
date: 2023-07-11
tags: [ruby, ruby on rails]
---

## 初始化

### 环境配置

#### macos

1. 安装 rails 

2. 安装数据库

```bash
$ brew update
$ brew install postgresql@14
$ brew services start postgresql@14
$ brew services stop postgresql@14
```

3. 安装必要驱动：`pacman -S postgresql-libs`

#### ubuntu(wsl)

1. 安装 rvm [rvm/ubuntu_rvm: Ubuntu package for RVM (github.com)](https://github.com/rvm/ubuntu_rvm)

2. 安装 postgresql [PostgreSQL: Linux downloads (Ubuntu)](https://www.postgresql.org/download/linux/ubuntu/)
   
3. 安装必要驱动：`sudo apt-get install libpq-dev`

### 数据库配置

#### macos

```bash
# 连接postgresql，不指定用户名和数据库默认是当前登陆系统账号同名的用户与数据库
psql
#  终端执行命令，其作用是创建一个与当前系统登陆用户同名的数据库，目的是为了可以通过这个数据库连接上 postgresql，不执行的话会报错数据库找不到
createdb
psql -U USERNAME -W PASSWORD 
# 创建 gsemir 用户
CREATE USER gsemir WITH PASSWORD '123456';
# 删除默认的 postgres 数据库
DROP DATABASE postgres;
# 创建属于 gsemir 用户的数据库
CREATE DATABASE gsemir OWNER gsemir;
# 将所有权限赋给 gsemir 用户
GRANT ALL PRIVILEGES ON DATABASE gsemir to gsemir;
# 给 postgres 用户添加 创建数据库 的属性
ALTER ROLE gsemir CREATEDB;
# 之后就可以使用 gsemir 用户来创建并管理其他数据库了
```

#### ubuntu(wsl)

- 配置同上

- 注意事项

  - 项目代码用户与数据库用户需要统一
  - 本项目代码的权限是属于 gsemir 用户，而数据库配置的用户只有 postgres
  - 不能使用 gsemir 用户操作 postgres 角色（database.yml）的数据库（运行db create等）
  - 因此 gsemir 用户也要在数据库创建**同名的角色**及**同名的数据库**，添加 createdb 权限

- 启动服务

  - 启动 `sudo service postgresql start`
  - 状态 `sudo service postgresql status`

#### docker

```bash
docker run -d \
    # 容器名称
    --name db-for-rails-todo \
    # 环境变量
    -e POSTGRES_USER=gsemir \
    -e POSTGRES_PASSWORD=123456 \
    -e POSTGRES_DB=rails-todo-dev \
    -e PGDATA=/var/lib/postgresql/data/pgdata \
    # 新增数据卷
    -v rails-todo-data:/var/lib/postgresql/data \
    # 镜像名称 版本14
    postgres:14

# 供复制：
docker run -d --name db-for-rails-todo -e POSTGRES_USER=gsemir -e POSTGRES_PASSWORD=123456 -e POSTGRES_DB=rails-todo-dev -e PGDATA=/var/lib/postgresql/data/pgdata -v rails-todo-data:/var/lib/postgresql/data postgres:14
```

#### 数据库常用命令

- `\c <database_name>` 连接数据库
- `\l` 列出全部数据库
- `\dt` 显示全部表格

#### IDE

- 安装vscode扩展 `ckolkman.vscode-postgres`

### 项目初始化

#### ruby 配置 

1. 安装 ruby：`rvm install ruby-3.0.0`

2. 配置国内源

```bash
$ gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
$ bundle config mirror.https://rubygems.org https://gems.ruby-china.com
```

3. 安装 rails：`gem install rails -v 7.0.2.3`

4. 安装项目依赖：`bundle`

5. 数据库配置

开发与测试数据库配置
```yml
# config/database.yaml
development:
  <<: *default
  database: rails_todo_dev
  username: gsemir
  password: 123456
  host: localhost
  port: 5432
```

#### 创建或运行项目

1. 同步数据库及数据表：`bin/rails db:create db:migrate`

2. 创建项目

```bash
# 仅使用api模式，指定数据库，忽略测试（后面自己配），指定项目名称
rails new --api --database=postgresql --skip-test todo-backend-rails-1
```

3. 启动 rails 项目
   

`bin/rails s -p 3001 -e development`

`bin/rails s` 也行

#### rspec 配置

1. 将 `gem 'rspec-rails', '~>5.0.0'` 复制到 `Gemfile` 中

```ruby
group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ] 
  gem 'rspec-rails', '~> 5.0.0'
end
```

2. 运行 `bundle`，安装依赖

3. 初始化rspec：`bin/rails g rspec:install`
   
4. 配置测试数据库

在 `config/database.yml` 配置测试数据库，同开发

5. 创建数据库，同步数据表：

`RAILS_ENV=test bin/rails db:create db:migrate`

1. 运行单元测试：

```bash
$ bundle exe rspec
# 或 rspec
# 执行指定的测试用例
$ rspec -e "获取当前登录用户"
# 也可以指定行数
$ rspec spec/requests/api/v1/me_spec.rb:5``
```

#### API 文档配置

1. Gemfile 使用本地依赖

```ruby
gem 'rspec_api_documentation', path: './vendor/rspec_api_documentation'
```
2. 提前解决Api文档中请求体与响应体无法正常显示的问题

- 请求体

```ruby
# spec/spec_helper.rb
require 'rspec_api_documentation'
RspecApiDocumentation.configure do |config|
  # 配置文档中请求体的格式为json
  config.request_body_formatter = :json
end
```

- 响应体

用修复过 bug 的依赖

```bash
# 将代码克隆到 vendor 中，别忘删除掉.git
$ git clone git@github.com:GSemir0418/rspec_api_documentation.git vendor/rspec_api_documentation
# 刷新依赖
$ bundle
```
3. 创建 api 文档测试文件夹 `mkdir spec/acceptance`

---

## API开发

### API 开发主要流程及命令

#### 设计 table、api

#### 创建 model

`bin/rails g model <Name> field1:type field2:type`

#### 同步数据表

`bin/rails db:create db:migrate`

`RAILS_ENV=test bin/rails db:create db:migrate`

- 修改表结构

`bin/rails g migrate AddDeletedAtToItems deleted_at:datetime`

- 回滚命令

`bin/rails db:rollback step=1`

#### 创建 controller

`bin/rails g controller api/v1/<controller_names>`

`bin/rails g controller Api::V1::<Names>`

驼峰和下划线都可, 斜杠也可, 在Rails中，双冒号（::）用于表示命名空间的层级关系，而斜线（/）用于表示路径的层级关系。Rails会将斜线转换为双冒号，并根据命名空间的层级关系创建相应的文件和目录结构。因此，在这两条指令中，最终生成的文件和动作都是相同的。

#### TDD

- 初始化

`bin/rails g rspec:install`

- 创建测试文件

`bin/rails g rspec:request <controller_names>`

- 创建接口测试文档文件

`touch /spec/acceptance/<controller_names>_spec.rb`

#### 接口文档生成

`bin/rake docs:generate`

### 设计 Table

t.string 和 t.text 区别

1. 数据类型： t.string 创建的列会使用数据库中的字符串类型（如 VARCHAR），而 t.text 创建的列会使用数据库中的文本类型（如 TEXT）。

2. 存储空间： 字符串类型 (t.string) 通常用于存储相对较短的文本，例如标题、姓名等，有一个固定的最大长度。而文本类型 (t.text) 通常用于存储更长的文本，如文章内容、评论等，没有固定的最大长度限制。

3. 索引： 由于字符串类型有固定的最大长度，因此可以创建索引以提高搜索和排序的性能。文本类型没有固定的最大长度，所以不能创建普通索引，但可以创建全文索引（Full-Text Index）来支持全文搜索。

### Model

执行生成命令后，rails 会帮我们创建`数据模型文件`及`数据库schema`文件；

模型类默认是单数形式的

ActiveRecord 是 Rails 中的默认 ORM 工具，用于简化与数据库的交互。

模型类通常继承 ApplicationRecord ?? ActiveRecord::Base，以实现与数据库的交互

提供验证方法 validate 支持常规校验与自定义校验，自定义校验除非在self.errors中add error，否则默认返回 nil，表示通过校验

数据范围 default_scope

声明与其他模型之间的关系 belongs_to

定义该数据模型实例的方法，例如User的generate_jwt

支持生命周期函数，例如before_create，after_create，用于数据模型实例在被创建前后执行的逻辑

总结：将数据的校验逻辑及模型相关的工具逻辑抽离到model类中

数据的校验逻辑会在执行 save/create/update 等方法时进行校验

工具逻辑（例如生成 jwt、生成验证码、发送邮件）的执行可以利用 ActiveRecord 提供的生命周期回调（`before_create/after_save/before_update` 等），决定工具函数的执行时机

而 controller 层仅用于操作数据库，根据不同情况返回不同响应

### Migration

生成 model 会生成 migration 文件

执行同步命令后，rails 会主动读取数据库信息，将数据库表结构存入 schema 文件中，因此手动更改这个文件是无效的

数据库表结构只能通过执行一次新的 migration 来修改

### Controller

执行生成命令后，rails会帮我们创建`控制器文件`及`对应路由`

专注于请求/响应逻辑，与数据库交互的逻辑等

#### 路由

resource 定义了一个 RESTful 资源，表示该资源具有多个默认的 CRUD（创建、读取、更新、删除）操作。

控制器文件默认都是**复数形式**的，与我们在路由文件中定义的 resource 的单复数形式无关

- 关于路由用 resource 还是 resources：

  - resource用于当您只有一个模型对象（单数资源）时，例如/profile表示当前登录用户的个人资料。使用resource时，不会创建index路由，而且没有一个路由需要在URL中传递ID参数。
  - resources用于当您有多个模型对象（复数资源）时，例如/posts表示所有的文章。使用resources时，会创建index, show, new, edit, create, update, destroy等常用的路由，每个路由都需要在URL中传递ID参数来指定具体的对象。

在 RESTful 设计中，资源的路由通常使用复数形式，rails 也会自动将路由映射为复数形式

路由可以通过定义资源的形式来表示，例如 `resources :items, only: [:create, :index, :destroy]`

手动指定路由与控制器方法的映射关系：

`post :validation_code, to: 'validation_code#create'`

only 数组中定义了该资源接收的请求方法，其余请求方法均会返回 404

这些请求方法分别对应 controller 中的方法

其中 index 与 show 方法非常相似，但 index 用于显示资源的集合（列表），可以显示多个资源；而 show 用于显示单个资源的详细信息，主要用于显示单个资源。

这些方法通常与路由一起使用，以便在浏览器中使用相应的 URL 访问它们。例如，index方法可以与 GET /posts 或 /posts?page=1 路由关联，而show方法可以与 GET /posts/:id 路由关联

#### CRUD Api

在编写 controller 逻辑时，通常需要借助 model 类对数据库进行增删改查的操作。下面列举一些常见 api

new 创建一个数据实例

save 将实例保存至数据库

create 相当于 new + save

find 使用主键查询

find_by 使用传入的值作为查询条件，返回第一个满足条件的数据

update 一般使用find查数据，该数据，再save，相当于update

#### 响应

rails 提供了 render、head、redirect_to等关键字指定响应体内容或重定向操作

render 关键字可以指定要渲染的视图模板、设置响应头、指定响应格式等

- `render json: {}`：将指定的 JSON 对象作为响应的主体。
- `render plain: 'text'`：将指定的纯文本作为响应的主体。
- `render file: 'path/to/file'`：将指定的文件内容作为响应的主体。
- `render template: 'path/to/template'`：渲染指定的视图模板并作为响应的主体。
- `render action: :new`：渲染指定动作对应的视图模板并作为响应的主体。

`head` 方法则更适用于简单的状态码响应，不需要具体响应主体内容的情况。

### TDD

TDD 测试驱动开发是一种开发策略，即先写单元测试，再以通过测试的目的来写 controller 层逻辑。测试完成后，接口功能基本也实现了

测试分成单元测试和文档测试，单元测试用来测试接口失败的情况，而文档测试用来测试接口成功的情况，成功后会自动生成接口文档

配置rspec，统一文档测试时的请求头

```ruby
# spec/spec_helper.rb
...
Rspec.configure do |config|
  config.before(:each) do |spec|
    # 如果是acceptance类型的测试
    if spec.metadata[:type].equal? :acceptance
      header 'Accept', 'application/json'
      header 'Content-Type', 'application/json'
    end
  end
...
```

生成文档命令：`bin/rake docs:generate`

- bin/rake 与 bin/rails 的区别：

  - bin/rake 用于执行 Rake 任务，比如数据库迁移、测试运行、api文档生成等

  - bin/rails 提供了更高级的命令，比如服务器运行、应用程序生成等

接口文档页面在 doc/api 文件夹下，使用 `npx http-server doc/api` 来查看

## 其他

### 密钥管理

1. 生成或编辑 keys `bin/rails credentials:edit`
2. or 指定 vscode 编辑 `EDITOR="code --wait" bin/rails credentials:edit`
3. 读取 keys `bin/rails c | Rails.application.credentials.secret_key_base` 或者 `Rails.application.credentials.config`
4. 生产环境 keys `EDITOR="code --wait" rails credentials:edit --environment production`
5. 需要自定义 secret_key_base
6. 读取生产环境 keys `RAILS_ENV=production bin/rails c | Rails.application.credentials.secret_key_base` 或者 `Rails.application.credentials.config`
7. 生产环境数据库配置
8. 剧透：对于本项目来说，只会管理 jwt 密钥、邮箱服务器授权码及数据库密码
9. 查看密钥：`bin/rails c | Rails.application.credentials.config`

### 中间件

写中间件
bin/rails middleware 显示全部中间件
touch lib/auto_jwt.rb 在lib下创建中间件文件（lib是自己给自己写的库，vendor是别人给自己写的库）

全局配置中间件

```rb
# config/application.rb
...
require_relative "../lib/auto_jwt"

Bundler.require(*Rails.groups)

module RailsTodo1
  class Application < Rails::Application
    ...
    config.middleware.use AutoJwt
  end
end
```

改写 mes controller

### 配置邮件服务器

1. 创建 mailer `bin/rails generate mailer User`

```bash
create  app/mailers/user_mailer.rb
invoke  erb
create    app/views/user_mailer
invoke  rspec
create    spec/mailers/user_spec.rb
create    spec/mailers/previews/user_preview.rb
```

2. Mailer 全局配置

```rb
# app/mailers/application_mailer.rb
class ApplicationMailer < ActionMailer::Base
	# 全局发送邮件地址
  default from: "845217811@qq.com"
  # html默认布局
  layout 'mailer'
end
```

3. 邮件配置

```rb
# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
  def welcome_email(code)
    # 给模板传递变量
    @code = code
    mail(to: "845217811@qq.com", subject: 'Welcome to My Awesome Site')
  end
end
```

4. 修改邮件内容

```erb
<!-- app/views/user_mailer/welcome_email.html.erb -->
<!DOCTYPE html>
<html>
  <head>
    <meta content="text/html; charset=UTF-8" http-equiv="Content-Type" />
  </head>
  <body>
    <%# 使用传递的变量 %> hi <%= @code %>
  </body>
</html>
```

5. 开启 qq 邮箱的 smtp 服务：登录 qq 邮箱，点击「设置」=>「账户」=>「开启 IMAP/SMTP 服务」=>「短信验证」
6. 保存授权码：`EDITOR="code --wait" bin/rails credentials:edit`
7. 写入 email_pw: ycmbmysnijqcbfgb
8. 配置邮件服务：记得生产环境也要配置

```ruby
# config/environments/development.rb
...
# 是否抛出邮件错误
config.action_mailer.raise_delivery_errors = true
# 是否使用缓存
config.action_mailer.perform_caching = false
#
config.action_mailer.smtp_settings = {
  address:				'smtp.qq.com',
  port: 				587,
  domain:				'smtp.qq.com',
  user_name: 			'845217811@qq.com',
  password:				Rails.application.credentials.email_pw,
  authentication:		'plain',
  anable_starttls_auto: true,
  open_timeout:			10,
  read_timeout:			10
}
...
```

10. 控制台测试邮件发送功能
    `bin/rails console`

```
# 使用UserMailer内置方法即可
UserMailer.welcome_email('123456').deliver
```

记得生产环境也需要配置授权码

## 部署

生产环境使用 puma 作为后端服务器，使用 puma-daemon 后台运行

[kigster/puma-daemon: Puma (starting version 5) removed automatic demonization from the gem itself. This functionality was extracted to this gem, which supports Puma v5 and v6. (github.com)](https://github.com/kigster/puma-daemon#what-is-daemonization)

Gemfile 添加依赖

```ruby
gem "puma", "~> 5.0"

gem 'puma-daemon', require: false
```

bundle 安装依赖

修改 puma 配置

```ruby
require 'puma/daemon'
# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Specifies the `worker_timeout` threshold that Puma will use to wait before
# terminating a worker in development environments.
#
worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
#
port ENV.fetch("PORT") { 3000 }

# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch("RAILS_ENV") { "production" }

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked web server processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#
# workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory.
#
# preload_app!

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart

stdout_redirect 'log/access.log', 'log/error.log', true

daemonize
```

开启后台 puma 服务器 `bundle exec puma -C config/puma.rb`

终止后台 puma 服务器 `bundle exec pumactl stop`





