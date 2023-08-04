---
title: Ruby学习
date: 2023-03-17T15:42:00+08:00
tags: ["Ruby", "Rails"]
sidebar-position: 1
authors: gsemir
---

>参考：
>
>[Learn ruby in Y Minutes (learnxinyminutes.com)](https://learnxinyminutes.com/docs/zh-cn/ruby-cn/)
>
>[Basic Data Types | The Odin Project](https://www.theodinproject.com/lessons/ruby-basic-data-types)

# 1 Ruby 基础

## 1.0 注释

```ruby
# 这是单行注释

=begin
这是多行注释
=end
```

## 1.1 基础数据类型

Ruby 是典型的面向对象语言，在 Ruby 中一切皆是对象，包括基础数据类型。

```ruby
# 数字是对象
3.class #=> Integer
3.to_s #=> "3"
# 字符串是对象
"Hello".class #=> String
# 布尔值是对象
nil.class #=> NilClass
true.class #=> TrueClass
false.class #=> FalseClass
# 甚至方法也是对象
"Hello".method(:class).class #=> Method
```

Ruby 共有四种基础数据类型：`numbers(integers, floats)`、`strings`、`symbols`、`Booleans(true, false, nil)`

### 1.1.1 Numbers

#### 运算

```ruby
# 基础运算
1 + 1   #=> 2
8 - 1   #=> 7
10 * 2  #=> 20
35 / 5  #=> 7
2 ** 5  #=> 32
5 % 3   #=> 2

# 位运算符
3 & 5 #=> 1
3 | 5 #=> 7
3 ^ 5 #=> 6
```

算术符号只是语法糖而已，实际上是调用对象的方法

```ruby
1.+(3) #=> 4
10.* 5 #=> 50 
100.methods.include?(:/) #=> true
```

#### 整型与浮点型

Ruby 的 numbers 包括主要有两种类型。**Integers** 就是整型数字，**Floats** 就是包含小数点的数字。

当两个整型数字做数学运算时，*其结果总是整型*

```ruby
17 / 5 #=> 3, not 3.4
```

若要输出正确的结果，只需替换其中一个整型为浮点型数字即可。

```ruby
17 / 5.0 #=> 3.4
```

#### 转换数字类型

```ruby
13.to_f #=> 13.0
# to_i 方法会直接抛弃小数点后的数据
13.9.to_i #=> 13
```

#### 常用方法

```ruby
4.even? #=> true
7.odd? #=> true
```

### 1.1.2 Strings

字符串主要有`""`和`''`的形式，其区别在于`""`支持*插入变量*与*转义字符*

#### 拼接字符串

```ruby
"Welcome" + "to" + "China" #=> "Welcome to China"
"Welcome" << "to" << "China" #=> "Welcome to China"
"Welcome".concat("to").concat("China") #=> "Welcome to China"
```

#### 截取字符串

```ruby
"hello"[0]	#=> "h"
"hello"[0..1]	#=> "he"
"hello"[0, 4]	#=> "hell"
"hello"[-1]	#=> "o"
```

#### 转义字符

```
\\; \b # backspace; \r # 回车; \n # 下一行; \s # space; \t tab; \"; \'
```

#### 插值

```ruby
name = 'gsq'
puts "Hello, #{name}"
```

#### 常用方法

```ruby
"hello".capitalize #=> "Hello"
"hello".include?("lo")  #=> true
"hello".upcase  #=> "HELLO"
"Hello".downcase  #=> "hello"
"hello".empty?  #=> false
"hello".length  #=> 5
"hello".reverse  #=> "olleh"
"hello world".split  #=> ["hello", "world"]
"hello".split("")    #=> ["h", "e", "l", "l", "o"]
" hello, world   ".strip  #=> "hello, world"
"he77o".sub("7", "l")           #=> "hel7o"
"he77o".gsub("7", "l")          #=> "hello"
"hello".insert(-1, " dude")     #=> "hello dude"
"hello world".delete("l")       #=> "heo word"
"!".prepend("hello, ", "world") #=> "hello, world!"
```

#### 转换字符串

```ruby
5.to_s        #=> "5"
nil.to_s      #=> ""
:symbol.to_s  #=> "symbol"
```

#### 字符串与数字转换

```ruby
'A'.ord #=> 65
'Z'.ord #=> 90
'a'.ord #=> 97
'z'.ord #=> 122
65.chr #=> 'A'
```

### 1.1.3 Symbols

Symbols 仅在内存中存储一次，性能要优于 Strings

符号是不可变的，内部用整数值表示的可重用的常数；通常用它代替字符串来有效地表示有意义的值

```ruby
:pending.class #=> Symbol
status = :pending
status == :pending #=> true
status == 'pending' #=> false
status == :approved #=> false
```

#### Symbols vs. Strings

利用 `object_id` 方法（返回对象的整型数字标识）证实二者区别：Symbol在内存中独一无二

```ruby
"string" == "string"  #=> true
"string".object_id == "string".object_id  #=> false
:symbol.object_id == :symbol.object_id    #=> true
```

### 1.1.4 Booleans

包括 `true`、`false`、`nil`，它们也都是对象

```ruby
nil.class #=> NilClass
true.class #=> TrueClass
false.class #=> FalseClass
```

## 1.2 变量

### 1.2.1 声明与命名

```ruby
# 声明与赋值
x = 25 #=> 25
x #=> 25

# 注意赋值语句返回了赋的值
# 这意味着你可以用多重赋值语句

x = y = 10 #=> 10
x #=> 10
y #=> 10

# 按照惯例，使用类似 snake_case 风格的变量名
snake_case = true

# 使用有意义的变量名
path_to_project_root = '/good/name/'
path = '/bad/name/'
```

### 1.2.2 赋值运算符

```ruby
age = 18
age += 4 #=> 22
age -= 2  #=> 16
age *= 2 #=> 36
age /= 10 #=> 1
```

## 1.3 输入与输出

### 1.3.1 打印输出

```
# 打印输出，并在末尾加换行符
puts "I'm printing!"
#=> I'm printing!
#=> nil

# 打印输出，不加换行符
print "I'm printing!"
#=> I'm printing! => nil
```

### 1.3.2 获取输入

gets 方法会返回用户输入的值，而不是 nil

```ruby
user_input = gets
111
=> "111"
```

## 1.4 条件逻辑

在 Ruby 中判断一个表达式的真假非常简单：**只有返回 `false` 本身和 `nil` 才会判定为 `false` **，其他条件都是 `true`

### 1.4.1 基本条件语句

```ruby
if true
  "if statement"
elsif false
 "else if, optional"
else
 "else, also optional"
end
```

如果只有 if 部分，可以简写为

```ruby
put "1 < 2" if 1 < 2
```

### 1.4.2 比较运算符

#### 常规

```ruby
# 常规
5 != 7 #=> true
5 > 7 #=> false
7 < 5 #=> false
7 >= 5 #=> true
5 <= 7 #=> true
```

#### 相等

`==`、`.eql?`、`.equal?`，三者对于相等逻辑的判断严谨性是递增的

```ruby
# == 比较两个字面量以及类型是否相等
5 == 5.0 #=> true 
'color' == :color #=> false

# eql? 除了字面量，还会细分到数据类型（Number）中的类(Integer / Float)
5.eql?(5.0) #=> false; although they are the same value, one is an integer and the other is a float
'gsq'.eql?('gsq') #=> true

# equal? 检查这两个值是否是内存中完全相同的对象
a = 5
b = 5
a.equal?(b) #=> true
a = "hello"
b = "hello"
a.equal?(b) #=> false
```

#### 组合比较运算符

仅比较字面量

```ruby
5 <=> 10    #=> -1
10 <=> 10   #=> 0
10 <=> 5    #=> 1
```

### 1.4.3 逻辑运算符

#### `&&` 或者 `and`

```ruby
if 1 < 2 && 5 < 6
  puts "Party at Kevin's!"
end
if 1 < 2 and 5 < 6
  puts "Party at Kevin's!"
end
```

#### `||` 或者 `or`

```ruby
if 10 < 2 || 5 < 6 
  puts "Party at Kevin's!"
end
if 10 < 2 or 5 < 6
  puts "Party at Kevin's!"
end
```

#### `!`

```ruby
if !false     #=> true
if !(10 < 5)  #=> true
```

### 1.4.4 Case 语句

`case...when...else`

```ruby
grade = 'B'

case grade
when 'A'
  puts "Way to go kiddo"
when 'B'
  puts "Better luck next time"
when 'C'
  puts "You can do better"
else 
  puts "Alternative grading system, eh?"
end
#=> "Better luck next time"

# case也可以用区间
grade = 82
case grade
when 90..100
  puts 'Hooray!'
when 80...90
  puts 'OK job'
else
  puts 'You failed!'
end
#=> "OK job"
```

### 1.4.5 Unless 语句

unless 语句与 if 语句的工作方式相反，增强代码可读性

```ruby
age = 19
# 可以放在句尾
puts "Welcome to a life of debt." unless age < 18

# 也可以添加 else
unless age < 18
  puts "Down with that sort of thing."
else
  puts "Careful now!"
end
```

### 1.4.6 三元运算符

```ruby
age = 19
response = age < 18 ? "Young" : "Old"
puts response #=> "Old"
```

## 1.5 循环语句

循环就是*在满足某个条件之前，不断重复执行的代码块*

### 1.5.1 Loop 循环

必须包含 break 条件，否则将陷入死循环；几乎不用这种方式编写循环语句

```ruby
i = 0
loop do
  puts "i is #{i}"
  i += 1
  break if i == 10
end
```

### 1.5.2 While 循环

比 Loop 语句可读性强（？）

```ruby
i = 0
while i < 10 do
 puts "i is #{i}"
 i += 1
end
```

### 1.5.3 Until 循环

Until Loop 的工作方式与 While Loop 相反，While Loop 只要条件为真，循环就会继续；而 Until Loop 会循环持续到条件为假

Until Loop 与 Unless 语句一样，避免了我们在正向逻辑推理过程中使用 `!` 否定逻辑表达式，使得代码更容易理解，可读性大大加强。

### 1.5.4 范围

在 Ruby 中，只需提供起始值和结束值，便可以生成一个范围

```ruby
(1..5)      # inclusive range: 1, 2, 3, 4, 5
(1...5)     # exclusive range: 1, 2, 3, 4

# We can make ranges of letters, too!
('a'..'d')  # a, b, c, d
```

### 1.5.5 For 循环

```ruby
for i in 0..5
  puts "#{i} zombies incoming!"
end

arr = [1,2,3]
result = []
for number in arr do
  if number != 1
  	result.push(number)
  end
end
```

### 1.5.6 Times 循环

```ruby
5.times do |number|
  puts "Alternative fact number #{number}"
end
```

### 1.5.7 Upto 和 Downto 循环

可以使用这两种方法分别从一个起始数字向上或向下迭代到终止数字，主要特征就是能够控制循环顺序

```ruby
5.upto(10) {|num| print "#{num} " }     #=> 5 6 7 8 9 10
10.downto(5) {|num| print "#{num} " }   #=> 10 9 8 7 6 5
```

## 1.6 数组

**数组**是表示数据集合的方式之一，可以将其视为有序列表。

数组允许您创建和操作这些数据的有序和索引集合

数组中的各个变量、数字或字符串称为**元素**。数组可以包含变量、数字、字符串或其他 Ruby 对象（包括其他数组）的任意组合

```ruby
[1, "hello", false] #=> [1, "hello", false]
```

### 1.6.1 创建数组

主要有**字面量**与**Array.new**两种方式创建数组

```ruby
num_array = [1, 2, 3, 4, 5]
str_array = ["This", "is", "a", "small", "array"]

Array.new               #=> []
Array.new(3)            #=> [nil, nil, nil]
Array.new(3, 7)         #=> [7, 7, 7]
Array.new(3, true)      #=> [true, true, true]
```

### 1.6.2 访问元素

可以通过**索引**的方式访问元素

```ruby
# 从前面开始
array[0] #=> 1
array.first #=> 1
array[12] #=> nil

# 像运算符一样，[index] 形式的访问也只是语法糖
# 本质上是调用对象的 [] 方法
array.[] 0 #=> 1
array.[] 12 #=> nil

# 从尾部开始
array[-1] #=> 5
array.last #=> 5

# 同时指定开始的位置和长度
array[2, 3] #=> [3, 4, 5]

# 或者指定一个区间
array[1..3] #=> [2, 3, 4]
```

### 1.6.3 添加或移除元素

- `push(elements)` / `<<`：队尾新增元素

- `pop(x)` / `shift(x)`：删除后/前 x（1）个元素

- `unshift(elements)`：队首新增

```ruby
num_array = [1, 2]
# 添加
num_array.push(3, 4)      #=> [1, 2, 3, 4]
num_array << 5            #=> [1, 2, 3, 4, 5]
# 删除（弹出）最后一个元素
num_array.pop             #=> 5
num_array                 #=> [1, 2, 3, 4]
num_array = [2, 3, 4]
# 在首部新增一个1
num_array.unshift(1)      #=> [1, 2, 3, 4]
# 删除第一个元素
num_array.shift           #=> 1
num_array                 #=> [2, 3, 4]
num_array = [1, 2, 3, 4, 5, 6]
# 删除最后三个元素
num_array.pop(3)          #=> [4, 5, 6]
# 删除前两个元素
num_array.shift(2)        #=> [1, 2]
num_array                 #=> [3]
```

### 1.6.4 数组的加减

数组间的加和相当于数组的**拼接**

```ruby
a = [1, 2, 3]
b = [3, 4, 5]

a + b         #=> [1, 2, 3, 3, 4, 5]
a.concat(b)   #=> [1, 2, 3, 3, 4, 5]
```

数组间相减会移除**全部**相同元素

```ruby
[1, 1, 1, 2, 2, 3, 4] - [1, 4]  #=> [2, 2, 3]
```

### 1.6.5 常用方法

可以通过 `num_array.methods` 查看全部 Array 实例方法

```ruby
[].empty?               #=> true
[[]].empty?             #=> false
[1, 2].empty?           #=> false

[1, 2, 3].length        #=> 3

[1, 2, 3].reverse       #=> [3, 2, 1]

[1, 2, 3].include?(3)   #=> true
[1, 2, 3].include?("3") #=> false

[1, 2, 3].join          #=> "123"
[1, 2, 3].join("-")     #=> "1-2-3"
```

## 1.7 哈希表

哈希表是 Ruby 的主要键/值对表示法

### 1.7.1 创建 Hash

哈希表由大括号表示

```ruby
hash = {'color' => 'green', 'number' => 5}
my_hash = Hash.new #=> {}
```

哈希的 key 可以是字符串、数字、Symbol

```ruby
hash = { 9 => "nine", :six => 6 }
```

### 1.7.2 访问值

哈希表可以通过键快速地查询

```ruby
hash = { 'color' => 'green', "number" => 5}
hash['color'] #=> 'green'
hash['number'] #=> 5

# 未查询到对应key的值 返回nil
hash["name"] #=> nil
# Ruby提供fetch方法，如果key不存在，则会报错
hash.fetch("name") #=> KeyError: key not found: "name"
# fetch 方法还支持默认值，若key不存在，则返回默认值
hash.fetch("name", "gsq") #=> "gsq"
hash.fetch "name", "gsq" #=> "gsq"
```

### 1.7.3 添加与更新数据

可以通过调用键并设置值来将键值对添加到哈希中，如果 key 存在，则会更新 value

```ruby
hash = { 'color' => 'green', "number" => 5}
hash['name'] = 'gsq'
hash['color'] = 'red'
```

### 1.7.4 删除数据

使用 delete 方法删除键值对

```ruby
hash.delete 'color'
```

### 1.7.5 共享方法

```ruby
books = {
  "a" => "A",
  "b" => "B"
}

# 列举全部的 keys 与 value
books.keys      #=> ["a", "b"]
books.values    #=> ["A", "B"]

# 检查键值是否存在
books.key?('a') #=> true
books.value?('A') #=> true
```

哈希与数组共享许多相同的方法，因为它们都使用 Ruby 的**枚举**模块，都是**可枚举的**，后面会补充

### 1.7.6 合并对象

hash 提供合并对象的方法 `merge`，hash2 会将 hash1 中相同 key 的值替换。

```ruby
hash1 = { "a" => 100, "b" => 200 }
hash2 = { "b" => 254, "c" => 300 }
hash1.merge(hash2)      #=> { "a" => 100, "b" => 254, "c" => 300 }
```

### 1.7.7 Symbols 作为 Hash keys

当 Symbols 作为 Hash keys 时，写法可以由 `:key => value` 改为 `key: value`

```ruby
student = { :name => 'gsq', :age => 18 }
# 等价于
student = { name: 'gsq', age: 18 }
# 读取
student[:name] #=> 'gsq'
student['name'] #=> nil
```

## 1.8 方法

在 Ruby 中一切皆对象，Ruby 内置了大量的方法，其本质都是在类（Integer、Object）中定义的方法

### 1.8.1 创建方法

```ruby
def my_name
  "GSQ"
end

my_name #=> 'GSQ'
```

### 1.8.2 方法名

- 不允许使用保留字

- 不能使用`!`、`?`、`_`、`=`以外的任何特殊符号

- 只能将`！`、`？`、`=`用于方法名称末尾

- 数字不能开头

### 1.8.3 Parameters 和 Arguments

两者的中文翻译都是“参数”，二者的区别在于：

- Parameters在方法中充当占位符变量，即形参；

- 而 Arguments 是在调用方法时传递给方法的实际变量，即实参

```ruby
def greet name = "stranger"
  "Hello, " + name + "!"
end

puts greet "John" #=> Hello, John!
puts greet #=> Hello, stranger!
```

### 1.8.4 返回值

可以使用 return 关键字显式制定方法返回值

```ruby
def puts_squared number
  return number * number
  # return 后的代码不再执行
  puts 'done'
end
```

默认情况下，函数 (以及所有的块) 隐式返回最后语句的值

```ruby
def puts_squared number
  number * number
end
```

### 1.8.5 Predicate 方法

Ruby 内置了很多 Predicate 方法，它们的名称都是以 `?` 结尾的，并且返回 Boolean

```ruby
puts 5.even?  #=> false
puts 6.even?  #=> true
puts 17.odd?  #=> true

puts 12.between?(10, 15)  #=> true
```

这类方法统一被称作 ”Predicate Method“，我们在实际开发中，只要方法返回的是一个Boolean，那么命名时建议学习Ruby，以 `?` 结尾

### 1.8.6 Bang 方法

当我们执行一个对象的方法时，是不会改变对象的原始值的。在编程中我们是不希望由于执行了对象的方法而改变对象本来的值的情况发生的。

```ruby
text = 'HELLO'
text.downcase #=> 'hello'
# 不会改变对象初始值
text #=> 'HELLO'
```

若要强制改变初始值，可以调用方法时在最后加上 `！` 字符

```ruby
text.downcase! #=> 'hello'
text #=> 'hello'
# 相当于
text = text.downcase
```

## 1.9 调试

每个对象都有 `.inspect` 方法，该方法能够返回我们为创建对象本身而编写的**原始代码**

而 p 命令就相当于

```ruby
def p object
  puts object.inspect
end
```

结合了 puts 与 inspect 的特征，在调试程序时非常好用

还有一种是利用 `pry-byebug` 包，后续补充（？）

## 1.10 基本可枚举方法

### 1.10.1 each

数组

```ruby
friends = ['Sharon', 'Leo', 'Leila', 'Brian', 'Arun']
friends.each { |friend| puts "Hello, " + friend }
# 相当于
friends.each do |friend|
  puts "Hello, " + friend
end

# 返回初始数组
```

哈希

```ruby
my_hash = { "one" => 1, "two" => 2 }
# 接受两个参数，分别是 key 和 value
my_hash.each { |key, value| puts "#{key} is #{value}" }

one is 1
two is 2
#=> { "one" => 1, "two" => 2}

# 也可以接受一个参数，表示键值对数组
my_hash.each { |pair| puts "the pair is #{pair}" }

the pair is ["one", 1]
the pair is ["two", 2]
#=> { "one" => 1, "two" => 2}

# 返回初始哈希
```

### 1.10.2 each_with_index

新增了 `index` 作为 block 的第二个参数

数组

```ruby
friends.each_with_index { |friend, index| puts "Hello, " + index + friend }
# 返回初始数组
```

哈希

```ruby
my_hash.each_with_index { |pair, index| puts "the pair is #{index} #{pair}" }
# 返回初始哈希
```

### 1.10.3 map

用法同 each，返回新数组/哈希

### 1.10.4 select

用法同 map，接受的 block 必须返回一个 Boolean，用于筛选元素

```ruby
# 数组
friends = ['Sharon', 'Leo', 'Leila', 'Brian', 'Arun']
friends.select { |friend| friend != 'Brian' }
 #=> ["Sharon", "Leo", "Leila", "Arun"]

# 哈希
responses = { 'Sharon' => 'yes', 'Leo' => 'no', 'Leila' => 'no', 'Arun' => 'yes' }
responses.select { |person, response| response == 'yes'}
#=> {"Sharon"=>"yes", "Arun"=>"yes"}
```

### 1.10.5 reduce/inject

Block 的第一个参数是一个**累加器**（前面累加计算的结果），第二个参数是**元素**

当遍历数组后需要输出一个值（或对象）时，可以选用此方法

```ruby
# 求和
arr = [1,2,3]
result = arr.reduce do |sum, number|
  sum += number
end
#=> 6
```

例子：统计票数

```ruby
votes = ["Sam", "Jack", "Sam"]
# Hash.new(0)表示创建一个空哈希，对未赋值的key赋予默认value为0
# 传入reduce表示作为第一次遍历的result
votes.reduce(Hash.new(0)) do |result, vote|
  result[vote] += 1
  result
end
#=> {"Sam"=>2, "Jack"=>1}
```

### 1.10.6 Bang 方法

Bang 方法即在调用方法名后加 `!` 字符，表示此方法会修改初始对象

```ruby
friends = ['Sharon', 'Leo', 'Leila', 'Brian', 'Arun']

friends.map! { |friend| friend.upcase }
#=> `['SHARON', 'LEO', 'LEILA', 'BRIAN', 'ARUN']`

friends
#=> `['SHARON', 'LEO', 'LEILA', 'BRIAN', 'ARUN']`
```

尽量少用

## 1.11 Predicate 可枚举方法

谓词可枚举方法属于可枚举方法的一个特殊子集，方法名由 `?` 结尾，返回 Boolean

### 1.11.1 include?

判断元素是否存在，只能应用于数组

```ruby
# 数组
numbers = [1, 2, 3, 4]
numbers.include?(3) #=> true
numbers.include?(6) #=> false
```

### 1.11.2 any?

传入 block，如果存在满足 block 条件的元素，返回 true；适用于数组与哈希

```ruby
# 数组
numbers = [1, 2, 3]
numbers.any? do |number|
	number <= 4
end
#=> true

# 对象
user = { name: 'gsq', age: 10 }
user.any? do |pair|
  pair.include? 'gsq'
end
#=> true
```

### 1.11.3 all?

接收一个 block，数组或哈希中全部元素满足 block 的条件，才会返回 true

只要有一项返回 false，遍历就会终止

```ruby
numbers = [1, 2, 3]
numbers.all? { |number| number <= 3 } #=> true

user = { 'a': 'A', 'b': 'B' }
user.all? { |key, value| key.upcase == value } #=> false
# 这里为什么是false啊 
# 'A' == 'A' => true
# 'a'.upcase == 'A' => true
# 因为用的是冒号，导致 key 的类型变成了 symbol
```

### 1.11.4 none?

与 all? 相反，当数组/哈希中的元素没有符合 block 条件的，则返回 true

```ruby
numbers = [1, 2, 3]
numbers.none? do |number|
  number > 4
end #=> true

user = { name: 'gsq', age: 1 }
user.none? { |pair| pair[0] == pair[1] } #=> true
```

## 1.12 嵌套集合

### 1.12.1 多维数组

如果要在尝试访问不存在的嵌套元素的索引时返回 nil ，可以使用 `dig` 方法，防止报错

```ruby
seats = [
  ["Adams", "Baker", "Clark", "Davis"],
  ["Jones", "Lewis", "Lopez", "Moore"],
  ["Perez", "Scott", "Smith", "Young"]
]
teacher_mailboxes[3][0]
#=> NoMethodError
teacher_mailboxes[0][4]
#=> nil

teacher_mailboxes.dig(3, 0)
#=> nil
teacher_mailboxes.dig(0, 4)
#=> nil
```

#### 创建多维数组

观察两种方式的区别

```ruby
mutable = Array.new(3, Array.new(2))
#=> [[nil, nil], [nil, nil], [nil, nil]]
mutable[0][0] = 1000
#=> 1000
mutable
#=> [[1000, nil], [1000, nil], [1000, nil]]

immutable = Array.new(3) { Array.new(2) }
#=> [[nil, nil], [nil, nil], [nil, nil]]
immutable[0][0] = 1000
#=> 1000
immutable
#=> [[1000, nil], [nil, nil], [nil, nil]]
```

#### 遍历嵌套数组

使用 each_with_index 可以清晰地标记元素所在的行列

```ruby
seats.each_with_index do |row, row_index|
  row.each_with_index do |student, col_index|
    puts "Row #{row_index} Col: #{col_index} = #{student}"
  end
end
```

也可以使用 `flatten` 方法，将多维数组降成一维

```ruby
seats.flatten.each do |student|
  puts "#{student} is amazing!"
end
```

使用 flatten 后，就方便结合 all? 或者 any? 等谓词可枚举方法了

### 1.12.2 嵌套哈希

嵌套哈希是存储复杂关联数据的一种非常常见的方法。

```ruby
vehicles = {
  alice: {year: 2019, make: "Toyota", model: "Corolla"},
  blake: {year: 2020, make: "Volkswagen", model: "Beetle"},
  caleb: {year: 2020, make: "Honda", model: "Accord"}
}
```

#### 访问数据

dig 方法同样适用

```ruby
vehicles[:alice][:year]
#=> 2019

vehicles[:zoe][:year]
#=> NoMethodError
vehicles.dig(:zoe, :year)
#=> nil
```

#### 常用方法

当我们需要统计 vehicles 中 year 为2020年之后的全部数据时，首先想到的是 select 筛选

```ruby
vehicles.select { |name, data| data[:year] >= 2020 }
#=> {:caleb=>{:year=>2020, :make=>"Honda", :model=>"Accord"}, :dave=>{:year=>2021, :make=>"Ford", :model=>"Escape"}}
```

但有时我们只需要车主名称的列表，而不是一个嵌套哈希，这时就可以使用 `collect` 方法

```ruby
vehicles.collect { |name, data| name if data[:year] >= 2020 }
#=> [nil, :caleb, :dave]
```

当没有返回值时，会默认返回 nil ，此时可以使用 `compact` 方法处理数组/哈希中的 nil

```ruby
vehicles.collect {...}.compact
#=> [:caleb, :dave]
```

Ruby 2.7 版本新增了 `filter_map` 方法，非常适用于以上场景

```ruby
vehicles.filter_map { |name, data| name if data[:year] >= 2020 }
#=> [:caleb, :dave]
```

# 2 练习

## 2.1 Caesar Cipher

凯撒密码

```ruby
def translate str, shift
  result = ''
  str.split('').each do |char|
    case char.ord
      when 65..90
      result += (((char.ord + shift - 65) % 26) + 65).chr
      when 97..122
      result += (((char.ord + shift - 97) % 26) + 97).chr
    else
      result += char
    end
  end
  result
end

puts translate 'aB cd', 2
```

## 2.2 统计单词出现次数

```ruby
dictionary = ["below","down","go","going","horn","how","howdy","it","i","low","own","part","partner","sit"]
def sub_string string, dictionary 
  string.split(" ").reduce(Hash.new(0)) {
    |result, str| dictionary.each { 
      |word| result[word] += 1 if str.include? word
    }
    result
  }
end
puts sub_string "below", dictionary
#=> {"below"=>1, "low"=>1}
```

## 2.3 找股票

股票买卖求最大收益，只买卖一次

接收每天的股票价格，返回一对代表最佳买入日和最佳卖出日的天数，日从零开始

```ruby
stock_picker([17,3,6,9,15,8,6,1,10])
#=> [1,4]  # $15 - $3 = $12
```

```
fa's'd
```

# 3 Ruby 面向对象

## 变量

@ 实例变量（属性）

@@ 类变量（属性）

$ 全局变量

## 方法

def MyApp.xxx 类方法

默认方法都是public private方法尽量写在一起 因为定义在 private 关键字下面的方法都会被视为私有方法

私有方法内部定义的变量是无法访问的

### 访问器

attr_reader :name

def name

​	@name

end



 attr_writer :name

def name value

​	@name = value

end



attr_accessor = both

## 继承

class MyApp < Application 继承

super 调用父类同名方法

## 模块

模块类似于类，模块不能创建实例，也不能有子类。它们只是用来存放变量和方法的工具箱

将方法与变量分隔在命名空间中



:: **范围解析运算符** 它告诉 *Ruby 你*在哪里寻找特定的代码

Include 在类中使用，可以省略 Module::



使用 module 可以将类中的方法或者变量抽离出来，再混入（mixin）类中

若使用 module 的方法作为类方法而不是实例方法，则使用 extend 关键字

# 4 文件系统和序列化

当涉及到文件系统和序列化时，Ruby 提供了很多内置的库和方法来进行操作。

## 4.1 文件系统

Ruby 的文件系统操作都是通过内置的 `File` 类来完成的。该类提供了许多方法，使您能够在文件系统中执行各种操作。下面是一些常见的方法：

- `File.exist?(file_path)`：检查文件是否存在
- `File.file?(file_path)`：检查文件是否为常规文件
- `File.open(file_path, mode)`：打开文件，mode 取值为 `r`、`w`、`a` 等
- `File.close()`: 手动关闭文件
- `File.directory?(file_path)`：检查文件是否为目录
- `File.read(file_path)`：读取整个文件内容
- `File.readlines(file_path)`：读取文件的每一行
- `File.write(file_path, content)`：将内容写入文件
- `File.delete(file_path)`：删除文件

此外，Ruby 还提供了 `Dir` 类来处理目录相关的操作。下面是一些常见的方法：

- `Dir.mkdir(directory_path)`：创建目录
- `Dir.entries(directory_path)`：列出目录中的文件和目录
- `Dir.foreach(directory_path) do |filename| ... end`：遍历目录中的每个文件和目录

## 4.2 序列化

Ruby 提供了内置的序列化和反序列化库，可以将数据从一种格式转换为另一种格式。其中最常见的两种格式是 JSON 和 YAML。

- **JSON**

  Ruby 内置了 `json` 库，用于将 Ruby 对象序列化为 JSON 格式，以及将 JSON 格式反序列化为 Ruby 对象。下面是一些常见的方法：（使用前引入：`require 'json'`）

  - `JSON.dump(object)`：将对象转换为 JSON 格式的字符串
  - `JSON.parse(json_string)`：将 JSON 格式的字符串转换为 Ruby 对象

- **YAML**

  Ruby 内置了 `yaml` 库，用于将 Ruby 对象序列化为 YAML 格式，以及将 YAML 格式反序列化为 Ruby 对象。下面是一些常见的方法：

  - `YAML.dump(object)`：将对象转换为 YAML 格式的字符串
  - `YAML.load(yaml_string)`：将 YAML 格式的字符串转换为 Ruby 对象

## 4.3 练习：事件管理器（CSV）

> [main.rb - FlakyPlumCells - Replit](https://replit.com/@SemirG/FlakyPlumCells#main.rb)

CSV 代表“**逗号分隔值**”。 它是一种简单的文件格式，用于以纯文本形式存储表格数据，例如电子表格或数据库，文件的每一行代表表格的一行，该行中的每个字段（列）由逗号分隔。

1. 尝试使用 read 直接读取 csv 数据

```ruby
lines = File.readlines './event_attendees.csv'
lines.each do |line|
  # 循环跳过第一行
  next if line == " ,RegDate,first_Name,last_Name,Email_Address,HomePhone,Street,City,State,Zipcode\n"
  # 也可以用 index 跳过第一行
  # next if index == 0
  column = line.split ','
  name = column[2]
  p name
end
```

2. 使用内置 csv 库读取数据，并对邮编字段进行处理

```ruby
# 可以利用 Ruby 内置的 csv 库直接读取 csv 文件
require 'csv'
puts 'EventManager initialized.'

# 抽离处理邮编的逻辑
def clean_zipcode zipcode
  if zipcode.nil?
    '00000'
  elsif zipcode.length < 5
    # 使用 rjust 方法，向左填充 0，直到邮编字符串长度为 5
    zipcode.rjust(5, '0')
  elsif zipcode.length > 5
    # 使用数组的切片方法，将 zipcode 变量的值截取为从第 0 个字符开始，到第 4 个字符为止的字符
    zipcode[0..4]
  else
    zipcode
  end
end

contents = CSV.open(
  'event_attendees.csv',
  # 将文件的第一行作为列标题。这将创建一个带有列标题的CSV::Table对象，每一行都将变成一个Hash对象，使用列标题作为Hash的键。
  headers: true,
  # 将列标题转换为符号。这将确保列标题作为Hash的键时，它们是符号而不是字符串。
  header_converters: :symbol
)

contents.each do |row|
  name = row[:first_name]
  zipcode = clean_zipcode row[:zipcode]
  
  puts "#{name} #{zipcode}"
end
```

3. 重构 clean_zipcode 逻辑

利用类型转换的特性，重构 clean_zipcode

```ruby
$ nil.to_s
=> ""
$ "123456".rjust(5, '0')
=> "123456"
$ "12345"[0..4]
=> "12345"

# 结果
def clean_zipcode zipcode
  zipcode.to_s.rjust(5, '0')[0..4]
end
```

4. 使用 Google’s Civic Information 匹配邮编信息

安装

```sh
$ gem install google-api-client
```

使用

```ruby
begin
    legislators = civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    )
    legislators = legislators.officials
		# legislators.map { |legislator| legislator.name }
		#	map 过程可以简写为
    legislator_names = legislators.map(&:name)
    legislators_string = legislator_names.join(", ")
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
end
```

#### ruby 常见语法简写

1. `array.first(n)` 和 `array.last(n)`：获取数组中的前 n 个或后 n 个元素。例如，`[1, 2, 3, 4].first(2)` 将返回一个包含前两个元素的数组 `[1, 2]`。

2. `array.each(&:method)`：将一个符号作为方法名，并使用 `&` 来将它作为代码块传递给 `each` 方法。例如，`[1, 2, 3].each(&:to_s)` 等同于 `[1, 2, 3].each { |n| n.to_s }`。

3. `array.compact`：返回一个新数组，其中不包含 `nil` 元素。例如，`[1, nil, 2, nil, 3].compact` 将返回一个包含 `[1, 2, 3]` 的新数组。

4. `array.uniq`：返回一个新数组，其中不包含重复的元素。例如，`[1, 2, 2, 3, 3, 3].uniq` 将返回一个包含 `[1, 2, 3]` 的新数组。

5. `array.reject(&:method)`：返回一个新数组，其中不包含调用给定方法时返回 `true` 的元素。例如，`[1, 2, 3].reject(&:even?)` 将返回一个包含 `[1, 3]` 的新数组。

6. `array.select(&:method)`：返回一个新数组，其中包含调用给定方法时返回 `true` 的元素。例如，`[1, 2, 3].select(&:even?)` 将返回一个包含 `[2]` 的新数组。

7. `array.reduce(&:+)`：返回数组中所有元素的总和。例如，`[1, 2, 3].reduce(&:+)` 将返回 `6`。

8. `array.reduce(&:*)`：返回数组中所有元素的乘积。例如，`[1, 2, 3].reduce(&:*)` 将返回 `6`。

9. `array.one?(&:method)`：检查数组中是否只有一个元素返回 `true`。例如，`[1, 2, 3].one?(&:even?)` 将返回 `false`，而 `[2].one?(&:even?)` 将返回 `true`。

10. `array.all?(&:method)`：检查数组中是否所有元素都返回 `true`。例如，`[1, 2, 3].all?(&:even?)` 将返回 `false`，而 `[2, 4, 6].all?(&:even?)` 将返回 `true`。

11. `array.any?(&:method)`：检查数组中是否有一个元素返回 `true`。例如，`[1, 2, 3].any?(&:even?)` 将返回 `true`，而 `[1, 3, 5].any?(&:even?)` 将返回 `false`。

    

5. 邮件模版

- 方案一，读取 html 模版文件，利用 `gsub` 或者 `gsub!` 方法替换占位字符串，但是存在一些问题
  - 不能确保字符串的唯一性
  - 如果字段过多，或者采用表格形式的话，利用字符串替换是相当麻烦的
- 方案二，erb
  - *ERB 为 Ruby 提供了一个易于使用但功能强大的模板系统。使用ERB，可以将实际的Ruby代码添加到用于生成文档信息详细信息和/或流控制的任何纯文本文档。*

```ruby
require 'erb'

meaning_of_life = 42

question = "The Answer to the Ultimate Question of Life, the Universe, and Everything is <%= meaning_of_life %>"
template = ERB.new question
# 渲染模板并返回渲染结果
# binding 方法的作用是获取当前上下文的绑定，将 meaning_of_life 变量的值绑定到模板中的表达式，以便在渲染时进行替换
results = template.result(binding)
puts results
```

```ruby
require 'erb'
template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  form_letter = erb_template.result(binding)
  Dir.mkdir('output') unless Dir.exist?('output')
  filename = "output/thanks_#{id}.html"
  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end
```

# 5 模式匹配

在 Ruby 2.7 中，引入了新的“模式匹配”功能。这个功能通过使用  `case...in`  语句进行匹配，可以将变量和常量与某些模式进行匹配，可以在模式中提取匹配对象的属性或变量。

## 5.1 对象模式匹配

在执行匹配过程中的判断逻辑与 `===` 一致，Ruby 会把 case 后的值放在 `===` 右边，会把 in 后的值放在符号左边

```ruby
input = 3

case input
in String then puts 'input was of type String'
in Integer then puts 'input was of type Integer'
end

#=> input was of type Integer
```

插播一下 Ruby 中三重等于运算符 `===` 的内容，`===` 用来检查对象是否属于某个类或是否满足某个模式:

```ruby
String === '111' #=> true
'111' === String #=> false
```

- 在 `String === '111'` 中，`String` 是一个类，因此这个表达式会检查字符串 `'111'` 是否属于 `String` 类或其子类。由于 `'111'` 是一个字符串，而 `String` 是字符串的父类，因此这个表达式返回 `true`。

- 而在 `'111' === String` 中，`'111'` 是一个字符串，`String` 是一个类名，因此这个表达式会检查字符串 `'111'` 是否等于 `String` 这个类名。由于字符串 `'111'` 显然不等于类名 `String`，因此这个表达式返回 `false`。

- 如果 `===` 左侧是类的实例（‘111‘），则比较右侧的值是否与之匹配；如果 `===` 左侧是类（String），则比较右侧是否是该类的实例。

适用于模式匹配的基础数据类型： `Integer` `Float` `NilClass` `TrueClass` `FalseClass` `String` `Symbol`

复杂数据类型：`Object` `Array` `Hash` `Ranges`

## 5.2 变量模式

变量匹配语法可以将任意的值绑定到一个变量上（声明变量，值为传入的 case）

```ruby
age = 15

case age
in a
  puts a
end
# => 15
```

## 5.3 可选模式匹配

可选模式匹配可以提供选项来匹配输入值

```ruby
case 0
in 0 | 1 | 2
  puts :match
end

# => match
```

一般会用 `^` 运算符替换上面的写法，表示匹配不是 3 的值

```ruby
case 0
in ^3
  puts :no_match
else
  puts :match
end
```

## 5.4 模式守卫语句

在 `in` 后面的模式中使用 `if` 或 `unless` 加强模式匹配的精细度

```ruby
some_other_value = true

case 0
in 0 if some_other_value
  puts :match
end
# => match
```

## 5.5 数组模式匹配

- 精确匹配

```ruby
arr = [1 ,2]
case arr
in [1, 2] then puts :match
in 3, 4 then puts :no_match
end # => match

case arr
in [Integer, Integer]
  puts :match
in [String, String]
  puts :no_match
end # => match
```

- 模糊匹配

```ruby
arr = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
case arr
in [Integer, Integer, *, 9, 10]
  puts :match
end # => match

arr = [1, 2, 3, 4]
case arr
in [1, 2, *tail]
  p tail
end # => [3, 4]

case arr
in [_, _, 3, 4]
  puts :match
end # => match
```

- 结合变量模式与 AS 模式匹配

```ruby
case [1, 2, 3, [4, 5]]
in [1, 2, 3, [4, a] => arr]
  puts a
  p arr
end
# => 5
# => [4, 5]
```

## 5.6 哈希模式匹配

- 普通匹配

```ruby
case { a: 'apple', b: 'banana' }
in { a: 'aardvark', b: 'bat' }
  puts :no_match
in { a: 'apple', b: 'banana' }
  puts :match
end # => match
```

- 结合变量模式

```ruby
case { a: 'apple', b: 'banana' }
# 等价于 in { a:, b: }
in a:, b:
  puts a
  puts b
end
# => apple
# => banana
```

- 模糊匹配

```ruby
case { a: 'ant', b: 'ball', c: 'cat' }
in { a: 'ant', **rest }
  p rest
end

# => { :b => "ball", :c => "cat" }
```

- 使用模式匹配语法 `=>` 对哈希进行解构赋值

```ruby
login = { username: 'hornby', password: 'iliketrains' }
# 使用模式匹配将 login 中的 username 键值对的值绑定给了一个名为 username 的变量。
login => { username: username }
puts "Logged in with username #{username}"
#=> "Logged in with username hornby"
```

## 5.7 查找模式

我们可以使用数组模式匹配（占位符*）来匹配哈希的一部分，那么如何匹配数组的一部分？

as 模式将捕获所有数组，变量模式将捕获数组的各个部分。为了解决这个问题，Ruby 添加了查找模式

```ruby
case [1, 2, "a", 4, "b", "c", 7, 8, 9]
in [*pre, String => x, String => z, *post]
  p pre
  p x
  p z
  p post
end

# => [1, 2, "a", 4]
# => "b"
# => "c"
# => [7, 8, 9]
```

- 处理 JSON

```js
data = [
  {name: 'James', age: 50, first_language: 'english', job_title: 'general manager'},
  {name: 'Jill', age: 32, first_language: 'italian', job_title: 'leet coder'},
  {name: 'Helen', age: 24, first_language: 'dutch', job_title: 'biscuit quality control'},
  {name: 'Bob', age: 64, first_language: 'english', job_title: 'table tennis king'},
  {name: 'Betty', age: 55, first_language: 'spanish', job_title: 'pie maker'},
]
```

过去我们查找一条数据，需要遍历，然后通过 if 来判断

```ruby
name = 'Jill'
age = 32
job_title = 'leet coder'

match = data.find do |person|
  person[:name] == name && person[:age] == age && person[:job_title] == job_title
end
# 由于 match 可能会返回 nil 导致空引用异常，使用 & 可以防止程序崩溃（返回nil）
match&.fetch(:first_language)
```

如果查找字段过多，代码会相当难看切难以维护

现在我们使用模式匹配来处理：

```ruby
name = 'Jill'
age = 32
job_title = 'leet coder'
# 值是什么不重要，因为会被匹配到的值覆盖
first_language = 'xxx'

case data
# ^ 表示取出 name 字段用来严格匹配 name 变量的值，但不覆盖上面定义的 name 变量的值
in [*, { name: ^name, age: ^age, first_language: first_language, job_title: ^job_title }, *]
else
  first_language = nil
end

puts first_language
```

# 6 Block

一个Block可以被视为一个代码块，它包含了一些代码，可以在调用方法时传递给这个方法，并在该方法中执行。它是一个可以被传递给方法的可执行代码块。

在Ruby中，Block可以与方法调用一起使用，以便动态地改变方法的行为。Block可以被传递给一个方法，然后在方法内部执行，或者可以被定义在方法内部，然后在方法调用期间执行。

Block 一般的形式是{}、do...end

## 6.1 Yield

yield是一个关键字，可以在方法内部调用以将执行权转交给块。

```ruby
def love_language
  yield('Ruby')
  yield('Rails')
end

love_language { |lang| puts "I love #{lang}" }
#=> I love Ruby.
#=> I love Rails.
```

示例：@transactions 包含多个交易对象，使用 each 方法来遍历 @transactions 数组中的每个交易对象，并调整其展示格式，那么调整展示格式的逻辑就可以使用块来实现

```ruby
@transactions = [10, -15, 25, 30, -24, -70, 999]

def transaction_statement
  formatted_transactions = []
  @transactions.each do |transaction|
    # 将块的返回值 push 到数组中
    formatted_transactions << yield(transaction)
  end

  p formatted_transactions
end

transaction_statement do |transaction|
  # 改变交易数额的格式
  # 利用格式化字符串，表示在 transaction 中应该插入一个浮点数
  # 其中 0.2 表示精度，不足 2 位则用 0 补齐
  "%0.2f" % transaction
end
#=> ["10.00", "-15.00", "25.00", "30.00", "-24.00", "-70.00", "999.00"]
```

#### 格式化字符串

格式化字符串是一种非常方便的字符串处理方式，在处理数字和其他数据类型时非常有用。要使用格式化字符串，只需要将占位符和实际值用%符号连接起来即可。

- %d表示整数的占位符，可以被实际的整数替换
- %f表示浮点数的占位符，可以被实际的浮点数替换；%.2f表示保留两位小数的浮点数的占位符，可以被实际的浮点数替换
- %s表示字符串的占位符，可以被实际的字符串替换



block对参数的有无或者个数的限制不是很严格

```ruby
def mad_libs
  yield('cool', 'beans', 'burrito')
  yield 
end

mad_libs do |adjective, noun|
  puts "I said #{adjective} #{noun}!"
end
#=> I said cool beans!
#=> I said  !
```

## 6.2 块的控制

使用 `block_given?`

```ruby
def maybe_block
  if block_given?
    puts "block party"
  end
  puts "executed regardless"
end

maybe_block
# => executed regardless

maybe_block {} # {} is just an empty block
# => block party
# => executed regardless
```

## 6.3 Lambdas

Lambda是一种匿名函数（也称为闭包），它可以像普通函数一样被调用，也可以作为参数传递给其他函数。Lambda通常用于函数式编程和事件驱动编程中，可以帮助我们编写简洁、灵活的代码。

- 简单的Lambda表达式

```ruby
my_lambda = lambda { puts "hello world" }
my_lambda.call # 输出 "hello world"
```

- 带参数的 Lambda 表达式

```ruby
my_lambda = lambda { |x| puts "hello #{x}" }
my_lambda.call("world") # 输出 "hello world"
```

- Lambda表达式作为参数

```ruby
def my_method(my_lambda)
  my_lambda.call
end

my_lambda = lambda { puts "hello world" }
my_method(my_lambda) # 输出 "hello world"
```

- Lambda 表达式定义与调用

```ruby
# 定义可以简写
my_lambda = -> { puts "hello from the other side" }
my_name = ->(name) { puts "hello #{name}" }

# 丰富的调用方式，推荐第一种
my_name.call("tim")
my_name.("tim")
my_name["tim"]
my_name.=== "tim"
```

## 6.4 Procs

Proc 与 Lambda 非常相似，都是用来定义闭包或匿名函数的；可以说，Lambda 实际上是一种特殊的 Proc 对象

- 定义

```ruby
my_proc = Proc.new { puts "hello world" }
my_proc = proc { puts "hello world" }
my_proc.call # 输出 "hello world"
```

- 带参数的 Proc 对象

```ruby
my_proc = Proc.new { |x| puts "hello #{x}" }
```

- Proc 对象作为参数

```ruby
def my_method my_proc
  my_proc.call
end

my_proc = Proc.new { puts "hello world" }
```

- 相同点

  - 都可以定义匿名函数

  - 都支持默认参数

    - ```ruby
      my_proc = Proc.new { |name="bob"| puts name }
      my_lambda = ->(name="r2d2") { puts name }
      ```

  - 都可以作为参数传递给其他函数

  - 都支持 return 

## 6.5 Procs VS Lambda

- 处理函数参数

在处理函数参数的方式上，Proc对象比Lambda对象更宽松。Proc对象在调用时，如果缺少参数，它会将缺少的参数赋值为nil，而Lambda对象则会抛出一个参数不足的异常。

```ruby
a_proc = Proc.new { |a, b| puts "a: #{a} --- b: #{b}" }
a_proc.call("apple")
# => a: apple --- b:

a_lambda = lambda { |a, b| puts "a: #{a} --- b: #{b}" }
a_lambda.call("apple")
# => wrong number of Arguments (given 1, expected 2) (ArgumentError)
```

- 处理 return 关键字

在处理return关键字时，Lambda对象和Proc对象的行为不同。Lambda对象在调用return关键字时，只会从Lambda本身中返回，而不会影响外部的代码。而Proc对象则会从调用Proc对象的方法中返回，可能会影响外部的代码。

```ruby
def test_lambda
  lam = lambda { return }
  lam.call
  puts "This line will be executed."
end

def test_proc
  proc = Proc.new { return }
  proc.call
  puts "This line will not be executed."
end

test_lambda # 输出 "This line will be executed."
test_proc # 不输出任何内容
```

## 6.6 捕获块

Ruby 提供了 & 用于 Block 与 Proc 对象的转换

```ruby
def cool_method(&my_block)
  my_block.call
end
cool_method { puts "cool" }
#=> cool

def cool_method
  yield
end
my_proc = Proc.new { puts "proc party" }
cool_method(&my_proc)
# => proc party
```

## 6.7 实际应用

1. 迭代器：在 Ruby 中，可以使用 Block 来实现各种迭代器，如 each、map、select 等等。这些方法都接收一个块作为参数，并在方法内部调用块来实现相应的功能。例如：

```ruby
[1, 2, 3, 4, 5].each do |num|
  puts num
end
```

2. 钩子方法：在 Ruby 中，可以使用 Proc 和 Lambda 来实现钩子方法，即在程序的某些特定位置调用一些特定的代码。例如：

```ruby
class MyClass
  def initialize(&hook)
    @hook = hook
  end

  def do_something
    @hook.call if @hook
    # ...
  end
end

obj = MyClass.new do
  puts "Hook executed!"
end

obj.do_something
```

3. 延迟执行：在 Ruby 中，可以使用 Proc 和 Lambda 来实现延迟执行的功能，即将一段代码封装成一个对象，并在需要执行的时候再进行调用。例如：

```ruby
def delayed_print(str, delay)
  proc { sleep delay; puts str }
end

job1 = delayed_print("Hello", 2)
job2 = delayed_print("World", 1)

job1.call
job2.call
```

4. 错误处理：在 Ruby 中，可以使用 Lambda 来实现错误处理的功能，即将可能抛出异常的代码封装到一个 Lambda 中，并在调用 Lambda 的时候进行异常处理。例如：

```ruby
def safely_run(&block)
  begin
    block.call
  rescue => e
    puts "Error: #{e.message}"
  end
end

safely_run do
  1 / 0
end
```

5. 面向切面编程（AOP）：在 Ruby 中，可以使用 Proc 和 Lambda 来实现面向切面编程的功能，即在程序的某些特定位置动态插入一些代码，例如日志、性能监控等等。例如：

```ruby
def with_logging(func)
  Proc.new do |*args|
    puts "Calling #{func.name} with args: #{args}"
    result = func.call(*args)
    puts "Result: #{result}"
    result
  end
end

def my_function(x, y)
  x + y
end

logged_function = with_logging(method(:my_function))
logged_function.call(1, 2)
```

6. 回调函数：在 Ruby 中，可以使用 Proc 和 Lambda 来实现回调函数的功能，即在某些事件发生时自动调用一些特定的函数。例如：

```ruby
def do_something(callback)
  result = some_long_running_operation
  callback.call(result)
end

do_something(Proc.new do |result|
  puts "Got result: #{result}"
end))
```

