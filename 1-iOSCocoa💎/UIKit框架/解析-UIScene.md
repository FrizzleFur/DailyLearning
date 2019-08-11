## UIScene

> 基本上来说，一个 UIScene 中会包含 UI，scene 会由系统按需创建，同样也会在未被使用时由系统销毁。而一个 UISceneSession 中则会包含持久化的用户界面状态。每次创建一个新窗口时，应用会在 Application Delegate 中收到通知，有一个新的 session 被创建了。当窗口被关闭时，同样也会收到 session 被销毁的通知


* UIScene<UISceneDelegate>:UIResponder  display App's UI,
    * 持有一个只读`UISceneSession`属性
* UISceneSession：NSObject, 对`UIScene`进行管理
    * 持有一个只读的`UIScene`,    
    * 持有一个只读的`UISceneConfiguration`
    * 持有一个只读的`NSUserActivity`stateRestorationActivity
    * 持有一个的userInfo: NSDictionary
* NSUserActivity
    * NSUserActivity对象提供了一种轻量级方法来捕获应用程序的状态并将其稍后使用。
    * 您可以创建用户活动对象并使用它们捕获有关用户正在执行的操作的信息，例如查看应用程序内容，编辑文档，查看网页或观看视频。当系统启动您的应用程序并且活动对象可用时，您的应用程序可以使用该对象中的信息将自身恢复到适当的状态。
    * userInfo: NSDictionary
* UIWindow: UIView, 
    * 弱引用一个`UIWindowScene`，持有一个`UIScreen`
* UIApplication
    * 能够将 App 中已经存在的 scene 激活带到前台，或是创建新的 scene
    * UIApplication.shared.requestSceneSessionActivation(existingSession, userActivity: nil, options: nil)

## 持久化


> UISceneSession 旨在帮助我们进行状态恢复。如果 App 在之前已经用到了 handoff 之类的技术，那么可以直接利用其中的 stateRestorationUserActivity: NSUserActivity，但如果 App 已经存在了自己实现的状态恢复相关的逻辑代码，不想使用 NSUserActivity 相关的 API，则可以利用 Apple 在 UISceneSession 中提供的 persistentIdentifier: String，将其关联保存到数据库或文件中帮助我们去处理状态恢复的问题。同一个 scene 的 persistentIdentifier 会始终保持一致，甚至是在设备进行了备份和恢复操作之后也是一样。同时，UISceneSession 中还有一个 userInfo: [String:AnyHashable] 属性可以帮助我们记录一些不想全局存储的小状态，比如侧边栏是否已经被显示出来了，又或是用户上一次选择的墨水是什么颜色等。



## 参考

* [iPad 上的多窗口 － 小专栏](https://xiaozhuanlan.com/topic/0342159876)
