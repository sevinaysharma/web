---
title: Android 三方 SDK 类名冲突的解决方法
date: 2021-02-18 18:47:07
tags:
 - 类冲突
categories:
 - Android
---

# 原因

三方提供的 SDK 一般都会进行混淆。混淆的过程是根据一个名称字典按照一定规则生成新的包名、类名、方法名。因为各自混淆时上下文完全隔离，就会导致混淆后某些类冲突。

# 处理

这种情况一般分为两种，一种是有源代码的库和没有源代码的库冲突，另一种是冲突的库都没有源代码。

## 有源代码

有源代码时，可以通过指定混淆词典的方式来避免冲突。冲突的一个原因就是大家都使用了默认的混淆词典。此时通过指定自定义的混淆词典就可以解决这个问题。

具体方法是，在该 module 的 `proguard-rules.pro` 中指定自定义的词典，如下所示

```
-obfuscationdictionary filename.txt
-classobfuscationdictionary filename.txt
-packageobfuscationdictionary filename.txt
```

`filename.txt` 就是自定义的词典文件。字典文件中的空格，标点符号，重复的词，还有以'#'开头的行都会被忽略。下面是一个参考案例

```
# 使用java中的关键字作字典：避免混淆后与其他包重名，而且混淆之后的代码更加不利于阅读
#
# This obfuscation dictionary contains reserved Java keywords. They can't
# be used in Java source files, but they can be used in compiled class files.
# Note that this hardly improves the obfuscation. Decent decompilers can
# automatically replace reserved keywords, and the effect can fairly simply be
# undone by obfuscating again with simpler names.
# Usage:
#     java -jar proguard.jar ..... -obfuscationdictionary filename.txt
#

do
if
for
int
new
try
byte
case
char
else
goto
long
this
void
break
catch
class
const
final
float
short
super
throw
while
double
import
native
public
return
static
switch
throws
boolean
default
extends
finally
package
private
abstract
continue
strictfp
volatile
interface
protected
transient
implements
instanceof
synchronized
```

### 参考资料

关于 Proguard 的更多资料可以参考 [http://proguard.sourceforge.net/](http://proguard.sourceforge.net/) 和 [https://bbs.huaweicloud.com/blogs/218907](https://bbs.huaweicloud.com/blogs/218907)

## 没有源代码

没有源代码时修改就比较麻烦，涉及到 AAR 和 JAR 的编译和反编译。涉及到的工具有 ApkTool、dex2jar、JD-GUI、unzip 和 jarjar-1.4.jar。

具体思路为：把 AAR 或者 JAR 解压，使用 **jarjar-1.4.jar** 把冲突的类放到一个自定义的 package 下面，然后修改引用这个类的 `import`，最后把修改的 `.class` 文件和之前的文件重新打包为 AAR 或者 JAR，工程中引用这个修改过的 SDK 就可以了。

### 参考资料

[Android修改第三方.aar后重新打包](https://www.jianshu.com/p/f0a267551493)