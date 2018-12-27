# App发布到AppStore

[Publishing to the App Store - Part 1: Getting Started](https://videos.raywenderlich.com/courses/71-publishing-to-the-app-store/lessons/1)

##  Certificate

* development: for install to your own device to debugging.

* distribution: for submit to the App Store.


### 申请`Certificate`流程

> 从Mac上生成一个文件，上传到Apple服务器，获取对应的证书

1. 添加`Certificate`
![](http://oc98nass3.bkt.clouddn.com/2017-06-15-14974990735698.jpg)

2. Generate a `Certificate Signing Request` from your Mac.
![](http://oc98nass3.bkt.clouddn.com/2017-06-15-14974991135924.jpg)

![](http://oc98nass3.bkt.clouddn.com/2017-06-15-14974991581842.jpg)

![](http://oc98nass3.bkt.clouddn.com/2017-06-15-14974991670104.jpg)

3. 申请生产证书

![](http://oc98nass3.bkt.clouddn.com/2017-06-15-14974992706346.jpg)

* development 和 distribution 证书
![](http://oc98nass3.bkt.clouddn.com/2017-06-15-14974992832680.jpg)


### 注册设备


获得设备的`Device UUID`

![](http://oc98nass3.bkt.clouddn.com/2017-06-15-14974993976052.jpg)


###  AppID 

AppID = TeamID "prefix by default" + BunldeId"suffix by you".
![](http://oc98nass3.bkt.clouddn.com/2017-06-15-14975025038407.jpg)

1. Create App ID 
![](http://oc98nass3.bkt.clouddn.com/2017-06-15-14975018659459.jpg)


### Provisioning Profiles

`Provisioning Profiles` = `Certificate` + `Device identifiers` + `App ID`

 * development : build and test versions of an app during the development process.
 * distribution : submitting your app to the App Store or beta testers. 

