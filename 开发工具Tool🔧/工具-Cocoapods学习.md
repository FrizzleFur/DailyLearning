
# CocoaPods 解析

> CocoaPods是用Ruby构建的，它可以使用macOS上的默认Ruby进行安装。您可以使用Ruby版本管理器，但我们建议您使用macOS上提供的标准Ruby，除非您知道自己在做什么。
> * [ObjC 中国 - 深入理解 CocoaPods](https://objccn.io/issue-6-4/)
> * [1. 版本管理工具及 Ruby 工具链环境](https://mp.weixin.qq.com/s?__biz=MzA5MTM1NTc2Ng==&mid=2458322728&idx=1&sn=3a16de4b2adae7c57bbfce45858dfe06&chksm=870e0831b0798127994902655fdee3be7d6abd53734428dd8252b8f584343aad217e77a70920&scene=178&cur_album_id=1477103239887142918#rd)
> * [Cocoapods文档](https://rubydoc.info/gems/cocoapods/Pod/Podfile)


软件工程中，版本控制系统是敏捷开发的重要一环，为后续的持续集成提供了保障。Source Code Manager (SCM) 源码管理就属于 VCS 的范围之中，熟知的工具有如 Git 。而 CocoaPods 这种针对各种语言所提供的 Package Manger (PM)也可以看作是 SCM 的一种。

而像 Git 或 SVN 是针对项目的单个文件的进行版本控制，而 PM 则是以每个独立的 Package 作为最小的管理单元。包管理工具都是结合 SCM 来完成管理工作，对于被 PM 接管的依赖库的文件，通常会在 Git 的 .ignore 文件中选择忽略它们。

例如：在 Node 项目中一般会把 node_modules 目录下的文件 ignore 掉，在 iOS / macOS 项目则是 Pods。

## Package Manager

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220514103735.png)

从 👆 可见，PM 工具基本围绕这个两个文件来现实包管理：

描述文件：声明了项目中存在哪些依赖，版本限制；
锁存文件（Lock 文件）：记录了依赖包最后一次更新时的全版本列表。


## CocoaPods

CocoaPods  是开发 iOS/macOS 应用程序的一个第三方库的依赖管理工具。 利用 CocoaPods，可以定义自己的依赖关系（简称 Pods），以及在整个开发环境中对第三方库的版本管理非常方便。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220514103918.png)

* Podfile
Podfile 是一个文件，以 DSL（其实直接用了 Ruby 的语法）来描述依赖关系，用于定义项目所需要使用的第三方库。该文件支持高度定制，你可以根据个人喜好对其做出定制。更多相关信息，请查阅 [Podfile 指南](https://guides.cocoapods.org/syntax/podfile.html#podfile)。

* Podfile.lock
这是 CocoaPods 创建的最重要的文件之一。它记录了需要被安装的 Pod 的每个已安装的版本。如果你想知道已安装的 Pod 是哪个版本，可以查看这个文件。推荐将 Podfile.lock 文件加入到版本控制中，这有助于整个团队的一致性。

* Manifest.lock
这是每次运行 pod install 命令时创建的 Podfile.lock 文件的副本。如果你遇见过这样的错误 沙盒文件与 Podfile.lock 文件不同步 (The sandbox is not in sync with the Podfile.lock)，这是因为 Manifest.lock 文件和 Podfile.lock 文件不一致所引起。由于 Pods 所在的目录并不总在版本控制之下，这样可以保证开发者运行 App 之前都能更新他们的 Pods，否则 App 可能会 crash，或者在一些不太明显的地方编译失败。


### Ruby 生态及工具链
对于一部分仅接触过 CocoaPods 的同学，其 PM 可能并不熟悉。其实 CocoaPods 的思想借鉴了其他语言的 PM 工具，例：`RubyGems`[7], `Bundler`[8], `npm`[9] 和 `Gradle`[10]。

我们知道 CocoaPods 是通过 Ruby 语言实现的。**它本身就是一个 Gem 包**。理解了 Ruby 的依赖管理有助于我们更好的管理不同版本的 CocoaPods 和其他 Gem。同时能够保证团队中的所有同事的工具是在同一个版本，这也算是敏捷开发的保证吧。

* [Why rbenv](https://github.com/rbenv/rbenv/wiki/Why-rbenv%3F)

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220514104914.png)

### RubyGems

RubyGems 是 Ruby 的一个包管理工具，这里面管理着用 Ruby 编写的工具或依赖我们称之为 Gem。
并且 RubyGems 还提供了 Ruby 组件的托管服务，可以集中式的查找和安装 library 和 apps。当我们使用 gem install xxx 时，会通过 rubygems.org 来查询对应的 Gem Package。而 iOS 日常中的很多工具都是 Gem 提供的，例：Bundler，fastlane，jazzy，CocoaPods 等。

在默认情况下 Gems 总是下载 library 的最新版本，这无法确保所安装的 library 版本符合我们预期。因此我们还缺一个工具。

### Bundler

Bundler 是管理 Gem 依赖的工具，**可以隔离不同项目中 Gem 的版本和依赖环境的差异，也是一个 Gem**。
Bundler 通过读取项目中的依赖描述文件 Gemfile ，来确定各个 Gems 的版本号或者范围，来提供了稳定的应用环境。当我们使用 bundle install 它会生成 Gemfile.lock 将当前 librarys 使用的具体版本号写入其中。之后，他人再通过 bundle install 来安装 library 时则会读取 Gemfile.lock 中的 librarys、版本信息等。

Gemfile
可以说 CocoaPods 其实是 iOS 版的 RubyGems + Bundler 组合。Bundler 依据项目中的 Gemfile 文件来管理 Gem，而 CocoaPods 通过 Podfile 来管理 Pod。

Gemfile 配置如下：

```dart
source 'https://gems.example.com' do
  gem 'cocoapods', '1.8.4'是管理 Gem 依赖的工具
  gem 'another_gem', :git => 'https://looseyi.github.io.git', :branch => 'master'
end
```

可见，Podfile 的 DSL 写法和 Gemfile 如出一辙


### 如何安装一套可管控的 Ruby 工具链？
讲完了这些工具的分工，然后来说说实际的运用。我们可以使用 homebrew + rbenv + RubyGems + Bundler 这一整套工具链来控制一个工程中 Ruby 工具的版本依赖。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220514105634.png)




![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220514110050.png)


### 如何使用 Bundler 管理工程中的 Gem 环境

下面我们来实践一下，如何使用 Bundler 来锁定项目中的 Gem 环境，从而让整个团队统一 Gem 环境中的所有 Ruby 工具版本。从而避免文件冲突和不必要的错误。

下面是在工程中对于 Gem 环境的层级图，我们可以在项目中增加一个 Gemfile 描述，从而锁定当前项目中的 Gem 依赖环境。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220514110139.png)


不使用 bundle exec 执行前缀，则会使用系统环境中的 CocoaPods 版本。如此我们也就验证了工程中的 Gem 环境和系统中的环境可以通过 Bundler 进行隔离。


### 总结
* 通过版本管理工具演进的角度可以看出，CocoaPods 的诞生并非一蹴而就，也是不断地借鉴其他管理工具的优点，一点点的发展起来的。VCS 工具从早期的 SVN、Git，再细分出 Git Submodule，再到各个语言的 Package Manager 也是一直在发展的。
* 虽然 CocoaPods 作为包管理工具控制着 iOS 项目的各种依赖库，但其自身同样遵循着严格的版本控制并不断迭代。希望大家可以从本文中认识到版本管理的重要性。
* 通过实操 Bundler 管理工程的全流程，学习了 Bundler 基础，并学习了如何控制一个项目中的 Gem 版本信息。



### 知识目录

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220514112043.png)

组件构成和对应职责

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220514112416.png)



### CocoaPods 初探

接下来，结合 `pod install` 安装流程来展示各个组件在 `Pods` 工作流中的上下游关系。

##### 命令入口

每当我们输入 `pod xxx` 命令时，系统会首先调用 `pod` 命令。所有的命令都是在 `/bin` 目录下存放的脚本，当然 Ruby 环境的也不例外。我们可以通过 `which pod` 来查看命令所在位置：

```
$ which pod
/Users/edmond/.rvm/gems/ruby-2.6.1/bin/pod
```

> 这里的显示路径不是 /usr/local/bin/pod 的原因是因为使用 RVM 进行版本控制的。


### Pod install

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220514113301.png)

对应的实现如下：

```ruby
def install!
    prepare
    resolve_dependencies
    download_dependencies
    validate_targets
    if installation_options.skip_pods_project_generation?
        show_skip_pods_project_generation_message
    else
        integrate
    end
    write_lockfiles
    perform_post_install_actions
end

def integrate
    generate_pods_project
    if installation_options.integrate_targets?
        integrate_user_project
    else
        UI.section 'Skipping User Project Integration'
    end
end
```

[2. 整体把握 CocoaPods 核心组件](https://mp.weixin.qq.com/s?__biz=MzA5MTM1NTc2Ng==&mid=2458324020&idx=1&sn=5d57193433b93127e3f72865bdc5b173&chksm=870e032db0798a3bab5da470df244a44096fc6a2faeeb1207ae6def6edef7053c766a0f0ceb6&cur_album_id=1477103239887142918&scene=189#0x1%20Install%20%E7%8E%AF%E5%A2%83%E5%87%86%E5%A4%87%EF%BC%88prepare%EF%BC%89)

* 在 prepare 阶段会将 pod install 的环境准备完成，包括版本一致性、目录结构以及将 pre-install 的装载插件脚本全部取出，并执行对应的 pre_install hook。
* 0x2 解决依赖冲突（resolve_dependencies）依赖解析过程就是通过 Podfile、Podfile.lock 以及沙盒中的 manifest 生成 Analyzer 对象。Analyzer 内部会使用 Molinillo （具体的是 Molinillo::DependencyGraph 图算法）解析得到一张依赖关系表。
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220514113825.png)
另外，需要注意的是 analyze 的过程中有一个 pre_download 的阶段，即在 --verbose 下看到的 Fetching external sources 过程。这个 pre_download 阶段不属于依赖下载过程，而是在当前的依赖分析阶段。

* 验证环节
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220514114029.png)
* 0x5 生成工程 (Integrate)
* 0x6 写入依赖 (write_lockfiles)将依赖更新写入 Podfile.lock 和 Manifest.lock
* 0x7 结束回调（perform_post_install_action）
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220514114125.png)





## Ruby 语言

Open Class
开始之前，我们需要了解一个 Ruby 的语言特性：Open Classes

在 Ruby 中，类永远是开放的，你总是可以将新的方法加入到已有的类中，除了在你自己的代码中，还可以用在标准库和内置类中，这个特性被称为 Open Classes。说到这里作为 iOS 工程师，脑中基本能闪现出 Objective-C 的 Category 或者 Swift 的 Extensions 特性。不过，这种动态替换方法的功能也称作 Monkeypatch。(🐒  到底招谁惹谁了）

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220514115318.png)

需要注意，即使是已经创建好的实例，方法替换同样是生效的。另外 ⚠️ Open Class 可以跨文件、跨模块进行访问的，甚至对 Ruby 内置方法的也同样适用 (谨慎)。


## 4. Podfile 的解析逻辑


![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220514115711.png)

### Podfile 的主要数据结构


* Specification
  * Specification 即存储 PodSpec 的内容，是用于描述一个 Pod 库的源代码和资源将如何被打包编译成链接库或 framework，后续将会介绍更多的细节。
* TargetDefinition
  * TargetDefinition 是一个多叉树结构，每个节点记录着 Podfile 中定义的 Pod 的 Source 来源、Build Setting、Pod 子依赖等。
* Lockfile
  * Lockfile，顾名思义是用于记录最后一次 CocoaPods 所安装的 Pod 依赖库版本的信息快照。也就是生成的 Podfile.lock。
  * 在 pod install 过程，Podfile 会结合它来确认最终所安装的 Pod 版本，固定 Pod 依赖库版本防止其自动更新。
  * Lockfile 也作为 Pods 状态清单 (mainfest)，用于记录安装过程的中哪些 Pod 需要被删除或安装或更新等。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220514160752.png)

### Podfile 文件的读取

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220514160843.png)

### Xcode 工程结构


我们先来看一个极简 Podfile 声明：

```swift
target 'Demo' do
 pod 'Alamofire', :path => './Alamofire'
end
```

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220514154819.png)


* Target - 最小可编译单元
  * 首先是 Target，它作为工程中最小的可编译单元，根据 Build Phases[3] 和 Build Settings[4] 将源码作为输入，经编译后输出结果产物。
  * 其输出结果可以是链接库、可执行文件或者资源包等，具体细节如下：
    - Build Setting：比如指定使用的编译器，目标平台、编译参数、头文件搜索路径等；
    - Build 时的前置依赖、执行的脚本文件；
    - Build 生成目标的签名、Capabilities 等属性；
    - Input：哪些源码或者资源文件会被编译打包；
    - Output：哪些静态库、动态库会被链接；
- Project - Targets 的载体
  - Project 就是一个独立的 Xcode 工程，作为一个或多个 Targets 的资源管理器，本身无法被编译。Project 所管理的资源都来自它所包含的 Targets。特点如下：
    - 至少包含一个或多个可编译的 Target；
    - 为所包含的 Targets 定义了一份默认编译选项，如果 Target 有自己的配置，则会覆盖 Project 的预设值；
    - 能将其他 Project 作为依赖嵌入其中；

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220514155042.png)
- Workspace - 容器
  - 作为纯粹的项目容器，Workspace 不参与任何编译链接过程，仅用于管理同层级的 Project，其特点：
    - Workspace 可以包含多个 Projects；
    - 同一个 Workspace 中的 Proejct 文件对于其他 Project 是默认可见的，这些 Projcts 会共享 workspace build directory ；
    - 一个 Xcode Project 可以被包含在多个不同的 Workspace 中，因为每个 Project 都有独立的 Identity，默认是 Project Name；
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220514155345.png)
- Scheme - 描述 Build 过程
  - Scheme 是对于整个 Build 过程的一个抽象，它**描述了 Xcode 应该使用哪种 Build Configurations[5] 、执行什么任务、环境参数等来构建我们所需的 Target**。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220514155542.png)




## 5. Podspec 文件分析

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220514154559.png)

* Podspec
  * Podspec 是用于 描述一个 Pod 库的源代码和资源将如何被打包编译成链接库或 framework 的文件 ，而 Podspec 中的这些描述内容最终将映会映射到 Specification 类中（以下简称 Spec）。

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220514161131.png)


Podspec示例

```swift
Pod::Spec.new do |spec|
  spec.name         = 'Reachability'
  spec.version      = '3.1.0'
  spec.license      = { :type => 'BSD' }
  spec.homepage     = 'https://github.com/tonymillion/Reachability'
  spec.authors      = { 'Tony Million' => 'tonymillion@gmail.com' }
  spec.summary      = 'ARC and GCD Compatible Reachability Class for iOS and OS X.'
  spec.source       = { :git => 'https://github.com/tonymillion/Reachability.git', :tag => "v#{spec.version}" }
  spec.source_files = 'Reachability.{h,m}'
  spec.framework    = 'SystemConfiguration'
end
```
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220514161322.png)

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220514161547.png)

* Subspecs
  * 乍一听 Subspec 这个概念似乎有一些抽象，不过当你理解了上面的描述，就能明白什么是 Subspec 了。我们知道在 Xcode 项目中，target 作为最小的可编译单元，它编译后的产物为链接库或 framework。而在 CocoaPods 的世界里这些 targets 则是由 Spec 文件来描述的，它还能拆分成一个或者多个 Subspec，我们暂且把它称为 Spec 的 子模块，子模块也是用 Specification 类来描述的。
    * 未指定 default_subspec 的情况下，Spec 的全部子模块都将作为依赖被引入；
    - 子模块会主动继承其父节点 Spec 中定义的 attributes_hash；
    - 子模块可以指定自己的源代码、资源文件、编译配置、依赖等；
    - 同一 Spec 内部的子模块是可以有依赖关系的；
    - 每个子模块在 pod push 的时候是需要被 lint 通过的；


## 6. PodSpec 管理策略
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220514162002.png)

* Source
  * 作为 PodSpec 的聚合仓库，Spec Repo 记录着所有 pod 所发布的不同版本的 PodSpec 文件。该仓库对应到 Core 的数据结构为 Source，即为今天的主角。
  * 整个 Source 的结构比较简单，它基本是围绕着 Git 来做文章，主要是对 PodSpec 文件进行各种查找更新操作。


## 7. Molinillo 依赖校验

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220514162208.png)

- 依赖关系的解决
  - 对于依赖过多或者多重依赖问题，我们可通过合理的架构和设计模式来解决。而依赖校验主要解决的问题为：
  - 检查依赖图是否存在版本冲突；
  - 判断依赖图是否存在循环依赖；
  - 版本冲突的解决方案
- 对于版本冲突可通过修改指定版本为带兼容性的版本范围问题来避免。如上面的问题有两个解决方案：
    - 通过修改两个 pod 的 Alamofire 版本约束为 ~> 4.0 来解决。
    - 去除两个 pod 的版本约束，交由项目中的 Podfile 来指定。
  - 不过这样会有一个隐患，由于两个 Pod 使用的主版本不同，可能带来 API 不兼容，导致 pod install 即使成功了，最终也无法编译或运行时报错。
  - 还有一种解决方案，是基于语言特性来进行依赖性隔离。如 npm 的每个传递依赖包如果冲突都可以有自己的 node_modules 依赖目录，即一个依赖库可以存在多个不同版本。

## 8. Xcode 工程文件解析


![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220514162522.png)



![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220514162814.png)

 pbxproj 内 Object 的说明
- PBXProject：Project 的设置，编译工程所需信息
- PBXNativeTarget：Target 的设置
- PBXTargetDependency：Target 依赖
- PBXContainerItemProxy：部署的元素
- XCConfigurationList：构建配置相关，包含 project 和 target 文件
- XCBuildConfiguration：编译配置，对应 Xcode 的 Build Setting 内容
- PBXVariantGroup：国际化对照表或 .storyboard 文件
- PBXBuildFile：各类文件，最终会关联到 PBXFileReference
- PBXFileReference：源码、资源、库，Info.plist 等文件索引
- PBXGroup：虚拟文件夹，可嵌套，记录管理的 PBXFileReference 与子 PBXGroup
- PBXSourcesBuildPhase：编译源文件（.m、.swift）
- PBXFrameworksBuildPhase：用于 framework 的构建
- PBXResourcesBuildPhase：编译资源文件，有 xib、storyboard、plist 以及 xcassets 等资源文件


Xcode 解析工程的是依次检查 *.xcworkspace > *.xcproject > project.pbxproj，根据 project.pbxproj 的数据结构，Xcodeproj 提供了 Project 类，用于记录根元素。
在 pod install 的依赖解析阶段，会读取 project.pbxproj。




## Pod

pod install 和 pod update 区别还是比较大的，每次在执行 pod install 或者 update 时最后都会生成或者修改 Podfile.lock 文件，Podfile.lock会锁定当前各依赖库的版本,。这样多人协作的时候，可以防止第三方库升级时造成大家各自的第三方库版本不一致.其中前者并不会修改 Podfile.lock 中显示指定的版本，**而后者会会无视该文件的内容，尝试将所有的 pod 更新到最新版。
**

## Pod结构

pod将一些配置放在了2个文件中进行管理，podfile和podfile.lock分别担任不同的职责。
podfile:  告诉pod目前工程依赖了哪些库，执行`pod update`命令时去拉去podfile中制定的依赖库，同时更新podfile.lock中各库的版本
podfile.lock  执行`pod install`时会依据当前podfile.lock文件各个库的版本将本地对应版本的各个库安装到`Pod`文件夹中。


## pod版本

一个简单的podfile:
 
pod 'AFNetworking', '~> 1.0' 版本号可以是1.0，可以是1.1，1.9，但必须小于2
 
－个更简单的podfile:
pod 'AFNetworking', '1.0' // 版本号指定为1.0
 
一个更更简单的podfile:
pod 'AFNetworking',  // 不指定版本号，任何版本都可以

Besides no version, or a specific one, it is also possible to use logical operators:

'> 0.1' Any version higher than 0.1 0.1以上
'>= 0.1' Version 0.1 and any higher version 0.1以上，包括0.1
'< 0.1' Any version lower than 0.1 0.1以下
'<= 0.1' Version 0.1 and any lower version 0.1以下，包括0.1
In addition to the logic operators CocoaPods has an optimisic operator ~>:

'~> 0.1.2' Version 0.1.2 and the versions up to 0.2, not including 0.2 and higher 0.2以下(不含0.2)，0.1.2以上（含0.1.2）
'~> 0.1' Version 0.1 and the versions up to 1.0, not including 1.0 and higher 1.0以下(不含1.0)，0.1以上（含0.1）
'~> 0' Version 0 and higher, this is basically the same as not having it. 0和以上，等于没有此约束

### Pod 升级/降级

[ios - How to downgrade or install an older version of Cocoapods - Stack Overflow](https://stackoverflow.com/questions/20487849/how-to-downgrade-or-install-an-older-version-of-cocoapods)

1. 先卸载，在安装
to remove your current version you could just run:

sudo gem uninstall cocoapods
you can install a specific version of cocoa pods via the following command:

sudo gem install cocoapods -v 0.25.0
You can use older installed versions with following command:

pod _0.25.0_ setup

1. 在某工程中使用指定版本Pod
Actually, you don't need to downgrade – if you need to use older version in some projects, just specify the version that you need to use after pod command.

pod _0.37.2_ setup




#### 总结

pod install只会将Podfile的信息写入到Podfile.lock, 但是不修改Pods已安装的依赖库的版本信息。pod update不但会将Podfile的信息写入到Podfile.lock文件中, 还会更新Pods已安装的依赖库的版本信息。

## pod install

`pod install`参考的是podfile.lock文件的版本

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15364967396430.jpg)

## pod update

`pod install`参考的是Podfile文件的版本

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/15364967642596.jpg)

如果Podfile文件库未指定版本，默认下载库的最新版本

## rubygems镜像

[RubyGems 镜像 - Ruby China](https://gems.ruby-china.com/)

```
$ gem update --system # 这里请翻墙一下
$ gem -v
2.6.3
$ gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
$ gem sources -l
https://gems.ruby-china.com
# 确保只有 gems.ruby-china.com
```


通俗地来讲RubyGems就像是一个仓库，里面包含了各种软件的包(如Cocoapods、MySql)，可以通过命令行的方式来安装这些软件包，最为方便的是自动帮你配置好软件依赖的环境，整个安装过程仅仅只需要几行命令行。

我们在安装CocoaPods的时候，就是通过rubygems来安装的，由于在国内访问rubygems非常慢，所以替换rubygems镜像源就显得十分必要了。在替换rubygems镜像源的时候，先检查一下rubygems的版本，建议在2.6.x以上，如果没有的话，建议先升级一下，升级命令行如下：


```
$ gem update --system # 这里请翻墙一下
$ gem -v
```

升级完成之后，可以用gem -v查看下现在的版本号，比如我现在的版本是2.6.7。之前很多人用的都是淘宝的镜像源，现在淘宝的rubygems镜像源交给Ruby China来维护了，替换rubygems镜像源的命令行如下：

```
$ gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
$ gem sources -l
https://gems.ruby-china.org

```
确保只有 gems.ruby-china.org

但是现在淘宝源已经不再维护了，所以需要换为目前国内还在维护的【ruby-china】，如果之前没换过则默认为【https://rubygems.org/ 】，这个是国外的，对于我们来说也是比较慢的，所以也得将其更换掉

```
// 移除
gem sources --remove http://ruby.taobao.org/

// 添加 ruby-china 的源
gem sources --add https://gems.ruby-china.org/
```

参考 [解决CocoaPods慢的小技巧 - 简书](https://www.jianshu.com/p/b3d15c9bbf2b), 
[解决Cocoapods贼慢问题 - 简书](https://www.jianshu.com/p/f024ca2267e3)

## Podfile

### use_frameworks!

[podfile中 use_frameworks! 和 #use_frameworks!区别 - 简书](http://www.jianshu.com/p/ac629a1cb8f5)

静态库：（静态链接库）（.a）在编译时会将库copy一份到目标程序中，编译完成之后，目标程序不依赖外部的库，也可以运行
       缺点是会使应用程序变大
动态库：（.dylib）编译时只存储了指向动态库的引用。
       可以多个程序指向这个库，在运行时才加载，不会使体积变大，
       但是运行时加载会损耗部分性能，并且依赖外部的环境，如果库不存在或者版本不正确则无法运行
Framework：实际上是一种打包方式，将库的二进制文件，头文件和有关的资源文件打包到一起，方便管理和分发。

对于是否使用Framework，CocoaPods 通过use_frameworks来控制

不使用use_frameworks! -> static libraries 方式 -> 生成.a文件
在Podfile中如不加use_frameworks!，cocoapods会生成相应的 .a文件（静态链接库），
Link Binary With Libraries: libPods-**.a 包含了其他用pod导入有第三库的.a文件
2.use_frameworks! -> dynamic frameworks 方式 -> 生成.framework文件

使用了use_frameworks!，cocoapods会生成对应的frameworks文件（包含了头文件，二进制文件，资源文件等等）
Link Binary With Libraries：Pods_xxx.framework包含了其它用pod导入的第三方框架的.framework文件


iOS8 / Xcode 6 之前是无法使用静态库，出现了AppExtension之后可以使用

对于是否使用Framework，CocoaPods 通过use_frameworks来控制

不使用use_frameworks! -> static libraries 方式 -> 生成.a文件
在Podfile中如不加use_frameworks!，cocoapods会生成相应的 .a文件（静态链接库），
Link Binary With Libraries: libPods-**.a 包含了其他用pod导入有第三库的.a文件
2.use_frameworks! -> dynamic frameworks 方式 -> 生成.framework文件

使用了use_frameworks!，cocoapods会生成对应的frameworks文件（包含了头文件，二进制文件，资源文件等等）
Link Binary With Libraries：Pods_xxx.framework包含了其它用pod导入的第三方框架的.framework文件
1.纯oc项目中 通过pod导入纯oc项目, 一般都不使用frameworks

2.swift 项目中通过pod导入swift项目，必须要使用use_frameworks！，在需要使用的到地方 import AFNetworking

3.swift 项目中通过pod导入OC项目

 1） 使用use_frameworks，在桥接文件里加上#import "AFNetworking/AFNetworking.h"
 2）不使用frameworks，桥接文件加上 #import "AFNetworking.h"


[Podfile中的 use_frameworks! - 林天海云 - SegmentFault](https://segmentfault.com/a/1190000007076865)

A、用cocoapods 导入swift 框架 到 swift项目和OC项目都必须要 use_frameworks!
B、使用 dynamic frameworks，必须要在Podfile文件中添加 use_frameworks!

(1)如果在Podfile文件里不使用 use_frameworks! 则是会生成相应的 .a文件（静态链接库），通过 static libraries 这个方式来管理pod的代码。   

(2)Linked:libPods-xxx.a包含了其它用pod导入的第三方框架的.a文件。

(3)如果使用了use_frameworks! 则cocoapods 会生成相应的 .frameworks文件（动态链接库：实际内容为 Header + 动态链接库 + 资源文件），使用 dynamic frameworks 来取代 static libraries 方式。   

(4)Linked:Pods_xxx.framework包含了其它用pod导入的第三方框架的.framework文件。
use_frameworks! -> dynamic frameworks 方式 -> .framework

```
#use_frameworks! -> static libraries 方式 -> .a
```

关于Library 和 Framework 可以参考：
http://blog.lanvige.com/2015/...



Library vs Framework in iOS


CocoaPods 终于支持了Swift，同时也发现Github团队的又一力作Carthage。它们都将包统一编译为Framework，但不同的是，Carthage 仅支持 iOS 8 & Xcode 6 Dynamic Framework 这一新特性。

Update 201504 CocoaPods 0.36 后也仅支持 Dynamic Framework，放弃了之前的 Static Framework 形式。

那这个编译结果有什么区别？

Static Library
Dynamic Library
Static Framework
Dynamic Framework
Static Library & Dynamic Library

这两者属于标准的编译器知识，所以讲的会比较多。

简单的说，静态链接库是指模块被编译合并到应用中，应用程序本身比较大，但不再需要依赖第三方库。运行多个含有该库的应用时，就会有多个该库的Copy在内存中，冗余。

动态库可以分开发布，在运行时查找并载入到内存，如果有通用的库，可以共用，节省空间和内存。同时库也可以直接单独升级，或作为插件发布。

Library & Framework

在iOS中，Library 仅能包含编译后的代码，即 .a 文件。

但一般来说，一个完整的模块不仅有代码，还可能包含.h 头文修的、.nib 视图文件、图片资源文件、说明文档。（像 UMeng 提供的那些库，集成时，要把一堆的文件拖到Xcode中，配置起来真不是省心的事。）

Framework 作为 Cocoa/Cocoa Touch 中使用的一种资源打包方式，可以上述文件等集中打包在一起，方便开发者使用（就像Bundle），。

我们每天都要跟各种各样的Framework打交道。如Foundation.framework / UIKit.framework等，这些都是Cocoa Touch开发框架本身提供的，而且这些 Framework 都是动态库。

但Apple对待第三方开发者使用动态库的态度却是极端的否定，所以在iOS 7之前如果使用动态库是肯定会被reject的，reason。但在2014年Xcode6和iOS 8发布时却开放了这个禁地，应该主要是为了App Extension。

Framework 包含什么？

到底Framework中有什么，这里来看Alamofire编译后的结果：


```
Alamofire.framework
├── Alamofire
├── Headers
│   ├── Alamofire-Swift.h
│   └── Alamofire.h
├── Info.plist
├── Modules
│   ├── Alamofire.swiftmodule
│   │   ├── arm.swiftdoc
│   │   ├── arm.swiftmodule
│   │   ├── arm64.swiftdoc
│   │   ├── arm64.swiftmodule
│   │   ├── i386.swiftdoc
│   │   ├── i386.swiftmodule
│   │   ├── x86_64.swiftdoc
│   │   └── x86_64.swiftmodule
│   └── module.modulemap
└── _CodeSignature
    └── CodeResources
    ```


Framework 包括了二进制文件（可动态链接并且为每种处理器架构专属生成），这点和静态库并无区别，但不同的是，它包含其它资源：

头文件 - 也包含Swift symbols所生成的头文件，如 `Alamofire-Swift.h`
所有资源文件的签名 - Framework被嵌入应用前都会被重新签名。
资源文件 - 像图片等文件。
Dynamic Frameworks and Libraries - 参见Umbrella Frameworks
Clang Module Map 和 Swift modules - 对应处理器架构所编译出的Module文件
Info.plist - 该文件中说明了作者，版本等信息。
Cocoa Touch Framework (实际内容为 Header + 动态链接库 + 资源文件)

Static Framework & Dynamic Framework

刚才也说明了Apple所创建的标准 Cocoa Touch Framework 里面包含的是动态链接库。而Dynamic Framework 为 Xcode 6中引入的新特性，仅支持 iOS 8，因为Carthage使用的是该特性，所以仅支持iOS 8，说明上有提。

但新版CocoaPods中使用Framework是能够支持iOS 7的，这说明它不是Dynamic Framework。推断它仅是将Static Library封装入了Framework。还是静态库，伪Framework。（v 0.36 正式版开始，仅提供 Dynamic Framework 的方式，不再支持 iOS7）。

关于Static Framework，见：

伪Framework 是指使用Xcode的Bundle来实现的。在使用时和Cocoa Touch Framework没有区别。但通过Framework，可以或者其中包含的资源文件（Image, Plist, Nib）。

#### Xcode 6 and iOS Static Frameworks

iOS Universal Framework Mk 8 中文
iOS-Framework
Swift 与 Framework 的关系
在Xcode 6.0 Beta 4的 Release Notes 中，可以找到这句话：

```
Xcode does not support building static libraries that include Swift code. (17181019)
在静态库中使用Swift语言开发，在build时会得到：
```
```

error: /Applications/Xcode.app/Contents/Developer/Toolchains/
XcodeDefault.xctoolchain/usr/bin/libtool:
unknown option character `X' in: -Xlinker
```

CocoaPods 将第三方都编译为Static Library。这导致Pod不支持Swift语言。所以新版Pod已将Static Library改为Framework。

Pods 0.36.0.beta.1 虽然已经支持Swift，但在编译时仍会给出下面警告：

1
ld: warning: embedded dylibs/frameworks only run on iOS 8 or later
CocoaPods 0.36 rc 开始对Swift正式放弃旧的打包方式，使用Dynamic Framework，也就意味着不再支持 iOS 7。更多见：SO

其它扩展阅读：

How to distribute Swift Library without exposing the source code?
Pod Authors Guide to CocoaPods Frameworks
Dynamic Framework

使用Dynamic 的优势：

模块化，相对于Static Library，Framework可以将模块中的函数代码外的资源文件打包在一起。
共享可执行文件 iOS 有沙箱机制，不能跨App间共享共态库，但Apple开放了App Extension，可以在App和Extension间共间动态库（这也许是Apple开放动态链接库的唯一原因了）。
iOS 8 Support only:

如果使用了动态链接库，在尝试编译到iOS 7设备上时，会出现在下错误：


```
ld: warning: directory not found for option '-F/Volumes/Mactop BD/repos/SwiftWeather/Carthage.build/iOS'
ld: embedded dylibs/frameworks are only supported on iOS 8.0 and later (@rpath/Alamofire.framework/Alamofire) for architecture armv7
clang: error: linker command failed with exit code 1 (use -v to see invocation)
```

[Library vs Framework in iOS | Lanvige's Zen Garden](http://blog.lanvige.com/2015/01/04/library-vs-framework-in-ios/?utm_source=tuicool&utm_medium=referral)

## 制作私有的Pod

* [细聊 Cocoapods 与 Xcode 工程配置](https://bestswifter.com/cocoapods/#cocoapods)
* [iOS组件化实践(三)：实施 - 简书](https://www.jianshu.com/p/0a7f3c0b4194)

### pod 制作

* pod repo add xxx  git@xxx.git
* pod lib create 



# Cocoapod原理

[CocoaPods 都做了什么？](https://draveness.me/cocoapods)

[Cocoapods原理总结 - iOS - 掘金](https://juejin.im/entry/59dd94b06fb9a0451463030b)

## static library

先看一下使用CocoaPods管理依赖前项目的文件结构

```
CardPlayer
├── CardPlayer
│   ├── CardPlayer
│   ├── CardPlayer.xcodeproj
│   ├── CardPlayerTests
│   └── CardPlayerUITests
├── exportOptions.plist
└── wehere-dev-cloud.mobileprovision

```

然后我们使用Pod来管理依赖，编写的PodFile如下所示:

```
project 'CardPlayer/CardPlayer.xcodeproj'

target 'CardPlayer' do
  pod 'AFNetworking', '~> 1.0'
end

```

## 文件结构的变化

然后使用pod install，添加好依赖之后，项目的文件结构如下所示:

```
CardPlayer
├── CardPlayer
│   ├── CardPlayer
│   ├── CardPlayer.xcodeproj
│   ├── CardPlayerTests
│   └── CardPlayerUITests
├── CardPlayer.xcworkspace
│   └── contents.xcworkspacedata
├── PodFile
├── Podfile.lock
├── Pods
│   ├── AFNetworking
│   ├── Headers
│   ├── Manifest.lock
│   ├── Pods.xcodeproj
│   └── Target\ Support\ Files
├── exportOptions.plist
└── wehere-dev-cloud.mobileprovision

```

可以看到我们添加了如下文件

1.  PodFile 依赖描述文件

2.  Podfile.lock 当前安装的依赖库的版本

3.  CardPlayer.xcworkspace

    xcworkspace文件，使用CocoaPod管理依赖的项目，XCode只能使用workspace编译项目，如果还只打开以前的xcodeproj文件进行开发，编译会失败

    xcworkspace文件实际是一个文件夹，实际Workspace信息保存在contents.xcworkspacedata里，该文件的内容非常简单，实际上只指示它所使用的工程的文件目录

    如下所示:

 ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <Workspace
       version = "1.0">
       <FileRef
          location = "group:CardPlayer/CardPlayer.xcodeproj">
       </FileRef>
       <FileRef
          location = "group:Pods/Pods.xcodeproj">
       </FileRef>
    </Workspace>
```

4.  Pods目录

    1.  Pods.xcodeproj，Pods工程，所有第三方库由Pods工程构建，每个第3方库对应Pods工程的1个target，并且这个工程还有1个Pods-Xxx的target，接下来在介绍工程时再详细介绍

    2.  AFNetworking 每个第3方库，都会在Pods目录下有1个对应的目录

    3.  Headers

        在Headers下有两个目录，Private和Public，第3方库的私有头文件会在Private目录下有对应的头文件，不过是1个软链接，链接到第3方库的头文件 第3方库的Pubic头文件会在Public目录下有对应的头文件，也是软链接

        如下所示:

        ```
        Headers/
         ├── Private
         │   └── AFNetworking
         │       ├── AFHTTPClient.h -> ../../../AFNetworking/AFNetworking/AFHTTPClient.h
         │       ├── AFHTTPRequestOperation.h -> ../../../AFNetworking/AFNetworking/AFHTTPRequestOperation.h
         │       ├── AFImageRequestOperation.h -> ../../../AFNetworking/AFNetworking/AFImageRequestOperation.h
         │       ├── AFJSONRequestOperation.h -> ../../../AFNetworking/AFNetworking/AFJSONRequestOperation.h
         │       ├── AFNetworkActivityIndicatorManager.h -> ../../../AFNetworking/AFNetworking/AFNetworkActivityIndicatorManager.h
         │       ├── AFNetworking.h -> ../../../AFNetworking/AFNetworking/AFNetworking.h
         │       ├── AFPropertyListRequestOperation.h -> ../../../AFNetworking/AFNetworking/AFPropertyListRequestOperation.h
         │       ├── AFURLConnectionOperation.h -> ../../../AFNetworking/AFNetworking/AFURLConnectionOperation.h
         │       ├── AFXMLRequestOperation.h -> ../../../AFNetworking/AFNetworking/AFXMLRequestOperation.h
         │       └── UIImageView+AFNetworking.h -> ../../../AFNetworking/AFNetworking/UIImageView+AFNetworking.h
         └── Public
             └── AFNetworking
                 ├── AFHTTPClient.h -> ../../../AFNetworking/AFNetworking/AFHTTPClient.h
                 ├── AFHTTPRequestOperation.h -> ../../../AFNetworking/AFNetworking/AFHTTPRequestOperation.h
                 ├── AFImageRequestOperation.h -> ../../../AFNetworking/AFNetworking/AFImageRequestOperation.h
                 ├── AFJSONRequestOperation.h -> ../../../AFNetworking/AFNetworking/AFJSONRequestOperation.h
                 ├── AFNetworkActivityIndicatorManager.h -> ../../../AFNetworking/AFNetworking/AFNetworkActivityIndicatorManager.h
                 ├── AFNetworking.h -> ../../../AFNetworking/AFNetworking/AFNetworking.h
                 ├── AFPropertyListRequestOperation.h -> ../../../AFNetworking/AFNetworking/AFPropertyListRequestOperation.h
                 ├── AFURLConnectionOperation.h -> ../../../AFNetworking/AFNetworking/AFURLConnectionOperation.h
                 ├── AFXMLRequestOperation.h -> ../../../AFNetworking/AFNetworking/AFXMLRequestOperation.h
                 └── UIImageView+AFNetworking.h -> ../../../AFNetworking/AFNetworking/UIImageView+AFNetworking.h  

        ```

    4.  Manifest.lock manifest文件 描述第3方库对其它库的依赖

        ```
        PODS:
          - AFNetworking (1.3.4)

        DEPENDENCIES:
          - AFNetworking (~> 1.0)

        SPEC CHECKSUMS:
          AFNetworking: cf8e418e16f0c9c7e5c3150d019a3c679d015018

        PODFILE CHECKSUM: 349872ccf0789fbe3fa2b0f912b1b5388eb5e1a9

        COCOAPODS: 1.3.1

        ```

    5.  Target Support Files 支撑target的文件

        ```
        Target\ Support\ Files/
        ├── AFNetworking
        │   ├── AFNetworking-dummy.m
        │   ├── AFNetworking-prefix.pch
        │   └── AFNetworking.xcconfig
        └── Pods-CardPlayer
            ├── Pods-CardPlayer-acknowledgements.markdown
            ├── Pods-CardPlayer-acknowledgements.plist
            ├── Pods-CardPlayer-dummy.m
            ├── Pods-CardPlayer-frameworks.sh
            ├── Pods-CardPlayer-resources.sh
            ├── Pods-CardPlayer.debug.xcconfig
            └── Pods-CardPlayer.release.xcconfig

        ```

在Target Support Files目录下每1个第3方库都会有1个对应的文件夹，比如AFNetworking，该目录下有一个空实现文件，也有预定义头文件用来优化头文件编译速度，还会有1个xcconfig文件，该文件会在工程配置中使用，主要存放头文件搜索目录，链接的Flag(比如链接哪些库)

在Target Support Files目录下还会有1个Pods-XXX的文件夹，该文件夹存放了第3方库声明文档markdown文档和plist文件，还有1个dummy的空实现文件，还有debug和release各自对应的xcconfig配置文件，另外还有2个脚本文件，Pods-XXX-frameworks.sh脚本用于实现framework库的链接，当依赖的第3方库是framework形式才会用到该脚本，另外1个脚本文件: Pods-XXX-resources.sh用于编译storyboard类的资源文件或者拷贝*.xcassets之类的资源文件

## 问题记录

### 1.`$ pod install`后，没有生成`XWorkSpace`文件，并且报错
`2017-06-28`

Error:“The sandbox is not in sync with the Podfile.lock…”

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/2017-06-28-14986422106999.png)

解决方法：
找的时候，参考[Pod install error in terminal: not creating xcode workspace | Treehouse Community](https://teamtreehouse.com/community/pod-install-error-in-terminal-not-creating-xcode-workspace)，重新安装了一下`Cocoapods`发现还是这样，后面`cd`到`cocoapods`的`~/.cocoapods`目录后，执行 `sudo gem update  cocoapods`


![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/2017-06-28-14986425068849.jpg)

然后回到项目文件夹，执行`pod install` 就可以了


### 2. 升级Cocoapods时候， Unable to download data from https://gems.ruby-china.org


``` 
╰─ sudo gem install cocoapods
ERROR:  Could not find a valid gem 'cocoapods' (>= 0), here is why:
          Unable to download data from https://gems.ruby-china.org/ - bad response Not Found 404 (https://gems.ruby-china.org/specs.4.8.gz)
```

原因：域名已经被更换了：从`gems.ruby-china.org`更换成`gems.ruby-china.com`

可以切换源
```
gem sources -a https://gems.ruby-china.com/  --remove https://gems.ruby-china.org/
```


参考： [Error fetching https://gems.ruby-china.org/: bad response Not Found 404 解决方法 - CSDN博客](https://blog.csdn.net/MChuajian/article/details/82016921)

### CocoaPods version

执行pod install时，提示如下信息：

```
[!] The version of CocoaPods used to generate the lockfile (1.5.3) is higher than the version of the current executable (1.3.1). Incompatibility issues may arise.
[!] Unable to satisfy the following requirements:

- `AFNetworking (~> 3.0)` required by `Podfile`
- `AFNetworking (= 3.2.1)` required by `Podfile.lock`

None of your spec sources contain a spec satisfying the dependencies: `AFNetworking (~> 3.0), AFNetworking (= 3.2.1)`.

You have either:
 * out-of-date source repos which you can update with `pod repo update` or with `pod install --repo-update`.
 * mistyped the name or version.
 * not added the source repo that hosts the Podspec to your Podfile.

Note: as of CocoaPods 1.0, `pod repo update` does not happen on `pod install` by default.
```
* 这是因为Podfile中的库版本比podfile.lock制定的低了
* 用'pod repo udapte'命令更新
* 然后'pod install'安装

参考[The version of CocoaPods used to generate the lockfile is higher than the version of - CSDN博客](https://blog.csdn.net/qq942418300/article/details/53446719)


### Pod 更新慢

```
pod update --verbose --no-repo-update
```

* 在执行pod install命令时加上参数--verbose即:pod install 'ThirdPartyName' --verbose,可在终端详细显示安装信息，看到pod目前正在做什么(其实是在安装第三方库的索引)，确认是否是真的卡住。 
* 进入终端家目录，输入ls -a可看到隐藏的pod文件夹，输入
* cd ~/.cocoapods/进入pod文件夹，然后输入du -sh即可看到repos文件夹的容量，隔几秒执行一下该命令，可看到repos的容量在不断增大，待容量增大至300+M时，说明，repos文件夹索引目录已安装完毕。此时，pod功能即可正常使用。

#### Cocoapods install时查看进度

新开终端窗口cd到复制的路径
输入命令：du -sh

 
### 1. CocoaPods could not find compatible versions for pod "XXX"

解决方法：

```
pod update --verbose --no-repo-update

pod install
```

### 2. 问题can't find gem cocoapods--ruby环境版本太低

```
/Library/Ruby/Site/2.0.0/rubygems.rb:250:in `find_spec_for_exe': can't find gem cocoapods (>= 0.a) (Gem::GemNotFoundException)
from /Library/Ruby/Site/2.0.0/rubygems.rb:278:in `activate_bin_path'
from /usr/local/bin/pod:22:in  '<main>''

```如下图：
![](https://i.loli.net/2018/11/09/5be586e655673.jpg)


原因：是由于ruby环境太低导致。
解决方法：（更新gem）

```
$ sudo gem update --system
```


如果不行，看能不能直接更新rubygems

```
sudo gem install rubygems-update
```
如果失败

```
ERROR:  While executing gem ... (Errno::EPERM)
    Operation not permitted @ rb_sysopen - /System/Library/Frameworks/Ruby.framework/Versions/2.3/usr/bin/gem

```
则执行

```
sudo gem install -n /usr/local/bin cocoapods

```
[CocoaPods1.4.0 安装使用详解 - 简书](https://www.jianshu.com/p/1892aa0b97ea)

3. 问题 unable to access 'https://github.com/CocoaPods/Specs.git/


![](https://i.loli.net/2018/11/10/5be6655132a7d.jpg)
1、查看下当前ruby版本
ruby -v

2、查看Gem源地址
gem sources -l

3、更换Gem源地址
这一步需要根据上面的gem源地址来进行，如果你的源地址已经是
http://gems.ruby-china.org/或者http://rubygems.org/就不用更换了，其他的地址可能不通，需要更换；
https://ruby.taobao.org/ 已经不能使用了
http://gems.ruby-china.org/ 可以使用
http://rubygems.org/ Gem的官方地址，可以使用

需要注意的是这里如果使用的是 https开头的可能会报错
fatal: unable to access 'https://github.com/CocoaPods/Specs.git/': LibreSSL SSL_read: SSL_ERROR_SYSCALL, errno 60
需要将Https换成http即可


```
  fatal: unable to access 'https://github.com/CocoaPods/Specs.git/': LibreSSL SSL_read: SSL_ERROR_SYSCALL, errno 54

```

4. AFNetworking.h 找不到

今天遇到一个很奇怪的问题，在本地通过cocoapods引入AFNetworking包后，文件引入报错：“AFNetworking.h”file not found，但是拷贝到另一台电脑，能够重新运行，本以为是xcode出了问题，所以重新安装了xcode，但是问题依然存在。
后来在网站上看到一个解决“AFNetworking.h”找不到的解决方案。原文的答案是：
In XCode Go to Product -> Scheme -> Manage Schemes. There delete the project (maintaining the pods) and add the project again. It worked for me.

[xcode文件找不到-－－“AFNetworking.h”file not found - wsh7365062的博客 - CSDN博客](https://blog.csdn.net/wsh7365062/article/details/53112723)



### Pod install & Pod update 

[使用 pod install 还是 pod update ？ - 简书](https://www.jianshu.com/p/a977c0a03bf4)

## 介绍：

许多人开始使用CocodPods的时候认为pod install只是你第一次用CocoaPods建立工程的时候使用，而之后都是使用pod update，但实际上并不是那会事。

简单来说，就是：

1.使用pod install来安装新的库，即使你的工程里面已经有了Podfile，并且已经执行过pod install命令了；所以即使你是添加或移除库，都应该使用pod install。

2.使用pod update [PODNAME] 只有在你需要更新库到更新的版本时候用。

## 详细介绍：

* * *

#### pod install ：

* 这个是第一次在工程里面使用pods的时候使用，并且，也是每次你编辑你的Podfile（添加、移除、更新）的时候使用。

* 每次运行pod install命令的时候，在下载、安装新的库的同时，也会把你安装的每个库的版本都写在了Podfile.lock文件里面。这个文件记录你每个安装库的版本号，并且锁定了这些版本。

* 当你使用pod install它只解决了pods里面，但不在Podfile.lock文件里面的那些库之间的依赖。对于在Podfile.lock里面所列出的那些库，会下载在Podfile.lock里面明确的版本，并不会去检查是否该库有新的版本。对于还不在Podfile.lock里面的库，会找到Podfile里面描述对应版本（例如：pod "MyPod", "~>1.2"）。

* 如果你的 Pods 文件夹不受版本控制，那么你需要做一些额外的步骤来保证持续集成的顺利进行。最起码，Podfile 文件要放入版本控制之中。**另外强烈建议将生成的 .xcworkspace 和 Podfile.lock 文件纳入版本控制**，这样不仅简单方便，也能保证所使用 Pod 的版本是正确的。

* * *

#### pod outdated：

当你运行pod outdated命令，CocoaPods会列出那些所有较Podfile.lock里面有新版本的库（那些当前被安装着的库的版本）。这个意思就是，如果你运行pod update PODNAME，如果这个库有新的版本，并且新版本仍然符合在Podfile里的限制，它就会被更新。

* * *

#### pod update：

当你运行 pod update PODNAME 命令时，CocoaPods会帮你更新到这个库的新版本，而不需要考虑Podfile.lock里面的限制，它会更新到这个库尽可能的新版本，只要符合Podfile里面的版本限制。

如果你运行pod update，后面没有跟库的名字，CocoaPods就会更新每一个Podfile里面的库到尽可能的最新版本。

## 正确用法：

你应该使用pod update PODNAME去只更新某个特定的库（检查是否有新版本，并尽可能更新到新的版本）。对应的，你应该使用pod install，这个命令不会更新那些已经安装了的库。

当你在你的Podfile里面添加了一个库的时候，你应该使用pod install，而不是pod update，这样既安装了这个库，也不需要去更新其它的已安装库。

你应该使用pod update去更新某个特定的库，或者所有的库（在Podfile的限制中）。

## 提交你的Podfile.lock文件：

在此提醒，即使你一向以来，不commit你的Pods文件夹到远程仓库，你也应该commit并push到远程仓库中。

要不然，就会破坏整个逻辑，没有了Podfile.lock限制你的Pods中的库的版本。

## 举例：

以下会举例说明在各个场景下的使用。

#### 场景1：User1创建了一个工程

User1创建了一个工程，并且想使用A、B、C这三个库，所以他就创建了一个含有这个三个库的Podfile，并且运行了pod intall。

这样就会安装了A、B、C三个库到这个工程里面，假设我们的版本都为1.0.0。

因此Podfile.lock跟踪并记录A、B、C这三个库以及版本号1.0.0。

顺便说一下：由于这个工程是第一次运行pod install，并且Pods.xcodeproj工程文件还不存在，所以这个命令也会同时创建Pods.xcodeproj以及.xcworkspace工程文件，这只是这个命令的一个副作用，并不是主要目的。

#### 场景2：User1添加了一个库

之后，User1添加了一个库D到Podfile文件中。

然后他就应该运行pod install命令了。所以即使库B的开发者发布了B的一个新版本1.1.0。但只要是在第一次执行pod install之后发布的，那么B的版本仍然是1.0.0。因为User1只是希望添加一个新库D，不希望更新库B。

这就是很多人容易出错的地方，因为他们在这里使用了pod update，因为想着“更新我的工程一个新的库而已”。这里要注意！

#### 场景3：User2加入到这个工程中

然后，User2，一个之前没有参与到这个工程的人，加入了。他clone了一份仓库，然后使用pod install命令。

Podfile.lock的内容就会保证User1和User2会得到完全一样的pods，前提是Podfile.lock被提交到git仓库中。

即使库C的版本已经更新到了1.2.0，User2仍然会使用C的1.0.0版本，因为C已经在Podfile.lock里面注册过了，C的1.0.0版本已经被Podfile.lock锁住了。

#### 场景4：检查某个库的新版本

之后，User1想检查pods里面是否有可用的更新时，他执行了pod outdated，这个命令执行后，会列出来：B有了1.1.0版本，C有了1.2.0版本。

这时候，User1打算更新库B，但不更新库C，所以执行pod update B，这样就把B从1.0.0更新到1.1.0（同时更新Podfile.lock里面对B的版本记录），此时，C仍然是1.0.0版本，不会更新。

### 在Podfile中使用明确版本还不够

有些人认为在Podfile中明确某个库的版本，例如：pod 'A', '1.0.0' ,足以保证所有项目里面的人都会使用完全一样的版本。

这个时候，他们可能会觉得，此时如果添加一个新库的时候，我使用pod update并不会去更新其它的库，因为其它的库已经被限定了固定的版本号。

但事实上，这不足以保证User1和User2的pods中库的版本会完全一样。

一个典型的例子是，如果库A有一个对库A2的依赖（声明在A.podspec中：dependency 'A2', '~> 3.0'），如果这样的话，使用 pod 'A', '1.0.0' 在你的Podfile中，的确会让User1和User2都使用同样版本的库A（1.0.0），然而：

最后User1可能使用A的依赖库A2的版本为3.4（因为3.4是当时User1使用的最新版本），但User2使用的库A2版本是3.5（假设A2的开发者刚刚发布了A2的新版本3.5）。

所以只有一个方法来保证某项目的每个开发者都使用相同版本的库，就是每个电脑中都使用同样的Podfile.lock，并且合理使用pod install 和 pod update。


## 参考

* [Podfile.lock背后的那点事 | Startry Blog](http://blog.startry.com/2015/10/28/Somthing-about-Podfile-lock/)