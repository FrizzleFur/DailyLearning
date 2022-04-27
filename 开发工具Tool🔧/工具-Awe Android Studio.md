# 工具-Awe Android Studio

## 自定义内存

跑Dart经常发现AS的内存不够，可以自定义下

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220427105711.png)




路径

```dart
 /Applications/Android\ Studio.app/Contents/bin/studio.vmoptions
```

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220427110032.png)


参考VM option配置

```dart
-Xms856m
-Xmx4280m
-XX:ReservedCodeCacheSize=1512m
-XX:+UseG1GC
-XX:SoftRefLRUPolicyMSPerMB=200
-XX:CICompilerCount=8
-Dsun.io.useCanonCaches=false
-Djdk.http.auth.tunneling.disabledSchemes=""
-Djdk.attach.allowAttachSelf=true
-Djdk.module.illegalAccess.silent=true
-Dkotlinx.coroutines.debug=off
-Djna.nosys=true
-Djna.boot.library.path=
-Didea.vendor.name=Google

-XX:ErrorFile=$USER_HOME/java_error_in_studio_%p.log
-XX:HeapDumpPath=$USER_HOME/java_error_in_studio.hprof

```


# Ref

* [memory management - Android Studio - How to increase Allocated Heap Size - Stack Overflow](https://stackoverflow.com/questions/18723755/android-studio-how-to-increase-allocated-heap-size)
