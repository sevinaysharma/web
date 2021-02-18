---
title: [转]Android Studio如何做混淆
date: 2021-02-18 20:52:50
tags:
 - 混淆
 - proguard
categories:
 - Android
---

> [原文地址](https://bbs.huaweicloud.com/blogs/218907)

# 概述

ProGuard 是一个 Java 类文件压缩器、优化器、混淆器、预校验器：
* 压缩阶段会检测和移除未使用的类、字段、方法、属性。ProGuard 以递归的方式检查并决定哪些类和类成员是被用到的，而其他没有用到的类和类成员就会被丢弃。
* 优化阶段会分析并优化方法的字节码。ProGuard 会进一步优化代码。其他优化包括不是入口点的类或方法可能会变成 private、final、static，而没有使用的参数可能会被移除等。
* 混淆阶段会用简短的无意义的名称来重命名剩下的类名、字段名、方法名。ProGuard 会重命名那些不是入口点(说白了入口点就是公开的，public 的）的类和类成员，会保留那些入口点（public 的），保证他们能够正确地访问。

进行完以上三个段后，我们的apk包会更小、更高效，并且更难进行反向工程。

预校验阶段会将预验证信息添加到类中，这是 Java Micro Edition 所必需的，或者可以缩短 Java 6 的启动时间。只有这一阶段不需要知道入口点的。

![1](1.png)

ProGuard 读取 Jar 包（或者是 wars、ears、zips 或者目录。然后开始压缩资源、优化代码、混淆代码和预校验它们。

前面这四个步骤都是可选的。

# proguard-rules.pro文件配置

为了决定哪些代码要保留、哪些代码要丢弃或混淆，我们必须在配置文件中指明。proguard-rules.pro文件可以配置的选项

## 输入输出选项

```
-include {filename} 从给定的文件中递归读取配置选项
@filename  '-include filename'的简写
-basedirectory {directoryname} 指定为这些配置参数或配置文件中的相对文件提供基础目录
-injars {class_path} 指定要处理的应用程序的jar,war,ear和目录
-outjars {class_path} 指定处理完后要输出的jar,war,ear和目录的名称，我们应该避免输出的文件重写输入文件，不使用这个选项的话就可以做到，就不会有任何jar包被重写。
-libraryjars {classpath} 指定要处理的应用程序jar,war,ear和目录所需要的程序库文件，这里的文件就不会被包含进输入jars中。
-dontskipnonpubliclibraryclasses 指定跳过非公共类当读取库jar包时，加速处理和减少ProGuard的内存使用。默认情况下，ProGuard会读取非公共和公共库类文件。
-dontskipnonpubliclibraryclassmembers 指定不去忽略包可见的库类的成员。
-skipnonpubliclibraryclasses 指定路过的非public类，当读库文件，加速处理和减少ProGuard的内存占用。默认情况ProGuard读取非public和public库文件。但是有些库包含了扩展自public库类的非public库类，如果使用了此选项就会报错，所以建议不要使用此选项。
-keepdirectories [directory_filter]指定要在输出jars文件中保留的目录。默认情况下，目录入口都会被移除，可以减少jar包的大小。如果不加过滤目录，只指定了这个选项，则全部目录都会被保留，否则只保留过滤目录。
-target version 指定版本号，用于设置被处理好的类文件。默认，类文件的版本号设置后不会再变，如果要更新类文件，就可以改变这个版本号，就会去校验它。
-forceprocessing 指定处理输入，即使输出已经是最新的了。更新的检测是基于对比指定的输入文件、输出文件、配置文件或目录的时间戳。
```

## 压缩选项

```
-dontshrink 关闭压缩。默认开启，处理时会移除除用-keep保留（间接或直接依赖的都会被保留）的之外未被使用的类和类成员，并且会在优化阶段再次执行，因为优化后可能会再次暴露出一些未被使用的类和成员。
-printusage {filename} 将输入类文件中没有用的代码列出来，并打印到标准输出或给定的文件中
-whyareyoukeeping {class_specification} 给出为什么在压缩步骤要保留某些类和类成员的理由，当你想知道某个给定的元素为什么会在输出中时，就可以查看这个理由。这个选项只在压缩阶段有效。
```

## 保留选项

```
-keep {Modifier} {class_specification} 指定要保留的类文件和类的成员
-keepclassmembers {modifier} {class_specification} 指定要保留的类成员，如果此类也保留会更好
-keepclasseswithmembers {class_specification} 保留指定的类和类的成员，但条件是所有指定的类和类成员是要存在。
-keepnames {class_specification}  保留指定的类和类的成员的名称，如果他们在压缩步骤中，不会被删除。这是 -keep,allowshrinking class_specification的简写。例如你要保留所有实现了Serializable接口的类名。在混淆时起作用。
-keepclassmembernames {class_specification} 保留指定的类的成员的名称，如果他们不会被删除，在压缩步骤中。这是-keepclassmembers,allowshrinking class_specification的简写。在混淆时起作用。
-keepclasseswithmembernames {class_specification} 保留指定的类和类成员的名称，前提是在压缩步骤，这些类和类成员都还存在。这是-keepclasseswithmembers,allowshrinking class_specification的简写。
-printseeds {filename} 列出-keep选项的清单的类和类成员，将打印到标准输出或输出到给定的文件。这将会非常有用，可以用于验证已扩展的类成员是否能找到，尤其是用了通配符的情况下。如，可以例出所有你保留的，不用混淆的类和类成员。
```

## 优化选项

```
-dontoptimize 关闭优化。默认开启，所有方法都会在字节码级别执行优化，让应用运行的更快。
-optimizationpasses n 指定优化次数。默认，一次。
-assumenosideeffects {class_specification} 指定没有副作用的方法（除了可能会返回值的）。在优化阶段，ProGuard会删除对这类方法的调用，如果返回值没有被使用。ProGuard会分析你的代码，会自动查找这一类的方法。ProGuard不会去分析库代码，正因如此，这个选项还是很有用的。
-allowaccessmodification 指定在处理期间可以扩展类和类成员的访问修饰符 
-mergeinterfacesaggressively 可以合并接口，当它们的实现类没有实现所有接口方法时。这可以减少输出文件的大小从而减少类的总数。
```

## 混淆选项

```
-dontobfuscate 关闭混淆。默认开启，增大反编译难度，类和类成员会被随机命名，除非用keep保护。
-printmapping {filename} 指定输出类的新名称与旧名称和改名后的类成员。可以输出到标准输出或指定的文件。
-applymapping {filename} 重用-printmapping输出的映射，用于进行增量式混淆
-obfuscationdictionary {filename} 使用给定文件中的关键字作为要混淆方法能和字段的名称，默认情况下是使用像'a', 'b'等这样的短名称。
-classobfuscationdictionary filename 指定包含合法的用于混淆后的类的名称的字符集合的文本文件。
-packageobfuscationdictionary filename 通过文本文件指定合法的包名。
-overloadaggressively 混淆时允许多个字段和方法可以得到相同的名称，只要它们的参数和返回类型不同（不仅仅是它们的参数）。这可以让程序代码更小。
-useuniqueclassmembernames 分配相同的混淆名称给有相同名称的类成员。确定统一的混淆类的成员名称来增加混淆。
-flattenpackagehierarchy {package_name} 重新包装所有重命名的包并放在给定的单一包中
-repackageclass {package_name} 重新包装所有重命名的类文件中放在给定的单一包中
-repackageclasses [package_name] 重新包装所有已重命名的类文件，并将它们移动入给定的单一包中。
-dontusemixedcaseclassnames 混淆时不产生混合大小写的类名。默认情况下会。
-keeppackagenames [package_filter] 不混淆给定的包名  
-keepattributes {attribute_name,...} 保留给定的可选属性，例如Exceptions, Signature, Deprecated, SourceFile, SourceDir, LineNumberTable, LocalVariableTable, LocalVariableTypeTable, Synthetic, EnclosingMethod, RuntimeVisibleAnnotations, RuntimeInvisibleAnnotations, RuntimeVisibleParameterAnnotations, RuntimeInvisibleParameterAnnotations, and AnnotationDefault，InnerClasses
-keepparameternames 保留参数名和方法类型。
-renamesourcefileattribute {string} 设置源文件中给定的字符串常量
```

## 预验证选项

```
-dontpreverify 关闭验证，默认是开启的。
-microedition 指定被处理的类文件对应的Java Micro Edition。
```

## 通用选项

```
-verbose 在处理期间，写出更多的的信息，如果遇到异常终止了，这个选项将打印出所有栈跟踪的信息。
-dontnote [class_filter] 不打印有关配置中潜在错误或遗漏的注释
-dontwarn [class_filter] 不警告未解决的引用和其他重要的问题
-ignorewarnings 打印有关未解决的引用和其他重要问题的任何警告
-printconfiguration [filename] 用包含的文件和替换的变量写出已分析的整个配置
-dump [filename] 写出类文件的内部结构
```

# 执行ProGuard后会生成的文件

* dump.txt 描述apk文件里的所以类的内部结构
* mapping.txt 列出了原始的和混淆后的类、方法和属性的对应关系
* seeds.txt 列出了没有被混淆的类和属性
* usage.txt 列出了没有被打到apk文件中的代码

# 使用 ProGuard 工具处理 jar

```
/Android SDK Path/tools/proguard/bin/proguard.sh @config.file –options …
```