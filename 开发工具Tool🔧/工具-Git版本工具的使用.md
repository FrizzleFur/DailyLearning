# Git版本工具的使用


## git 为不同的项目设置不同的用户名和邮箱

![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/15380102461500.jpg)

![](http://pic-mike.oss-cn-hongkong.aliyuncs.com/15380102181054.jpg)

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
	url = git@xxxx.com:xxxx.git
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



##  多个email的删除

![](https://i.loli.net/2018/11/11/5be81a195d4cd.jpg)


1. 直接编辑 config文件

Use git config -e and you should see something like:


```
[user]
    name = Shani
    name = shani
    name = shani
Delete the lines you don't want.

```

[git config - Delete username from a Git repository - Stack Overflow](https://stackoverflow.com/questions/6243407/delete-username-from-a-git-repository)


2. 使用unset、replace-all命令

```
git config --local --unset-all user.name
git config --local --replace-all user.name "New User Name"
```

## Git 合并部分文件


[Git合并指定文件到另一个分支 - yeahlife的个人页面 - 开源中国](https://my.oschina.net/yeahlife/blog/1927880)

经常被问到如何从一个分支合并特定的文件到另一个分支。

其实，只合并你需要的那些commits，不需要的commits就不合并进去了。

合并某个分支上的单个commit
首先，用git log或sourcetree工具查看一下你想选择哪些commits进行合并，例如：

比如feature 分支上的commit 82ecb31 非常重要，它含有一个bug的修改，或其他人想访问的内容。

无论什么原因，你现在只需要将82ecb31 合并到master，而不合并feature上的其他commits，

所以我们用git cherry-pick命令来做：

git checkout master
git cherry-pick 82ecb31
这样就好啦。现在82ecb31就被合并到master分支，并在master中添加了commit（作为一个新的commit）。

cherry-pick 和merge比较类似，

如果git不能合并代码改动（比如遇到合并冲突），git需要你自己来解决冲突并手动添加commit。

这里git cherry-pick每次合并过来会显示文件冲突(其实并没有冲突代码部分，只需手动解决既可)

合并某个分支上的一系列commits
在一些特性情况下，合并单个commit并不够，

你需要合并一系列相连的commits。这种情况下就不要选择cherry-pick了，rebase 更适合。

还以上例为例，假设你需要合并feature分支的commit76cada ~62ecb3 到master分支。

首先需要基于feature创建一个新的分支，并指明新分支的最后一个commit：

git checkout featuregit
git checkout -b newbranch 62ecb3
然后，rebase这个新分支的commit到master（--ontomaster）。

76cada^ 指明你想从哪个特定的commit开始。

git rebase --onto master 76cada^
得到的结果就是feature分支的commit 76cada ~62ecb3 都被合并到了master分支。

另外如果只想将feature分支的某个文件f.txt合并到master分支上。

1: git checkout feature
2: git checkout --patch master f.txt

第一个命令： 切换到feature分支；

**第二个命令：合并master分支上f文件到feature分支上，将master分支上 f 文件追加补丁到feature分支上 f文件。**

你可以接受或者拒绝补丁内容。

如果只是简单的将feature分支的文件f.txt copy到master分支上；

git checkout master
git checkout feature f.txt


###  合并冲突

```objc
# git checkout --patch branchB test.c
```

Apply this hunk to index and worktree [y,n,q,a,d,/,K,g,e,?]?


y - 存储这个hunk 
n - 不存储这个hunk 
q - 离开，不存储这个hunk和其他hunk 
a - 存储这个hunk和这个文件后面的hunk 
d - 不存储这个hunk和这个文件后面的hunk 
g - 选择一个hunk 
/ - 通过正则查找hunk 
j - 不确定是否存储这个hunk，看下一个不确定的hunk 
J - 不确定是否存储这个hunk，看下一个hunk 
k - 不确定是否存储这个hunk，看上一个不确定的hunk 
K -不确定是否存储这个hunk，看上一个hunk 
s - 把当前的hunk分成更小的hunks 
e - 手动编辑当前的hunk 
? - 输出帮助信息
```


```
分支A_bracn和B_branch，只想将A_branch分支的某个文件f.txt合并到B_branch分支上。

git checkout A_branch

git checkout –patch B_branch f.txt 
第一个命令： 切换到A分支； 
第二个命令：合并B分支上f文件到A分支上，将B分支上 f 文件追加补丁到A分支上 f文件。你可以接受或者拒绝补丁内容。

如果只是简单的将A_branch分支的文件f.txt copy到B_branch分支上；

git checkout B_branch 
cd path/to/f.txt 
git checkout A_bracn f.txt

```


* [Git 合并单个文件 - 超哥的专栏 - CSDN博客](https://blog.csdn.net/zhangxuechao_/article/details/82692627)
* [git 合并分之内的指定文件 - 灵晨的博客 - CSDN博客](https://blog.csdn.net/lingchen__/article/details/78353959?utm_source=blogxgwz7)

###  获取其他分支的某个提交


* git cherry-pick是本地特性，本地要有这个commit才可以被git cherry-pick。

* git cherry-pick可以选择某一个分支中的一个或几个commit(s)来进行操作（操作的对象是commit）
* 例如，假设我们有个稳定版本的分支，叫v2.0，另外还有个开发版本的分支v3.0，我们不能直接把两个分支合并，这样会导致稳定版本混乱，但是又想增加一个v3.0中的功能到v2.0中，这里就可以使用cherry-pick了。

　　就是对已经存在的commit 进行 再次提交；
　　
　　使用方法如下：


```
git cherry-pick <commit id>

```

查询commit id 的查询可以使用git log查询（查询版本的历史），最简单的语法如下：


```
git log 
```
* [git cherry-pick用法 - 简书](https://www.jianshu.com/p/d577dcc36a08)
* [Git - git-cherry-pick文档](https://git-scm.com/docs/git-cherry-pick)



## 参考

1. [git 为不同的项目设置不同的用户名和邮箱 - CSDN博客](https://blog.csdn.net/qq_2300688967/article/details/81094140)