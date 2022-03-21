# 工具-InjectionIII

> 国外作者John的一个开源项目，年代比较久远了，支持OC、Swift以及Swift和OC混编项目，采取在模拟器(真机不支持)注入方式实现UI热重载，修改完UI直接com+s，不用重新编译运行就能看到UI效果，堪称神器。
github,而且AppStore也有发布。

目前已经更新支持Xcode13和iOS15。

### 食用方法

1. Injection安装
   1. github下载最新release版本，或者AppStore下载安装即可，推荐github下载安装,github更新比AppStore更新快。如果你的项目使用混编OC时，强烈建议使用github的releases版本
2. 安装后，打开InjectionIII,选择Open Project,选择你的项目目录

3. 选择的项目会在OPen Recent中展示，同时保持File Watcher的选项勾选。

4. 项目配置
   1. AppDelegate配置,在didFinishLaunchingWithOptions配置注入
     需要注意，先打开InjectionIII的Resources路径，确认bundle文件的正确路径

OC版本

```swift
#if DEBUG
//iOS
[[NSBundle bundleWithPath:@"/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle"] load];
//同时还支持tvOS和MacOS，配置时只需要在/Applications/InjectionIII.app/Contents/Resources/目录下找到对应的bundle文件,替换路径即可
#endif

Swift版本
#if DEBUG
do{
let injectionBundle = Bundle.init(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle")
if let bundle = injectionBundle{
    try bundle.loadAndReturnError()
}else{
        debugPrint("Injection注入失败,未能检测到Injection")
}

}catch{
    debugPrint("Injection注入失败\(error)")
}
#endif

```

2、此时启动项目，在控制台可以看到，表示注入成功了
如果有多个项目都在使用Injection，需要查看Injection链接路径是否正确，如果不正确，打开Injection菜单-OPen Recent-选择你需要注入的项目即可。

    💉 InjectionIII connected /Users/looha/Desktop/Project_lh/BVGenius/BVGenius.xcworkspace
    💉 Watching files under /Users/looha/Desktop/Project_lh/BVGenius

3、注入页面文件配置
在需要热重载的页面VC中,实现injected方法，把操作UI方法添加到injected中即可
以Swift为例，比如UI操作都在vc的viewDidLoad中,那么就在injected添加viewDidLoad方法即可
如果项目都想使用，直接添加到baseVC即可

```swift
@objc func injected()  {
#if DEBUG

self.viewDidLoad()

#endif
}
```

4、在UI阶段，修改外UI，直接com+s就能看到效果，部分页面可能需要重新进入该页面才能看到效果。
ps：当你的项目使用unowned时，项目都配置完成并没有报错，但是修改完UI，按com+s并没有相应的效果，则删除injected方法，在需要热重载的界面或者(baseVC)添加通知INJECTION_BUNDLE_NOTIFICATION即可
          NotificationCenter.default.addObserver(self, selector:#selector(hotReloadingUI), name: Notification.Name("INJECTION_BUNDLE_NOTIFICATION"), object: nil)

### 项目额外的配置

 1、Build Settings - Swift Compiler-Code Generation
     Compilation Mode - Debug模式改为 Incremental
     Optimization Level - Debug模式改为 No Optimization [-Onone]
 2、不支持Swift的SWIFT_WHOLE_MODULE_OPTIMIZATION 模式，需要在关闭它
     User-Defined -
     SWIFT_WHOLE_MODULE_OPTIMIZATION Debug模式改为NO

 3、如果想对final方法和structs方法热重载，在Build Settings - Other Linker Flags中加入 -Xlinker，-interposable
    项目编译报错：Can't find ordinal for imported symbol for architecture x86_64
    增加 -undefined，dynamic_lookup即可

4、如果你的方法有默认参数，而报以下错误时，重新启动App即可

```dart

💉 *** dlopen() error: dlopen(/var/folders/nh/gqmp6jxn4tn2tyhwqdcwcpkc0000gn/T/com.johnholdsworth.InjectionIII/eval101.dylib, 2): Symbol not found: _$s13TestInjection15QTNavigationRowC4text10detailText4icon6object13customization6action21accessoryButtonActionACyxGSS_AA08QTDetailG0OAA6QTIconOSgypSgySo15UITableViewCellC_AA5QTRow_AA0T5StyleptcSgyAaT_pcSgAWtcfcfA1_
 Referenced from: /var/folders/nh/gqmp6jxn4tn2tyhwqdcwcpkc0000gn/T/com.johnholdsworth.InjectionIII/eval101.dylib
 Expected in: flat namespace
in /var/folders/nh/gqmp6jxn4tn2tyhwqdcwcpkc0000gn/T/com.johnholdsworth.InjectionIII/eval101.dylib ***

```

# Ref

* [iOS热重载 Injection](https://juejin.cn/post/6990285526901522463)
* [InjectionIII](https://github.com/johnno1962/InjectionIII)