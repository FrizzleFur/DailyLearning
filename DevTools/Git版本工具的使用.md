# Git版本工具的使用


## git 为不同的项目设置不同的用户名和邮箱

![](oc98nass3.bkt.clouddn.com/15380102461500.jpg)

![](oc98nass3.bkt.clouddn.com/15380102181054.jpg)

1. 到`.git`文件夹📂中查看config文件。
```
cd .git 
cat config
```

```
[core]
	repositoryformatversion = 0
	filemode = true
	bare = false
	logallrefupdates = true
	ignorecase = true
	precomposeunicode = true
[remote "origin"]
	url = git@code.aliyun.com:fenke-ios/Avenger.git
	fetch = +refs/heads/*:refs/remotes/origin/*
[branch "develop"]
	remote = origin
	merge = refs/heads/develop
[user]
	name = xxxx
	email = xxxx@xxxx.com
[difftool "tower"]
	cmd = \"/Applications/Tower.app/Contents/Resources/filemerge.sh\" \"$LOCAL\" \"$REMOTE\"
```

1，找到项目所在目录下的 .git/文件夹，进入.git/文件夹，然后执行如下命令分别设置用户名和邮箱：

```bash
git config user.name "moonlight"
```

```bash
git config user.email "15090552277@163.com"
```

然后执行命令查看config文件：cat config

发现里面多了刚才配置的用户名和邮箱信息，即成功为该项目单独设置了用户名和邮箱

```
[core]	repositoryformatversion = 0	filemode = true	bare = false	logallrefupdates = true	ignorecase = true	precomposeunicode = true[remote "origin"]	url = https://github.com/552277/calendar.git	fetch = +refs/heads/*:refs/remotes/origin/*[branch "master"]	remote = origin	merge = refs/heads/master[user]	name = moonlight	email = 15090552277@163.com
```

2，如果为所有项目设置默认的用户名和邮箱，则执行如下命令(即多了"--global"修饰，添加为全局变量)：

```bash
git config --global user.name"moonlight"git config --global user.email"15090552277@163.com"
```

## **附：** 如果git pull 每次都要求输入用户名和密码，则可以执行如下配置

```
git config --global credential.helper store
```

执行后， cat config查看，则多了下面的内容：

[credential]
        helper = store

```
[user]        name = xxxx        email = xxxxg@xx.com[credential]        helper = store
```

然后再回到项目目录下执行git pull，根据提示输入用户名和密码，输入正确后，以后再执行git pull 就不用输入用户名和密码了



## 参考

1. [git 为不同的项目设置不同的用户名和邮箱 - CSDN博客](https://blog.csdn.net/qq_2300688967/article/details/81094140)