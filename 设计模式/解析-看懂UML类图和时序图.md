# 看懂UML类图和时序图

[看懂UML类图和时序图](https://design-patterns.readthedocs.io/zh_CN/latest/read_uml.html#uml "永久链接至标题")

这里不会将UML的各种元素都提到，我只想讲讲类图中各个类之间的关系； 能看懂类图中各个类之间的线条、箭头代表什么意思后，也就足够应对 日常的工作和交流； 同时，我们应该能将类图所表达的含义和最终的代码对应起来； 有了这些知识，看后面章节的设计模式结构图就没有什么问题了；

本章所有图形使用Enterprise Architect 9.2来画,所有示例详见根目录下的design_patterns.EAP

## 从一个示例开始[](https://design-patterns.readthedocs.io/zh_CN/latest/read_uml.html#id1 "永久链接至标题")

请看以下这个类图，类之间的关系是我们需要关注的：

![_images/uml_class_struct.jpg](https://design-patterns.readthedocs.io/zh_CN/latest/_images/uml_class_struct.jpg)

*   车的类图结构为<<abstract>>，表示车是一个抽象类；
*   它有两个继承类：小汽车和自行车；它们之间的关系为实现关系，使用带空心箭头的虚线表示；
*   小汽车为与SUV之间也是继承关系，它们之间的关系为泛化关系，使用带空心箭头的实线表示；
*   小汽车与发动机之间是组合关系，使用带实心箭头的实线表示；
*   学生与班级之间是聚合关系，使用带空心箭头的实线表示；
*   学生与身份证之间为关联关系，使用一根实线表示；
*   学生上学需要用到自行车，与自行车是一种依赖关系，使用带箭头的虚线表示；

下面我们将介绍这六种关系；

* * *

管理主要是关联关系的细化需要注意强弱，由若到强分别是 依赖 < 关联 < 聚合 < 组合

## 类之间的关系[](https://design-patterns.readthedocs.io/zh_CN/latest/read_uml.html#id2 "永久链接至标题")

### 泛化关系(generalization)[](https://design-patterns.readthedocs.io/zh_CN/latest/read_uml.html#generalization "永久链接至标题")

类的继承结构表现在UML中为：泛化(generalize)与实现(realize)：

继承关系为 is-a的关系；两个对象之间如果可以用 is-a 来表示，就是继承关系：（..是..)

eg：自行车是车、猫是动物
泛化（generalization）关系时指一个类（子类、子接口）继承另外一个类（称为父类、父接口）的功能，并可以增加它自己新功能的能力，继承是类与类或者接口与接口最常见的关系，在Java中通过关键字extends来表示。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20200420201814.png)

泛化关系用一条带空心箭头的直接表示；如下图表示（A继承自B）；

![_images/uml_generalization.jpg](https://design-patterns.readthedocs.io/zh_CN/latest/_images/uml_generalization.jpg)

eg：汽车在现实中有实现，可用汽车定义具体的对象；汽车与SUV之间为泛化关系；

![_images/uml_generalize.jpg](https://design-patterns.readthedocs.io/zh_CN/latest/_images/uml_generalize.jpg)

注：最终代码中，泛化关系表现为继承非抽象类；

### 实现关系(realize)[](https://design-patterns.readthedocs.io/zh_CN/latest/read_uml.html#realize "永久链接至标题")
实现（realization）是指一个class实现interface接口（一个或者多个），表示类具备了某种能力，实现是类与接口中最常见的关系，在Java中通过implements关键字来表示。
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20200420201800.png)

实现关系用一条带空心箭头的虚线表示；

eg：”车”为一个抽象概念，在现实中并无法直接用来定义对象；只有指明具体的子类(汽车还是自行车)，才 可以用来定义对象（”车”这个类在C++中用抽象类表示，在JAVA中有接口这个概念，更容易理解）

![_images/uml_realize.jpg](https://design-patterns.readthedocs.io/zh_CN/latest/_images/uml_realize.jpg)

注：最终代码中，实现关系表现为继承抽象类；

### 聚合关系(aggregation)[](https://design-patterns.readthedocs.io/zh_CN/latest/read_uml.html#aggregation "永久链接至标题")

聚合（aggregation）是关联关系的特例，是强的关联关系，聚合是整个与个体的关系，即has-a关系，此时整体和部分是可以分离的，他们具有各自的生命周期，部分可以属于多个对象，也可以被多个对象共享；比如计算机和CPU，公司与员工的关系；在代码层面聚合与关联是一致的，只能从语义上来区分。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20200420202820.png)

聚合关系用一条带空心菱形箭头的直线表示，如下图表示A聚合到B上，或者说B由A组成；

![_images/uml_aggregation.jpg](https://design-patterns.readthedocs.io/zh_CN/latest/_images/uml_aggregation.jpg)

聚合关系用于表示实体对象之间的关系，表示整体由部分构成的语义；例如一个部门由多个员工组成；

与组合关系不同的是，整体和部分不是强依赖的，即使整体不存在了，部分仍然存在；例如， 部门撤销了，人员不会消失，他们依然存在；

### 组合关系(composition)[](https://design-patterns.readthedocs.io/zh_CN/latest/read_uml.html#composition "永久链接至标题")


组合（compostion）也是关联关系的一种特例，体现的是一种contain-a关系，比聚合更强，是一种强聚合关系。它同样体现整体与部分的关系，但此时整体与部分是不可分的，整体生命周期的结束也意味着部分生命周期的结束，反之亦然。如大脑和人类。
组合与聚合几乎完全相同，唯一区别就是对于组合，“部分”不同脱离“整体”单独存在，其生命周期应该是一致的。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20200420202944.png)

组合关系用一条带实心菱形箭头直线表示，如下图表示A组成B，或者B由A组成；

![_images/uml_composition.jpg](https://design-patterns.readthedocs.io/zh_CN/latest/_images/uml_composition.jpg)

与聚合关系一样，组合关系同样表示整体由部分构成的语义；比如公司由多个部门组成；

但组合关系是一种强依赖的特殊聚合关系，如果整体不存在了，则部分也不存在了；例如， 公司不存在了，部门也将不存在了；

### 关联关系(association)[](https://design-patterns.readthedocs.io/zh_CN/latest/read_uml.html#association "永久链接至标题")
*(has a)*

关联（association）关系表示类与类之间的连接，它使得一个类知道另外一个类的属性和方法。

关联可以使用单箭头表示单向关联，使用双箭头或者不适用箭头表示双向关联，不建议使用双向关联，关联有两个端点，每个端点可以有一个基数，表示这个关联的类可以有几个实例。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20200420202744.png)

关联关系是用一条直线表示的；它描述不同类的对象之间的结构关系；它是一种静态关系， 通常与运行状态无关，一般由常识等因素决定的；它一般用来定义对象之间静态的、天然的结构； 所以，关联关系是一种“强关联”的关系；

比如，乘车人和车票之间就是一种关联关系；学生和学校就是一种关联关系；

关联关系默认不强调方向，表示对象间相互知道；如果特别强调方向，如下图，表示A知道B，但 B不知道A；

![_images/uml_association.jpg](https://design-patterns.readthedocs.io/zh_CN/latest/_images/uml_association.jpg)

注：在最终代码中，关联对象通常是以成员变量的形式实现的；

### 依赖关系(dependency)[](https://design-patterns.readthedocs.io/zh_CN/latest/read_uml.html#dependency "永久链接至标题")

*(use a)*

依赖（dependency）关系也是表示类与类之间的连接，表示一个类依赖于另外一个类的定义，依赖关系时是单向的。简单理解就是类A使用到了类B，这种依赖具有偶然性、临时性，是非常弱的关系。但是类B的变化会影响到类A。举个例子，如某人要过河，则人与船的关系就是依赖，人过河之后，与船的关系就解除了，因此是一种弱的连接。在代码层面，为类B作为参数被类A在某个方法中使用。

依赖关系是用一套带箭头的虚线表示的；如下图表示A依赖于B；他描述一个对象在运行期间会用到另一个对象的关系；
依赖表现为：局部变量，方法中的参数和对静态方法的调用。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20200420202254.png)

![_images/uml_dependency.jpg](https://design-patterns.readthedocs.io/zh_CN/latest/_images/uml_dependency.jpg)

与关联关系不同的是，它是一种临时性的关系，通常在运行期间产生，并且随着运行时的变化； 依赖关系也可能发生变化；

显然，依赖也有方向，双向依赖是一种非常糟糕的结构，我们总是应该保持单向依赖，杜绝双向依赖的产生；

注：在最终代码中，依赖关系体现为类构造方法及类方法的传入参数，箭头的指向为调用关系；依赖关系除了临时知道对方外，还是“使用”对方的方法和属性；


## 建壮性

一个软件可以正确地运行在不同环境下，则认为软件可移植性高，也可以叫，软件在不同平台下是健壮的。

## 工具

墙裂推荐 [PlantUML](https://plantuml.com/zh/class-diagram)

## 参考

1. [看懂UML类图和时序图 — Graphic Design Patterns](https://design-patterns.readthedocs.io/zh_CN/latest/read_uml.html)
2. [UML基本表示法](https://www.w3cschool.cn/uml_tutorial/uml_tutorial-5y1i28pl.html)