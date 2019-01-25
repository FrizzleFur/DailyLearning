## Jenkins

![](https://i.imgur.com/Axb92E7.jpg)

[Jenkins自动打包代替Xcode的Archive - 简书](https://www.jianshu.com/p/91e8f571fc2b)

5、接着新建一个终端窗口 输入命令行 open /Users/管理员用户名/Library/Keychains

![](https://i.imgur.com/Zo06F08.jpg)


## Keychains and Provisioning Profiles Management

![](https://i.imgur.com/9fGMxcz.jpg)
![](https://i.imgur.com/FC1uH2Z.jpg)

### Keychains 管理
[Keychains and Provisioning Profiles Plugin - Jenkins - Jenkins Wiki](https://wiki.jenkins.io/display/JENKINS/Keychains+and+Provisioning+Profiles+Plugin)

### Provisioning Profiles Directory Path	
```
~/Library/MobileDevice/Provisioning Profiles
```


### login.keychain

login.keychain的路径是

```
~/library/keychains/login.keychain
```

解锁密码是电脑锁定密码


### 密码修改

If you have installed Jenkins through HomeBrew, check
```
/Users/YOURUSERNAME/.jenkins/secrets/initialAdminPassword
```
进入到'用户列表'页面，点击要修改密码的用户那一列后面的修改图标:
![](http://oc98nass3.bkt.clouddn.com/2017-08-08-15021741288053.jpg)
![](http://oc98nass3.bkt.clouddn.com/2017-08-08-15021741379382.jpg)

#### 删除用户

[How to remove a user from Jenkins - Stack Overflow](https://stackoverflow.com/questions/14731209/how-to-remove-a-user-from-jenkins)

```
http://<jenkins.url>/user/<username>/delete
```

### Cocoapods打包: Xcode构建前的shell代码:

```
#bin/bsah - l

export LANG=en_US.UTF-8

export LANGUAGE=en_US.UTF-8

export LC_ALL=en_US.UTF-8

cd $WORKSPACE/你的项目名称

/usr/local/bin/pod update --verbose --no-repo-update
```

### 设置打包包名

[reference-xcode-version-number-from-jenkins](https://stackoverflow.com/questions/24536041/reference-xcode-version-number-from-jenkins)
If you are using the Xcode Plugin, you have CFBundleVersion available as $VERSION and CFBundleShortVersionString as $SHORT_VERSION.
I found $SHORT_VERSION by searching the XCode Plugin source code.

#### .ipa 命名格式


注意下载`Build Timestamp Plugin`插件
```
${JOB_NAME}_V${SHORT_VERSION}_${BUILD_TIMESTAMP}
```

### Jenkins启动关闭

#### 在浏览器中：URL Options

`http://[jenkins-server]/[command]`
[command] can be

* exit: shutdown jenkins
* restart: restart jenkins
* reload: to reload the configuration

URL:
```
http://<jenkins.server>/restart
http://<jenkins.server>/safeRestart
http://<jenkins.server>/exit
http://<jenkins.server>/safeExit
http://<jenkins.server>/quietDown
http://<jenkins.server>/cancelQuietDown
``` 

#### 使用终端命令行

```
service jenkins start/stop/restart
```
* quietDown: Put Jenkins in a Quiet mode, in preparation for a restart. In that mode Jenkins don’t start any build
* cancelQuietDown: Cancel the effect of the “quiet-down” command
* safeRestart: Puts Jenkins into the quiet mode, wait for existing builds to be completed, and then restart Jenkins
* safeExit: Puts Jenkins into the quiet mode, wait for existing builds to be completed, and then shut down Jenkins
* These commands obey the security rules defined by the Authorization Strategy set up in Jenkins. Only user(s) with the required permission can use the following commands:


### [使用脚本上传ipa](http://www.cnblogs.com/xiaobaizhu/p/5715755.html)

```
# 这步操作解锁keychain，login.keychain的路径是${HOME}/library/keychains，123456是开机的密码
security unlock-keychain -p 123456 ${HOME}/library/keychains/login.keychain
# 工程名
APP_NAME="GitSearch"
#修改打包类型
TARGET_NAME="GitSearch
  #证书   CODE_SIGN_DISTRIBUTION="iPhone Distribution: XXXXX Inc. (R9JN3XXXX)"   provisoning_profile="942daf9e-2925-4fca-9afd-278e60b821e6"
  #切换手动选择证书模式（在xcode配置中取消Automatically manage signing，不然会报错！）   sed -i "" s/'ProvisioningStyle = Automatic;'/'DevelopmentTeam = R9JN3XXXX;ProvisioningStyle = Manual;'/g ${APP_NAME}.xcodeproj/project.pbxproj
  sed -i "" s/'PROVISIONING_PROFILE = "";'/'PROVISIONING_PROFILE = "$provisoning_profile";'/g ${APP_NAME}.xcodeproj/project.pbxproj
  sed -i "" s/'PROVISIONING_PROFILE_SPECIFIER = "";'/'PROVISIONING_PROFILE_SPECIFIER ="xxxx_CI_Distribution";'/g ${APP_NAME}.xcodeproj/project.pbxproj
  sed -i "" s/'DEVELOPMENT_TEAM = "";'/'DEVELOPMENT_TEAM = R9JN3XXXX;'/g ${APP_NAME}.xcodeproj/project.pbxproj
#info.plist路径
project_infoplist_path="./${APP_NAME}/${TARGET_NAME}-Info.plist"
#取版本号
bundleShortVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" "${project_infoplist_path}")
#取build值
bundleVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" "${project_infoplist_path}")
DATE="$(date +%Y_%m_%d_%H_%M)"
FILENAME="${DATE}"
#自己定义fir的token和appid
FIRTOKEN = "863efefc2c22d4b761c096e6af9a6024"
FIRAPPID = "5933aa88548b7a57ff000059"

export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

echo "=================pod install================="
pod install

echo "=================clean================="
xcodebuild -workspace "${APP_NAME}.xcworkspace" -scheme "${APP_NAME}"  -configuration 'Release' clean


echo "+++++++++++++++++build+++++++++++++++++"
xcodebuild archive -workspace "${APP_NAME}.xcworkspace" -scheme "${APP_NAME}" -configuration 'Release' -archivePath "./build/${FILENAME}/${APP_NAME}.xcarchive" CODE_SIGN_IDENTITY="$CODE_SIGN_DISTRIBUTION" PROVISIONING_PROFILE="$provisoning_profile"

echo "+++++++++++++++++archive && 导出ipa文件++++++++++++++++++"
#export_plist一定要有，请自行百度
xcodebuild -exportArchive -archivePath "./build/${FILENAME}/${APP_NAME}.xcarchive" -exportPath "./build/${FILENAME}"  -exportOptionsPlist "./export_plist/${TARGET_NAME}.plist" CODE_SIGN_IDENTITY="$CODE_SIGN_DISTRIBUTION" PROVISIONING_PROFILE="$provisoning_profile"
echo "+++++++++++++++++复制到桌面++++++++++++++++++"

rm -r -f ${HOME}/Desktop/Package/${APP_NAME}.ipa
mkdir ${HOME}/Desktop/Package
cp -R ./build/${FILENAME}/${APP_NAME}.ipa ${HOME}/Desktop/Package
#fir上传不一定能成功，可以使用插件
fir p "./build/${FILENAME}/${APP_NAME}.ipa" -T "${FIRTOKEN}" -Q
fir login ${FIRTOKEN}

echo "+++++++++++++++++蒲公英++++++++++++++++++"

curl -F "file=@/Users/next_mac_mini/Desktop/Package/${APP_NAME}.ipa" -F "uKey=d81326899dd50c3382e2f5e99f3a7495" -F "_api_key=495642f9b1336a64ceb2d5cb44d93183" http://www.pgyer.com/apiv1/app/upload
```

### output dir

```
${WORKSPACE}/build
```

* Xcode Scheme File: 关于这个其实对应的就是xcodebuild命令中的-scheme的参数

如果您不知道要填写什么的话， 可以通过xcodebuild -list来查询。是不是觉得这条命令很熟悉，没错前面查找target的时候也是用这个命令！



### Error 
[iOS持续集成简述 - 简书](https://www.jianshu.com/p/f44d746ff8a9)

```
FATAL: No global development team or local team ID was configured.
```
* Team ID 在这里填写，如图：

![TeamID](http://oc98nass3.bkt.clouddn.com/2017-08-08-15021737969197.jpg)



## Jenkins配置

```
#bin/bsah - l

export LANG=en_US.UTF-8

export LANGUAGE=en_US.UTF-8

export LC_ALL=en_US.UTF-8

cd $WORKSPACE/$PROJECTNAME

/usr/local/bin/pod update --verbose --no-repo-update

export LANG=en_US.UTF-8

export LANGUAGE=en_US.UTF-8
```


#### ipa名称

```
${JOB_NAME}_V${SHORT_VERSION}_${BUILD_DATE}
```


### Cocoapod

项目用到cocoapods，所以要先在构建这里选执行脚本，在里面输入

### Pod脚本
![](https://i.imgur.com/eUeiX0i.jpg)


```
#bin/bsah - l

export LANG=en_US.UTF-8

export LANGUAGE=en_US.UTF-8

export LC_ALL=en_US.UTF-8

cd $WORKSPACE/$PROJECTNAME

/usr/local/bin/pod update --verbose --no-repo-update

export LANG=en_US.UTF-8

export LANGUAGE=en_US.UTF-8
```

```
#bin/bsah - lexport LANG=en_US.UTF-8export LANGUAGE=en_US.UTF-8export LC_ALL=en_US.UTF-8cd $WORKSPACE/你的项目名称/usr/local/bin/pod update --verbose --no-repo-update注意：没有#bin/bsah - lexport LANG=en_US.UTF-8export LANGUAGE=en_US.UTF-8export LC_ALL=en_US.UTF-8   /usr/local/bin/  
```
这几句可能会造成编译器读不懂pod语句。当你构建的时候提示pod语句出错，百分之九十都是这个错误。


## Xcode Plugin配置参数

[Xcode Plugin - Jenkins - Jenkins Wiki](https://wiki.jenkins.io/display/JENKINS/Xcode+Plugin)
[jenkins+xcode+蒲公英实现ipa自动化打包 - 简书](https://www.jianshu.com/p/6bab38e569a5)

Advanced Xcode build options(xcodebuild命令的配置)
•   Clean test report?:这个是如果要用到xcode测试的时候才用到，意思就跟英语一样
•   Xcode Scheme File: 关于这个其实对应的就是xcodebuild命令中的-scheme的参数
如果您不知道要填写什么的话， 可以通过xcodebuild -list来查询。是不是觉得这条命令很熟悉，没错前面查找target的时候也是用这个命令！
•   SDK：这里是xcodebuild命令中的-sdk的参数，指定编译和打包的sdk号。如果不懂可以填写哪些可以通过xcodebuild -showsdks来查看。
•   SYMROOT:该变量是编译和打包产生结果的输出目录（ .a, .zip, .ipa, .hmap等产生文件的位置），其中该目录其实是包括了CONFIGURATION BUILD DIR和OBJROOT这两个目录，默认的路径是所编译的xcodeproj所在目录，如主项目和POD项目整合后，则会在主项目的和POD项目的XCODEPROJ所在目录
如果在指定了OBJROOT的位置后，编译过程中产生的文件不会在该目录体现 如果在指定CONFIGURATION_BUILD_DIR的位置后，该变量则变成无效化
•   Custom xcodebuild arguments:这个就是xcodebuild命令中的指定buildsetting的命令的参数，至于可以指定哪些参数请不要问我，可以找度娘或者谷哥
•   Xcode Workspace File:该配置是指明了xcodebuild中的-workspace的变量，其实就是如果您需要编译打包一个workspace时候的时候指定那个后缀名为xcworkspace的文件， 如果指定了该配置，那么Xcode project file配置项将无效
•   Xcode Project Directory：该目录是指明了包含xcodeproj文件的目录（这个我是没用用到如果用了该参数可能最开始第一步的构建就没用了------不过我还没证实，欢迎小伙伴证实后告诉我）
•   Xcode Project File: 如果需要构建一个project而不是一个workspace的话则指定文件的名称（后缀名为xcodeproj的文件）
•   Build output directory：该参数只是指明了最终需要产生的动态包，ipa，app等文件默认路径为所编译的xcodeproj所在目录，如主项目和POD项目整合后，则会在主项目的和POD项目的XCODEPROJ所在目录（编译产生的相关文件所在目录，默认为$SYMROOT/$CONFIGURATION）
•   值得说的是有一个参数也是挺常用的就是OBJROOT，该参数是产生 .a和 .hmap文件的目录，默认路径为所编译的xcodeproj所在目录，如主项目和POD项目整合后，则会在主项目的和POD项目的XCODEPROJ所在目录，关于OBJROOT、CONFIGURATION BUILD DIR以及SYMROOT三个路径之间的关系大家可以去查看官方的文档。


## FirIm插件

[fir.im Jenkins 插件使用方法](http://blog.fir.im/jenkins/)


## 配置

![1-构建设置](https://i.imgur.com/5bTFNkz.jpg)
![2-打包设置](https://i.imgur.com/tH17OOc.jpg)
![3-构建脚本](https://i.imgur.com/sgS6Vsc.jpg)
![4-通用设置](https://i.imgur.com/ZeCWcAD.jpg)
![5-Keychain](https://i.imgur.com/ZSJMIFz.jpg)
![6-Xcode设置](https://i.imgur.com/9hNKTyP.jpg)
![7-构建后Fir设置](https://i.imgur.com/FEMyzUg.jpg)
![8-Fir插件](https://i.imgur.com/2IIrVCU.jpg)


## 问题

1. No global keychain or local keychain path/password was configured.

![](https://i.imgur.com/6uAp95h.jpg)
解决：
![](https://i.imgur.com/Z9eX5cP.jpg)

2. Will not set default: file /Users/Shared/Jenkins/Library/Keychains/login.keychain-db is owned by UID=0, but we have UID=262 security: SecKeychainSetDomainDefault user: write permissions error

解决：进入mac 系统偏好设置 — 用户与群组 — 其他用户 — jenkins ，勾选允许用户管理这台电脑


## 参考

1. [IOS 自动化部署 - 最新Jenkins + git +cocoapods + fir - 简书](http://www.jianshu.com/p/ccc97e7ecf15)
1. [jenkins+xcode+蒲公英实现ipa自动化打包 - CocoaChina_让移动开发更简单](http://www.cocoachina.com/ios/20170811/20218.html)
1. [手把手教你利用Jenkins持续集成iOS项目](http://www.jianshu.com/p/41ecb06ae95f)
2. [Mac下Jenkins+SVN+Xcode构建持续导出环境](http://www.jianshu.com/p/c0955ff67c91)
3. [mac jenkins iOS持续集成中的坑](https://my.oschina.net/u/2359371/blog/804357)
4. [**nomad**shenzhen](https://github.com/nomad/shenzhen/issues/236#issuecomment-88688098)
5. [**Jenkins:”ResourceRules.plist: cannot read resources” error after Xcode 6.1**](http://stackoverflow.com/questions/26516442/how-do-we-manually-fix-resourcerules-plist-cannot-read-resources-error-after)
6. [--resource-rules has been deprecated in mac os x >= 10.10](http://stackoverflow.com/questions/26459911/resource-rules-has-been-deprecated-in-mac-os-x-10-10)
7. [installing-jenkins-os-x-homebrew](http://flummox-engineering.blogspot.com/2016/01/installing-jenkins-os-x-homebrew.html)
