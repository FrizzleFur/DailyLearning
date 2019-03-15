# 解析-YYModel

YYModel 是一个iOS JSON模型转化库，和其他一些同类型库相比，具有比较好的性能优势。本文会对YYModel的源码进行分析，具体用法作者ibireme在github中有提及。YYModel的目录结构很简单，只有两个类, NSObject+YYModel 和 YYClassInfo。YYClassInfo主要对根类NSObject 的 Ivar , Method, Property以及Class本身进行了封装，NSObject+YYModel 是 NSObject的分类，扩展了一些JSON模型转化的方法。

* YYClassIvarInfo : 对 Class的Ivar进行了封装
* YYClassMethodInfo : 对 Class的Method进行了封装
* YYClassPropertyInfo : 对 Class的Property进行了封装
* YYClassInfo : 对Class进行了封装，包含了YYClassIvarInfo，YYClassMethodInfo，YYClassPropertyInfo




## YYModel 继承

[继承的类怎么解析，急，在线等 · Issue #80 · ibireme/YYModel](https://github.com/ibireme/YYModel/issues/80)

我觉得找个问题可以把原来的类作为现在Model的一个属性~



## 参考

1. [YYModel源码分析 | 夜空中最亮的星](https://chenao0727.github.io/2017/01/03/YYModel/)
