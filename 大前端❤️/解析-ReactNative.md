
# ReactNative


## 搭建ReactNative

### 问题1： 'boost/iterator/iterator_adaptor.hpp' file not found #14423

['boost/iterator/iterator_adaptor.hpp' file not found · Issue #14423 · facebook/react-native](https://github.com/facebook/react-native/issues/14423)

下载了一个`Sample`项目，发现`main.jsbundle`文件缺失

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/2017-06-15-14975313213148.jpg)

接着报错Command failed: /usr/libexec/PlistBuddy -c Print:CFBundleIdentifier build/Build/Products/Debug-iphonesimulator/boostless.app/Info.plist
Print: Entry, ":CFBundleIdentifier", Does Not Exist

，找到问题facebook/react-native的Github地址，发现说，可能是node下载的问题，没有下载好`boost`，建议去下载好`boost`放在项目的thirdParty中，我一看，发现下载下来的`boost`解压后有500多M.而目前目录中的只有20M.果然是缺失了。

Download+extract boost 1.63 and copy to node_modules/react-native/third-party/boost_1_63_0

Additional Information

React Native version: 0.45.0
Platform: iOS
Development Operating System: macOS Sierra, 10.12.5
Dev tools: Xcode 8.3.2 (8E2002)



安装好后，`main.jsbundle`文件还是缺失，但是可以跑起来了



###  问题2 ：Packager can't listen on port 8081
Most likely another process is already using this port
Run the following command to find out which process:

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/qiniu/2017-06-15-14975330229894.jpg)


