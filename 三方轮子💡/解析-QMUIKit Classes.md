#  QMUIKit Classes

[功能列表 - QMUI iOS](https://qmuiteam.com/ios/documents)

## QMUIAlbumViewController

用于展示当前设备相册里的相簿列表，主要功能包括：

1.  支持指定要显示的资源类型，例如图片、视频、音频等。
2.  支持调整基本的外观，包括 cell 高度、缩略图大小、字号大小等。
3.  支持更改无资源等特殊情况下的提示语。

## QMUIAlertController

用于代替系统的 `UIAlertController` 的模态弹窗控件，使用方式与 `UIAlertController` 相近，但相比 `UIAlertController` 支持了更多的功能，包括：

1.  支持大量的 UI 样式调整，包括间距、字体、文字颜色、背景色、分隔线颜色等。
2.  支持显示自定义的 view。
3.  按钮也支持样式的自定义。
4.  支持判断当前是否有任一弹窗正在显示（在某些通过 scheme 从外部跳转过来的场景特别方便）。

## QMUIAsset

封装了系统的 `PHAsset`，用于表示相簿里的一个资源，但相比 `PHAsset` 使用更加便捷，主要特性包括：

1.  支持同步/异步获取一个图片/视频资源的缩略图（可以指定尺寸），预览图以及原图。
2.  支持获取资源的体积，图片的 `UIImageOrientation` 和 data 等信息。
3.  支持获取 iCloud 的相簿资源。

## QMUIAssetsGroup

封装了系统的 `PHAssetCollection、PHFetchResult`，用于表示一个相簿或者相簿资源合集，与系统类相比使用更加便捷，主要特性包括：

1.  支持获取相册名称，资源数量，缩略图（可以指定尺寸）等信息。
2.  支持获取相册的所有资源，包括图片、视频、音频。

## QMUIAssetsManager

相簿相关的工具类，按照功能类型来划分，总共包含以下几个特性：

1.  获取当前应用的“照片”访问授权状态。
2.  调起系统询问是否授权访问“照片”的 `UIAlertView`。
3.  获取所有的相册，支持获取如个人收藏，最近添加，自拍这类“智能相册”，可以筛选只包含照片/视频/音频的相册。
4.  保存图片或视频到指定的相册。

## QMUIBadge

用于在 `UIBarButtonItem`、`UITabBarItem` 上显示未读数（`badge`）和未读红点（`updatesIndicator`），且对设置的时机无要求，不用担心 `valueForKey:@"view"` 返回 `nil` 的情况。

## QMUIButton

用于代替系统的 `UIButton` 的按钮控件，支持的特性包括：

1.  点击、禁用状态自动通过改变自身 alpha 的方式来表现，无需每次都为特定的 state 设置样式。
2.  支持让图片和文字跟随按钮的 `tintColor` 一起变化（系统的 `UIButton` 默认不支持）。
3.  支持设置点击时的背景色和边框色。
4.  支持调整按钮里图片和文字的相对位置，图片可显示在文字的上、下、左、右（`UIButton` 只支持图片显示在文字左边）。

## QMUINavigationButton

专用于顶部导航栏按钮的控件，一般有两种使用方式：

1.  使用其中的类方法快速生成一个用于 `navigationItem` 的 `UIBarButtonItem` 对象。
2.  init 一个 `QMUINavigationButton` 实例并将其作为 `UIBarButtonItem` 的 customView，`QMUINavigationButton` 内部专门针对每个 iOS 版本都调整了顶部按钮的间距和位置，从而达到即便使用 `customView`，布局也依然和系统的 `UIBarButtonItem` 保持一致的效果。

## QMUIToolbarButton

专用于 `UIToolbar` 上的按钮的控件，一般有两种使用方式：

1.  使用其中的类方法快速生成一个 `UIBarButtonItem` 对象。
2.  init 一个 `QMUIToolbarButton` 实例并将其作为 `UIBarButtonItem` 的 customView。

## QMUILinkButton

支持显示下划线的按钮，可用于模拟链接。下划线的宽度、颜色、缩进均可设置。

## QMUIGhostButton

“幽灵”按钮，也即背景透明、带圆角边框的按钮，圆角大小会随着按钮的大小变化而变化，从而保证按钮左右两端为圆形。默认提供若干种颜色（参考 `QMUIGhostButtonColor`），也支持设置自定义的颜色。另外按钮里的图片也支持跟随按钮的颜色变化而变化，这样你就只需要通过一个 `ghostColor` 属性同时控制边框、文字、图片的颜色。

## QMUIFillButton

背景填充颜色的按钮，圆角大小会随着按钮的大小变化而变化，从而保证按钮左右两端为圆形。默认提供若干种颜色（参考 `QMUIFillButtonColor`），也支持设置自定义的颜色。另外按钮里的图片也支持跟随按钮文字的颜色变化而变化，这样你就不需要写额外的代码去调整图片的颜色。

## QMUICellHeightCache

用于 `UITableView`、`UICollectionView` 高度计算时缓存高度的类，以业务定义的 key 作为标志来缓存，但由于代码较为陈旧，也不支持 `self-sizing cells`，所以后续可能会被 `QMUICellHeightKeyCache` 和 `QMUICellSizeKeyCache` 代替（目前依然是主要使用的组件）。

## QMUICellHeightIndexPathCache

用于 `UITableView`、`UICollectionView` 高度计算时缓存高度的类，以 `NSIndexPath` 作为标志来缓存，基本废弃。

## QMUICellHeightKeyCache

配合 `UITableView` 使用的 cell 高度缓存控件，依赖于 `estimatedRowHeight` 和 `self-sizing cells`，具体的使用方式请参考 `UITableView (QMUICellHeightKeyCache)` 注释。不过由于目前 iOS 的 `estimatedRowHeight` bug 太多，因此这个控件暂时未得到大规模使用，也无法完全代替旧的 `QMUICellHeightCache`。

## QMUICellSizeKeyCache

与 `QMUICellHeightKeyCache` 相同，不过搭配的是 `UICollectionView`。目前这个控件尚未完成，只是先占位，请勿使用。

## QMUICollectionViewPagingLayout

一个自定义的 `UICollectionViewFlowLayout`，用于横向的按页滚动布局，包含 3 种动画效果：

1.  水平滚动，默认
2.  缩放模式，中间大两边小
3.  旋转模式，围绕底部某个中心点旋转（类似色卡）

可选择支持一次性滚动多张或一次只能滚动一张，支持调整滚动的速度。

## QMUICommonDefines

这并非一个 `Class`，而只是一个头文件，里面定义了大量的常用的宏及 C 函数，按功能分类大概包括：

1.  编译相关的宏，例如判断是否处于 `DEBUG` 模式，当前编译环境使用的 SDK 版本，忽略某些常见的 warning 等。
2.  设备相关的宏，例如区分当前设备是 iPhone、iPad 或是模拟器，获取当前设备的横竖屏状态、屏幕信息等。
3.  布局相关的宏，例如快速获取状态栏、导航栏的高度，为不同的屏幕大小使用不同的值，代表 1px 的宏等。
4.  常用方法的快速调用，例如读取图片、创建字体对象、创建颜色等。
5.  数学计算相关的宏，例如角度换算等。
6.  动画相关的宏，目前仅定义了两个参照系统键盘动画曲线的 `UIViewAnimationOptions`。
7.  布局相关的函数，例如浮点数的像素取整计算、CGPoint、CGRect、UIEdgeIntents 的便捷操作等。
8.  运行时相关的函数，例如 swizzle 方法替换、动态添加方法等。

## QMUICommonViewController

对应系统的 `UIViewController`，建议作为项目里的所有界面的基类来使用。主要特性包括：

1.  自带顶部标题控件 `QMUINavigationTitleView`，支持loading、副标题、下拉菜单，设置标题依然使用系统的 `setTitle:` 方法。
2.  自带空界面控件 `QMUIEmptyView`，支持显示loading、空文案、操作按钮。
3.  统一约定的常用接口，例如初始化 subviews、设置顶部 `navigationItem`、底部 `toolbarItem`、响应系统的动态字体大小变化等，从而保证相同类型的代码集中到同一个方法内，避免多人交叉维护时代码分散难以查找。
4.  通过 `supportedOrientationMask` 属性修改界面支持的设备方向，可直接对实例操作，无需重写系统的方法。
5.  支持点击空白区域降下键盘。

## QMUICommonTableViewController

对应系统的 `UITableViewController`，作为项目里的列表界面的基类来使用。主要特性包括：

1.  继承 `QMUICommonViewController`，具备父类的 titleView、emptyView 等功能。
2.  搭配 `QMUITableView`，具备比 `UITableView` 更强大的功能。
3.  支持默认情况下自动隐藏 `headerView`。
4.  自带搜索框（按需加载），方便地使用搜索功能。
5.  支持指定自定义的 `contentInset`，而不使用系统默认的 `automaticallyAdjustsScrollViewInsets` 特性。

## QMUIConfiguration

维护项目全局 UI 配置的单例，像通用的色值、`UIWindowLevel` 的维护、常见的 UIKit 控件的自定义等，都由这个类管理。使用者通过自己业务项目的 `QMUIConfigurationTemplate` 来为这个单例赋值，而业务代码里则通过 `QMUIConfigurationMacros.h` 文件里的宏来使用这些值。

## QMUIConfigurationTemplate

提供一份模板用于为 `QMUIConfiguration` 赋值，业务项目应该将 QMUI 里的 `QMUIConfigurationTemplate` 文件复制到业务项目里，修改赋值后调用 `setupConfigurationTemplate` 方法以生效。

## QMUIConfigurationMacros

为 `QMUIConfiguration` 的每个属性定义一个对应的宏，以方便在代码里使用。

## QMUIDialogViewController

通用的弹窗控件，以 `headerView`、`contentView`、`footerView` 来组织弹窗里的内容。弹窗只能显示取消和确认两个按钮。

## QMUIDialogSelectionViewController

基于 `QMUIDialogViewController` 实现的支持列表选择的弹窗，支持单选和多选。

## QMUIDialogTextFieldViewController

基于 `QMUIDialogViewController` 实现的带输入框的弹窗，支持自动管理提交按钮的 enable 状态。

## QMUIEmotionView

通用的表情展示控件，支持翻页，带有 `pageControl` 和发送按钮。

## QMUIEmotionInputManager

基于 `QMUIEmotionView` 实现的通用表情面板，需要绑定一个 `UITextField` 或 `UITextView` 来使用，会接管输入框的文字删除，自动判断当前是否正在删除某个表情的占位符。

## QMUIEmptyView

通用的空界面控件，支持显示 loading、主标题和副标题、图片。

## QMUIFloatLayoutView

做类似 css 里的 `float:left / right` 的布局，只要通过 `addSubview:` 将 view 添加进来，即可自动布局。`QMUIFloatLayoutView` 提供了对 item 的最小宽高、最大宽高以及 item 之间的间距的控制。

## QMUIGridView

用于做九宫格布局，根据指定的列数和行高，把每个 item 拉伸到相同的大小。支持在 item 和 item 之间显示分隔线，分隔线也支持以虚线显示。但 `QMUIGridView` 并不支持自动根据空间调整每一行每一列的 item 数量，如有这种需求，建议使用 `UICollectionView`，或自行计算新的 item 行列数。

## QMUIHelper

UI 工具类，按照功能类型来划分，总共包含以下几个特性：

1.  更方便地获取 Bundle 资源的方式。
2.  获取与动态字体设置相关的值。
3.  对设备键盘的管理，包括获取全局键盘显示状态、记录最后一次键盘的高度、从键盘事件的 `NSNotification` 对象中快速获取相关的信息。
4.  对设备的听筒/扬声器的管理。
5.  与 `Core Graphic` 绘图相关的方法。
6.  获取设备信息，包括设备类型、屏幕尺寸等。
7.  处理设备横竖屏旋转的方法。
8.  获取 App 当前的可见界面。
9.  管理设备的状态栏及当前 window 的 `dimmend` 状态。
10.  为 `UIView` 添加弹簧动画的方式。
11.  将给定的 `getter` 转换成对应的 `setter`。

## QMUIImagePickerCollectionViewCell

图片选择控件里的九宫格 cell，支持显示 checkbox、视频时长、饼状进度条及重试按钮（iCloud 图片需要）。

## QMUIImagePickerViewController

图片选择控件里的九宫格界面，底部自带一条工具栏，提供预览已选中图片的按钮和发送按钮，支持限制单次可选的最大图片数量。

## QMUIImagePickerHelper

图片选择相关的工具类，按照功能类型来划分，总共包含以下几个特性：

1.  判断一个由 `QMUIAsset` 对象组成的数组中是否包含特定的 `QMUIAsset` 对象。
2.  从一个由 `QMUIAsset` 对象组成的数组中移除特定的 `QMUIAsset` 对象。
3.  提供了选中图片数量改变时，展示图片数量的 Label 的动画以及图片 checkBox 被选中时的动画。
4.  提供了方法用于储存和获取最近使用过的相簿。

## QMUIImagePickerPreviewViewController

相册选图界面点击小图进去的大图预览界面，包含以下几个特性：

1.  展示图片和视频，支持 Live Photo、Gif，支持手势缩放。
2.  自带顶部 bar，可以显示返回按钮和 checkbox，支持限制单次可选的最大图片数量。

## QMUIImagePreviewView

通用的左右滑动查看大图的控件，支持从指定的某张图开始预览。这个类仅提供最基本的查看图片的功能，更复杂的功能建议通过继承的方式自己创建子类实现。

## QMUIImagePreviewViewController

自带一个 `QMUIImagePreviewView` 的控件，以 `UIViewController` 的形式存在，因此可以当成一个普通的 controller 以 push 或 present 的方式开始图片预览，若使用 present，则开始/结束动画支持两种：

1.  从界面上图片原来所处的位置放大到屏幕中央开始预览。
2.  直接在屏幕中央渐现开始预览。

## QMUIKeyboardManager

提供更便捷的方式管理键盘事件，包括第三方键盘、iPad Pro 的外接键盘等场景。主要功能包括：

1.  更加方便的获取系统 UserInfo 携带的信息。
2.  可以设置只接受某些 UIResponder 产生的键盘通知事件。
3.  提供多个常用工具方法，例如判断键盘是否当前可见、获取键盘可见高度以及获取键盘的私有 view 等等。

## QMUILabel

在 `UILabel` 的基础上增加了 2 个特性：

1.  支持设置文字的 padding。
2.  支持长按复制文本，且可修改弹出的 menu 的复制 item 文本及长按时的背景色。

## QMUIMarqueeLabel

跑马灯效果的 label。

## QMUIModalPresentationViewController

一个提供通用的弹出浮层功能的控件，可以将任意 `UIView` 或 `UIViewController` 以浮层的形式显示出来并自动布局。支持 3 种方式来显示浮层：

1.  **推荐**新起一个 `UIWindow` 盖在当前界面上，将 `QMUIModalPresentationViewController` 以 `rootViewController` 的形式显示出来，支持横竖屏自动调整方向和布局，不支持在浮层不消失的情况下做界面切换（因为 window 会把背后的 controller 盖住，看不到界面切换）。
2.  使用系统的 `presentViewController:animated:completion:` 方法来显示，支持界面切换。**注意** 使用这种方法必定只能以动画的形式来显示浮层，无法以无动画的形式来显示，并且 `animated` 参数必须为 `NO`。
3.  将浮层作为一个 subview 添加到 `superview` 上，从而能够实现在浮层不消失的情况下进行界面切换，但需要 `superview` 自行管理浮层的大小和横竖屏旋转，而且 `QMUIModalPresentationViewController` 不能用局部变量来保存，会在方法执行完后被释放，所以需要自行 retain。

除了显示方式外，`QMUIModalPresentationViewController` 还支持几个特性：

1.  通过 `layoutBlock` 支持自定义的布局，并支持兼容键盘的显隐。
2.  通过 `showingAnimation` 支持自定义显示动画，并支持兼容键盘的显隐。
3.  通过 `hidingAnimation` 支持自定义隐藏动画，并支持兼容键盘的显隐。
4.  支持对全局的 `QMUIModalPresentationViewController` 的管理，包括判断当前是否有任一浮层正在显示、隐藏所有正在显示的浮层等。

## QMUIMoreOperationController

常见的那种“更多操作”的面板，例如系统的图片分享。面板支持多行展示 item，底部显示一个取消按钮。支持动态插入/修改操作按钮的位置和内容。

## QMUIMultipleDelegates

Objective-C 的 Delegate 设计模式里，一个 delegate 仅支持指向一个对象，这为接口设计带来很大的麻烦（例如你很难做到在 textField 内部自己管理可输入的最大字符的限制的同时，又支持外部设置一个自己的 delegate），因此提供了这个控件，支持同时将 delegate 指向多个 object。

## QMUINavigationController

对应系统的 `UINavigationController`，建议作为项目里的所有 navigationController 的基类。通常搭配 `QMUICommonViewController` 来使用，提供的功能包括：

1.  方便地控制前后界面切换时的状态栏样式（例如前一个界面需要黑色，后一个界面需要白色）。
2.  控制导航栏的显隐、颜色、背景、分隔线等。
3.  当界面切换时，前后界面的导航栏样式不同，则允许提供一种更加美观的切换效果，以同时展示两条不同的导航栏。
4.  提供 `willShow`、`didShow`、`willPop`、`didPop` 等时机给 `viewController` 使用。

## QMUINavigationTitleView

可作为 `navigationItem.titleView` 的标题控件，提供的功能包括：

1.  支持显示主标题、副标题、左边的 loading、右边的附加 view（`accessoryView`）。
2.  主副标题支持水平布局和垂直布局。
3.  `accessoryView` 默认支持下拉箭头的样式，也可自定义。

## QMUIPieProgressView

一个饼状的进度条控件，支持通过 `tintColor` 修改进度条的颜色。

## QMUIPopupContainerView

带箭头的小tips浮层，自带 imageView 和 textLabel，可展示简单的图文信息，可选择优先在目标位置的上方或下方显示，若优先考虑的方向放不下，则会尝试在另外的方向显示。若要展示复杂的内容，请通过子类继承的方式实现。

## QMUIPopupMenuView

一个基于 QMUIPopupContainerView 实现的弹出浮层菜单控件，支持按 section 来划分菜单选项。

## QMUISearchBar

具备 QMUIConfigurationTemplate 内设定的全局样式的搜索框，可参考 `UISearchBar(QMUI)`。

## QMUISearchController

1.  支持展示一个类似“最近搜索”的面板。
2.  支持展示一个空界面用于处理搜索中、搜索为空、搜索失败等场景。

## QMUISegmentedControl

用于代替系统的 `UISegmentedControl`，相比 `UISegmentedControl` 支持了更多的功能，有两种使用方式：

1.  重新渲染 `UISegmentedControl` 的 UI，可以比较大程度地修改样式。比如 `tintColor`，`selectedTextColor` 等参数。
2.  用图片而非 `tintColor` 来渲染 `UISegmentedControl` 的 UI，支持非选中/选中状态的背景图，item 之间的分割线，字体颜色等参数。

## QMUISlider

相比系统的 `UISlider`，支持更方便地修改样式，包括背后导轨的高度、圆点的大小及阴影等。

## QMUIStaticTableViewCellData / QMUIStaticTableViewCellDataSource

用于方便地实现类似系统设置的列表。

## QMUITabBarViewController

对应系统的 `UITabBarController`，优化对横竖屏逻辑，横竖屏的方向由 tabBarController 当前正在显示的 controller 来决定。

## QMUITableView

配合 `QMUICommonTableViewController`、`QMUITableViewCell` 系列的类使用，而其本身只提供了去除列表不满一屏的情况下的尾部空行的功能。

## QMUITableViewCell

配合 `QMUITableView` 使用，支持调整 `textLabel`、`detailTextLabel`、`imageView`、`accessoryView` 的间距，支持获取 cell 在当前 section 里的位置（`QMUITableViewCellPosition`）。

## QMUITableViewHeaderFooterView

用于代替系统的 `UITableViewHeaderFooterView`，支持显示一行文字和右边的 `accessoryView`。

## QMUITextField

用于代替系统的 `UITextField`，相比 `UITextField` 支持了更多的功能：

1.  自定义 `placeholderColor`。
2.  自定义 `UITextField` 的文字内边距（文字与输入框之间的空白填充）。
3.  支持限制输入的文字的长度。

## QMUITextView

用于代替系统的 `UITextView`，相比 `UITextView` 支持了更多的功能：

1.  支持 `placeholder` 并支持更改 `placeholderColor`。
2.  支持在文字发生变化时计算内容高度并通知 delegate。
3.  支持限制输入框的最大高度，一般配合第2点使用。
4.  支持限制输入的文本的最大长度，默认不限制。
5.  支持通过 `textViewShouldReturn:` 方法快速监听键盘发送按钮的点击事件，无需自行判断换行符。
6.  优化系统的 UITextView 在文字超过文本框高度时换行的时候文字底部间距没考虑 `textContainerInset.bottom`。
7.  可方便地自定义“粘贴”行为，从而响应一些类似粘贴图片的操作。

## QMUIToastView

用于显示 toast 的控件，其主要特性包括：

1.  以 `backgroundView`、`contentView` 来组织 toast 里的内容，分别用于背景和内容，带有多种接口可以灵活修改样式，具体可参看 `QMUIToastBackgroundView.h` 与 `QMUIToastContentView.h`。也可以由外部提供，更具扩展性。
2.  提供了默认的 toastAnimator 来实现 ToastView 的显示和隐藏动画，具体可参看 `QMUIToastAnimator.h`。也可以通过协议添加自定义动画。

## QMUITips

简单封装了 `QMUIToastView`，支持弹出纯文本、loading、succeed、error、info 等五种 tips。

## QMUIZoomImageView

提供最基础的静态图片、Live Photo、视频的预览和缩放功能，主要特性包括：

1.  可通过双击或双指缩放手势来放大图片/视频。
2.  支持通过修改 `contentMode` 来控制图片/视频的显示模式，具体包括 `UIViewContentModeCenter`, `UIViewContentModeScaleAspectFill`, `UIViewContentModeScaleAspectFit` 三种模式。
3.  可自定义图片/视频的显示区域，从而让你方便地实现诸如头像裁剪之类的功能。
4.  自带 loading、error 等状态的显示支持。

## UIKit Extensions

CAAnimation (QMUI)

1.  支持以 `block` 方式使用 `CAAnimationDelegate`，语法更简洁的同时可以避免 `CAAnimation.delegate` 为 `strong` 带来的内存管理的麻烦。

CALayer (QMUI)

主要功能有：

1.  将某个 `sublayer` 移到所有 `sublayer` 的最前面或最后面。
2.  支持指定某几个角为圆角。
3.  去除隐式动画。
4.  自动保护 `setBounds:`、`setPosition:` 存在 `NaN` 导致的 crash。

NSArray (QMUI)

1.  快速用一个 block 编译多维数组的方法。
2.  将多维数组转换成多维的 mutable 数组。
3.  利用一个 block 过滤数组 item。

NSAttributedString (QMUI)

可以返回在 “中文 = 2 个字符、英文 = 1 个字符” 的情景下的字符长度。

NSObject (QMUI)

主要功能：

1.  对 super 发送消息。
2.  遍历一个 protocol 里的所有方法。
3.  遍历某个 class 的所有成员变量。
4.  遍历某个 class 的所有实例方法。
5.  判断当前类是否有重写某个父类的指定方法。
6.  用 bindXxx 的方式绑定对象、基本数据类型到实例上，省去创建 property 或继承子类的麻烦。

NSMutableParagraphStyle (QMUI)

提供一些便捷方法用于生成一个设置了行高、换行模式、文字对齐方式的段落样式。

NSPointerArray (QMUI)

1.  获取某个 pointer 的 index。
2.  判断是否有包含某个 pointer。

NSString (QMUI)

提供了一些常用的字符串校验和格式化方法：

1.  将字符串拆成数组（类似 JavaScript 的 split 函数）。
2.  判断是否包含某个字符串。
3.  去掉头尾或全部的空白字符。
4.  将换行符替换为空格。
5.  使用正则表达式搜索一段字符。
6.  计算字符串的 md5 值。
7.  把某个十进制数字转换为十六进制数字的字符串，如 10 -> "A"。
8.  以可变参数的形式来拼接字符串。
9.  将秒数转换为数字时钟格式，如"100" -> "01:40"
10.  按照“中文 = 2 字符，英文 = 1 字符”的规则来计算文本长度。
11.  去除一些稀有的[特殊字符](http://www.croton.su/en/uniblock/Diacriticals.html)来避免 UI 上的展示问题。
12.  专门用于处理带 emoji 表情的字符串的裁剪（当字符串中存在 emoji 表情等 `Character Sequences` 时，进行裁剪操作常常会导致 bug，比如一个 emoji 可能占用 1 - 4 长度的字符，如果不慎从中间裁剪掉则会出现乱码）。

NSURL (QMUI)

可通过 `qmui_queryItems` 将一个 url 里的 query 转换成一个 `NSDictionary`。

NSString (QMUI_StringFormat)

提供了一些将 `CGFloat` 或 `NSInteger` 转换为字符串的快捷方法。

UIActivityIndicatorView (QMUI)

支持自定义 `UIActivityIndicatorView` 的大小（系统的 `UIActivityIndicatorView` 默认不支持调整为任意大小）。

UIBarItem (QMUI)

获取 `UIBarButtonItem`、`UITabBarItem` 内部的 `view`。

UIBezierPath (QMUI)

快捷地创建一条矩形路径，矩形四个角的圆角支持不同大小的值。

UIButton (QMUI)

主要功能有：

1.  方便的初始化方法 `initWithImage:title:`。
2.  将 `UIButton` 高度一键设置为单行文字时的高度，从而可在“ button 宽度固定、高度自适应”的布局场景中完全省去 `sizeToFit` / `sizeThatFits:` 的相关代码。
3.  直接为不同 state 设置不同的 titleAttributes，无需自行构造 `NSAttributedString`。
4.  判断是否有设置过某个 state 下的某个属性。

UICollectionView (QMUI / QMUIIndexPathHeightCacheInvalidation)

提供了一些实用方法：

1.  取消所有 item 的选中态，一般用于从子界面返回到 `collectionView` 时。
2.  在维持 item 已有的选中态不变的情况下进行 `reloadData` 的操作。
3.  获取某个 view 所属的 item 的 indexPath，典型的使用场景如：在某个 view 的点击事件回调方法中拿到这个 view ，进而通过这个方法拿到所属的 indexPath。
4.  判断某个 indexPath 的 item 是否处于可视区域。
5.  获取可视区域内的第一个 cell （系统的 `indexPathsForVisibleItems` 方法返回的数组成员是无序排列的，不能直接通过 `firstObject` 拿到第一个 cell ）。

UICollectionView (QMUIKeyedHeightCache / QMUIIndexPathHeightCache / QMUILayoutCell)

提供了一系列方法来方便计算 cell 的高度，并通过 indexPath 或 key 缓存起来。

UIColor (QMUI)

提供了一些实用方法：

1.  支持在 HEX 格式的字符串（例如 `@"#ff0000"`）和 `UIColor` 对象之间互相转换。
2.  获取某个 `UIColor` 对象当前的 RGBA 通道及 HSB 的值。
3.  支持去掉颜色中的 alpha 通道（也即把 alpha 强制设为 1.0）。
4.  计算当前颜色叠加了 alpha 后放在指定的背景色上合成后的色值。
5.  计算颜色 A 和颜色 B 之间某个指定百分比的过渡色。
6.  计算两个颜色叠加后的颜色。
7.  获取当前颜色的反色。
8.  判断当前颜色属于深色或浅色。
9.  产生一个随机色，一般用于调试行为。

UIControl (QMUI)

支持的功能包括：

1.  支持通过 block 形式添加点击事件。
2.  优化控件在 UIScrollView 里的点击响应速度（UIScrollView 默认会带 300ms 的延迟，所以快速点击控件时，可能看不到 highlighted 的过程）。
3.  调整控件的点击响应范围，一般用于加大小按钮的点击范围。
4.  支持方便地在 highlighted 时做一些事情，而不用继承一个子类。

UIFont (QMUI)

支持的功能包括：

1.  创建一个细体的系统字体。
2.  创建一个在系统当前的动态字体设置情况下对应的字体（如果使用了系统的动态字体设置，则每一个 `fontSize` 都会被转换为另一个大小的值）。

UIImage (QMUI)

提供了一些实用方法：

1.  计算当前图片的平均色，配合 `[UIColor colorIsDark]` 就能更好地为图片上方的内容选择一个颜色来展示。
2.  置灰当前图片。
3.  为当前图片添加透明度。
4.  将当前图片的颜色换成另一个颜色（仅对路径生效）。
5.  将当前图片的颜色换成另一个颜色（不影响图片内容）。
6.  在图片 A 上叠一张图片 B。
7.  扩大图片四周的空白区域（常用于 `NSAttributedString` 里图文混排时做图片与文字之间的间距）。
8.  裁剪出图片内指定矩形区域的内容。
9.  将图片缩放到某个指定的大小。
10.  在图片上叠加一条路径，路径可指定宽度及颜色等。
11.  将图片裁剪成带圆角的图片。
12.  在图片的四周加上边框。
13.  用一张图当成遮罩，合并到另一张图上，得到一张新图。
14.  快速绘制一张指定大小、颜色、形状（默认支持矩形、三角形、椭圆、箭头、关闭按钮等）的图片。
15.  将 `NSAttributedString` 转换成 `UIImage`。
16.  对某个 `UIView` 截图。

UIImageView (QMUI)

让 `UIImageView` 的宽高比例调整为和图片的宽高比例一致，同时不超过给定的大小。

UILabel (QMUI)

提供了一些实用方法：

1.  通过传入一个字体和颜色，快速初始化一个 `UILabel`。
2.  复制 labelA 的样式到 labelB。
3.  计算 label 在当前样式和文字的设定下的单行高度，常用于设计上不会换行的场景下节省对 label 的宽高计算。
4.  优化 `UILabel` 在显示中文字符时的渲染性能。
5.  通过 `textAttributes` 属性设置 label 的文字样式，无需自行构造 `NSAttributedString`。

UINavigationController (NavigationBarTransition)

优化 `UINavigationController` 在 push/pop 过程中如果前后两个界面的导航栏样式不一致时的样式问题。

UINavigationController (QMUI)

提供了一些实用方法：

1.  判断当前是否正在进行 push/pop 操作。
2.  获取 `rootViewController`。
3.  允许拦截系统返回按钮的事件（包括手势返回）。
4.  允许强制开启手势返回（系统的 `UINavigationController` 在你使用了自定义的返回按钮或隐藏了导航栏的情况下，会屏蔽手势返回）。

UIScrollView (QMUI)

提供了一些实用方法：

1.  判断当前是否已经滚到顶部/底部。
2.  判断当前的 scrollView 可滚动。
3.  将 scrollView 滚到最顶部/最底部。
4.  立即中止 scrollView 的滚动。

UISearchBar (QMUI)

1.  支持修改文字颜色和 placeholder 颜色。
2.  支持快速将一个普通的 `UISearchBar` 按照 `QMUIConfigurationTemplate` 的全局样式进行格式化。
3.  支持获取 `searchBar` 内部的一些私有 view，例如背景容器、输入框、取消按钮、segmentedControl 等。
4.  支持调整 `searchBar` 内输入框的布局。

UITabBarItem (QMUI)

1.  提供方法用于快速获取 `UITabBarItem` 里的 `barButton` 和 `imageView`，以便做一些自定义的操作，例如添加未读数字等。
2.  支持监听双击事件。

UITableView (QMUI)

1.  获取某个 view 在 tableView 里的 indexPath，例如你点击了某个 cell 上的按钮，则在按钮的事件处理方法里就能利用这个特性方便地得到按钮所在的 indexPath。
2.  计算某个 view 处于当前 tableView 里的哪个 `sectoinHeaderView` 内。
3.  计算某个 cell 在它所在的 section 里的相对位置（`QMUITableViewCellPosition`），这样你就可以方便地为“第一行或最后一行的 cell”做特殊处理。
4.  判断给定的 indexPath 是否处于可视区域。
5.  取消当前列表的 cell 选中状态。
6.  方便地将某个 indexPath 所在的 cell 滚动到列表上的指定位置。
7.  判断 tableView 是否可滚动。
8.  配合 `QMUITableViewCell`、`QMUICellHeightKeyCache`、`QMUICellHeightIndexPathCache` 实现对 cell 高度的动态计算和缓存。

UIView (QMUI)

提供的功能包括：

1.  便捷的布局方法，例如快速设置宽高，兼容同时使用 `transform` 和 `frame` 等。
2.  让所有的 `UIView` 都支持在上下左右显示边框，边框大小、颜色支持自定义，可以省去专门用一个 view 去实现分隔线的场景。
3.  调试用，可让自身及内部所有 subview 都显示随机的背景色，方便查看布局关系。
4.  获取当前 view 所在的 viewController。
5.  判断当前 view 是否已处于 view 层级树里并可视。
6.  判断当前的 view 是否有重写对应的 UIKit 父类的某些方法。
7.  更优雅的接口设计，用于以动画和非动画的方式执行一些操作。
8.  自动保护 `setFrame:` 时存在 `NaN` 的值引发的 crash。
9.  以 `block` 的形式监听某些常用的时机，例如 `frame`、`tintColor`的变化，以及 `hitTest` 的重写等。

UIViewController (QMUI)

提供的功能包括：

1.  获取当前界面所处的 `navigationController` 堆栈里的上一个 `viewController`。
2.  获取当前界面所处的 `navigationController` 堆栈里的上一个 `viewController` 的标题，可用于设置当前界面的返回按钮的文字。
3.  获取当前 `viewController` 里的最高层可见的 `viewController`。
4.  区分当前界面是被 push 进来的还是被 present 起来的。
5.  通过 `qmui_visibleState` 获取当前的生命周期阶段，通过 `qmui_visibleStateDidChangeBlock` 监听生命周期的变化，省去继承重写 viewWillXxx/viewDidXxx 系列方法的麻烦。
6.  判断当前界面是否已经被加载并且处于可见状态，常用于一些消息通知的处理方法里提前判断，避免在界面不可见时做一些浪费的事情。
7.  判断当前界面是否有重写系统 `UIViewController` 的某些方法。

UIWindow (QMUI)

1.  可控制一个满屏的 window 是否应该夺取状态栏的控制权。