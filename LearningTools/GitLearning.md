## Git Learning

记录小白学习`Git`的过程，如有错误，希望拍砖指正~

# Git

[Git 图解、常用命令和廖雪峰教程笔记总结 - 好好地 - SegmentFault 思否](https://segmentfault.com/a/1190000008617626)
![](http://oc98nass3.bkt.clouddn.com/15190972612435.jpg)
workspace: 本地的工作目录。（记作A） 
index/stage：暂存区域，临时保存本地改动。 （记作B）
local repository: 本地仓库，只想最后一次提交HEAD。（记作C） 
remote repository：远程仓库。（记作D）
![](http://oc98nass3.bkt.clouddn.com/15190972722623.jpg)

命令笔记
以下所有的命令的功能说明，都采用上述的标记的A、B、C、D的方式来阐述。

初始化

git init //创建
git clone /path/to/repository //检出
git config --global user.email "you@example.com" //配置email
git config --global user.name "Name" //配置用户名
操作

git add <file> // 文件添加，A → B
git add . // 所有文件添加，A → B
git commit -m "代码提交信息" //文件提交，B → C
git commit --amend //与上次commit合并, *B → C
git push origin master //推送至master分支, C → D
git pull //更新本地仓库至最新改动， D → A
git fetch //抓取远程仓库更新， D → C
git log //查看提交记录
git status //查看修改状态
git diff//查看详细修改内容
git show//显示某次提交的内容
撤销操作

git reset <file>//某个文件索引会回滚到最后一次提交， C → B
git reset//索引会回滚到最后一次提交， C → B
git reset --hard // 索引会回滚到最后一次提交， C → B → A
git checkout // 从index复制到workspace， B → A
git checkout -- files // 文件从index复制到workspace， B → A
git checkout HEAD -- files // 文件从local repository复制到workspace， C → A
分支相关

git checkout -b branch_name //创建名叫“branch_name”的分支，并切换过去
git checkout master //切换回主分支
git branch -d branch_name // 删除名叫“branch_name”的分支
git push origin branch_name //推送分支到远端仓库
git merge branch_name // 合并分支branch_name到当前分支(如master)
git rebase //衍合，线性化的自动， D → A
冲突处理

git diff //对比workspace与index
git diff HEAD //对于workspace与最后一次commit
git diff <source_branch> <target_branch> //对比差异
git add <filename> //修改完冲突，需要add以标记合并成功
其他

gitk //开灯图形化git
git config color.ui true //彩色的 git 输出
git config format.pretty oneline //显示历史记录时，每个提交的信息只显示一行
git add -i //交互式添加文件到暂存区
实操：
① 创建版本库
通过git init命令把这个目录变成Git可以管理的仓库
第一步，用命令git add告诉Git，把文件添加到仓库：
$ git add readme.txt
执行上面的命令，没有任何显示，这就对了，

Unix的哲学是“没有消息就是好消息”

说明添加成功。

第二步，用命令git commit -m "xxx" 告诉Git，把文件提交到仓库，-m后面输入的是本次提交的说明，能从历史记录里方便地找到改动记录。

② 添加远程库

git remote add origin git@github.com:tcyfree/test.git(或https://github.com/tcyfree/test.git，用git@比https快)    
添加后，远程库的名字就是origin，这是Git默认的叫法，也可以改成别的，但是origin这个名字一看就知道是远程库。

下一步，就可以把本地库的所有内容推送到远程库上：

$ git push -u origin master
把本地库的内容推送到远程，用git push命令，实际上是把当前分支master推送到远程。

由于远程库是空的，我们第一次推送master分支时，加上了-u参数，Git不但会把本地的master分支内容推送的远程新的master分支，还会把本地的master分支和远程的master分支关联起来，在以后的推送或者拉取时就可以简化命令。

总结：从现在起，只要本地作了提交，就可以通过命令：git push origin master
把本地master分支的最新修改推送至GitHub，现在，你就拥有了真正的分布式版本库！
要关联一个远程库，使用命令git remote add origin git@server-name:path/repo-name.git；
关联后，使用命令git push -u origin master第一次推送master分支的所有内容；
此后，每次本地提交后，只要有必要，就可以使用命令git push origin master推送最新修改；

分布式版本系统的最大好处之一是在本地工作完全不需要考虑远程库的存在，也就是有没有联网都可以正常工作，而SVN在没有联网的时候是拒绝干活的！当有网络的时候，再把本地提交推送一下就完成了同步，真是太方便了！

③ 从远程库克隆
上次我们讲了先有本地库，后有远程库的时候，如何关联远程库。
现在，假设我们从零开发，那么最好的方式是先创建远程库，然后，从远程库克隆。

要克隆一个仓库，首先必须知道仓库的地址，然后使用git clone命令克隆。
Git支持多种协议，包括https，但通过ssh支持的原生git协议速度最快。

场景操作
时光机穿梭
1.要随时掌握工作区的状态，使用git status命令。
2.如果git status告诉你有文件被修改过，用git diff可以查看修改内容。
版本回退
1.HEAD指向的版本就是当前版本，因此，Git允许我们在版本的历史之间穿梭，使用命令git reset --hard commit_id。
2.穿梭前，用git log可以查看提交历史，以便确定要回退到哪个版本。
3.要重返未来，用git reflog查看命令历史，以便确定要回到未来的哪个版本。

git diff HEAD -- readme.txt命令可以查看工作区和版本库里面最新版本的区别

撤销修改
场景1：当你改乱了工作区某个文件的内容，想直接丢弃工作区的修改时，用命令git checkout -- file。

场景2：当你不但改乱了工作区某个文件的内容，还添加到了暂存区时，想丢弃修改，分两步，第一步用命令git reset HEAD file，就回到了场景1，第二步按场景1操作。
（git reset命令既可以回退版本，也可以把暂存区的修改回退到工作区。当我们用HEAD时，表示最新的版本。）

场景3：已经提交了不合适的修改到版本库时，想要撤销本次提交，参考版本回退一节，不过前提是没有推送到远程库。

删除文件
1.命令git rm用于删除一个文件。
2.确实要从版本库中删除该文件，那就用命令git rm删掉，并且git commit：

$ git rm test.txt
rm 'test.txt'
$ git commit -m "remove test.txt"
[master d17efd8] remove test.txt
 1 file changed, 1 deletion(-)
 delete mode 100644 test.txt



![](http://oc98nass3.bkt.clouddn.com/15187660224172.jpg)
diff: 分支点之间的变化
分支点的继承

> Git 作为现在最流行的开源的版本控制系统,  有很多好用开源的工具，`SourceTree`、`Tower`[](https://www.git-tower.com/mac/?source=rd)、`[GitUp](https://github.com/git-up/GitUp)`当然还有`Github`的官方客户端,还有大量的开发者，可以说`Git`是目前用户最多，最火的版本控制系统。

具体什么是`Git`,可以参考[what-is-git](https://www.atlassian.com/git/tutorials/what-is-git)文章,可以说`Git`集成了`SVN`的一些特性（tag, branch），采用了巧妙的设计(本地库)，让并行开发更高效。

## Git workflow

>The Git workflow consists of editing files in the working directory, adding files to the staging area, and saving changes to a Git repository. In Git, we save changes with a commit, which we will learn more about in this lesson.
![](http://oc98nass3.bkt.clouddn.com/14936106948535.jpg)

一个`Git`项目可以被看做一下三个部分：

1. A Working Directory: where you'll be doing all the work: creating, editing, deleting and organizing files.
工作区:  你将在里面完成文件的创建、编辑、删除、整理的所有工作。
2. A Staging Area: where you'll list changes you make to the working directory.
暂存区：
3. A Repository: where Git permanently stores those changes as different versions of the project.
版本库:  `Git`永久的保存着这个项目版本间的不同变化。

![](http://oc98nass3.bkt.clouddn.com/14936109243775.jpg)

### 工作区、暂存区、版本库原理图

![](http://oc98nass3.bkt.clouddn.com/14936261372760.png)

在这个图中，可以看到部分`Git`命令是如何影响工作区和暂存区（`stage`，亦称`index`）的。下面就对这些命令进行简要的说明，而要彻底揭开这些命令的面纱要在接下来的几个章节。
图中左侧为工作区，右侧为版本库。在版本库中标记为`index`的区域是暂存区（`stage`，亦称`index`），标记为`master`的是`master`分支所代表的目录树。
图中可以看出此时HEAD实际是指向`master`分支的一个“游标”。所以图示的命令中出现HEAD的地方可以用master来替换。
图中的`objects`标识的区域为`Git`的对象库，实际位于`.git/objects`目录下，会在后面的章节重点介绍。
当对工作区修改（或新增）的文件执行`git add`命令时，暂存区的目录树被更新，同时工作区修改（或新增）的文件内容被写入到对象库中的一个新的对象中，而该对象的ID被记录在暂存区的文件索引中。
当执行提交操作（`git commit`）时，暂存区的目录树写到版本库（对象库）中，`master`分支会做相应的更新。即`master`最新指向的目录树就是提交时原暂存区的目录树。
当执行`git reset HEAD`命令时，暂存区的目录树会被重写，被vmaster`分支指向的目录树所替换，但是工作区不受影响。
当执行`git rm –cached <file>`命令时，会直接从暂存区删除文件，工作区则不做出改变。
当执行`git checkout .`或者`git checkout – <file>`命令时，会用暂存区全部或指定的文件替换工作区的文件。这个操作很危险，会清除工作区中未添加到暂存区的改动。
当执行`git checkout HEAD .`或者`git checkout HEAD <file>`命令时，会用`HEAD`指向的`master`分支中的全部或者部分文件替换暂存区和以及工作区中的文件。这个命令也是极具危险性的，因为不但会清除工作区中未提交的改动，也会清除暂存区中未提交的改动。

##### Git diff魔法
通过使用不同的参数调用git diff命令，可以对工作区、暂存区、HEAD中的内容两两比较。下面的这个图，展示了不同的git diff命令的作用范围。

![](http://oc98nass3.bkt.clouddn.com/14936265400329.png)

##### Git对象库探秘
原来分支master指向的是一个提交ID（最新提交）。这样的分支实现是多么的巧妙啊：既然可以从任何提交开始建立一条历史跟踪链，那么用一个文件指向这个链条的最新提交，那么这个文件就可以用于追踪整个提交历史了。这个文件就是.git/refs/heads/master文件。
下面看一个更接近于真实的版本库结构图：

![](http://oc98nass3.bkt.clouddn.com/14936266336082.png)


### `Git`命令

用一个命令向改变区(staging)添加多个文件的方法
`git add filename_1 filename_2`

`git add files` 把当前文件放入暂存区域。
`git commit` 给暂存区域生成快照并提交。
`git reset -- files` 用来撤销最后一次git add files，你也可以用git reset` 撤销所有暂存区域文件。
`git checkout -- files` 把文件从暂存区域复制到工作目录，用来丢弃本地修改。

![](http://oc98nass3.bkt.clouddn.com/14936233428927.jpg)

![](http://oc98nass3.bkt.clouddn.com/14936234442203.jpg)

`git commit -a` 相当于运行 git add 把所有当前目录下的文件加入暂存区域再运行。git commit.
`git commit files` 进行一次包含最后一次提交加上工作目录中文件快照的提交。并且文件被添加到暂存区域。
`git checkout HEAD -- files` 回滚到复制最后一次提交。

[图解Git](https://marklodato.github.io/visual-git-guide/index-zh-cn.html#commands-in-detail)

`git checkout HEAD filename`: Discards changes in the working directory.
`git reset HEAD filename`: Unstages file changes in the staging area.
`git reset SHA`: Can be used to reset to a previous commit in your commit history.

#### `remote origin`

1. 添加远程库： `$ git remote add origin`
2. 移除远程库： `$ git remote remove (OrignName)`
3. 查看远程库： `$ git remote -v`(--verbose)

#### `git grep`命令查找
`$ git grep`命令
`git grep -n "要查找的字符串"`
1. -W 查找函数上下文
2. 使用 --count 参数, 只会显示在哪个文件里有几个要查找的字符串, 如下:
 `git grep --count "(defun format "`
 
 `src/format.lisp:1`

可以使用 `$ git help grep` 来查看帮助

#### `Git`删除文件

[git 删除文件](http://www.jianshu.com/p/c3ff8f0da85e)

#### 深入了解`git rese`t命令
![](http://oc98nass3.bkt.clouddn.com/14936268028934.png)

重置命令（`git reset`）是Git最常用的命令之一，也是最危险，最容易误用的命令。来看看git reset命令的用法。
用法一：`git reset [-q] [<commit>] [--] <paths>...`
用法二： `git reset [--soft | --mixed | --hard | --merge | --keep] [-q] [<commit>]`
上面列出了两个用法，其中` <commit> `都是可选项，可以使用引用或者提交`ID`，如果省略 `<commit> `则相当于使用了`HEAD`的指向作为提交`ID`。
上面列出的两种用法的区别在于，第一种用法在命令中包含路径`<paths>`。为了避免路径和引用（或者提交`ID`）同名而冲突，可以在`<paths>`前用两个连续的短线（减号）作为分隔。
第一种用法（包含了路径`<paths>`的用法）不会重置引用，更不会改变工作区，而是用指定提交状态（`<commit>`）下的文件（`<paths>`）替换掉暂存区中的文件。例如命令`git reset HEAD <paths>`相当于取消之前执行的`git add <paths>`命令时改变的暂存区。
第二种用法（不使用路径<paths>的用法）则会重置引用。根据不同的选项，可以对暂存区或者工作区进行重置。参照下面的版本库模型图，来看一看不同的参数对第二种重置语法的影响。

#### 深入了解`git checkout`命令

检出命令（git checkout）是Git最常用的命令之一，同样也很危险，因为这条命令会重写工作区。
```
用法一： git checkout [-q] [<commit>] [--] <paths>...
用法二： git checkout [<branch>]
用法三： git checkout [-m] [[-b|--orphan] <new_branch>] [<start_point>]
```
![](http://oc98nass3.bkt.clouddn.com/14936268612321.jpg)

下面通过一些示例，具体的看一下检出命令的不同用法。
* 命令：`git checkout branch`
检出`branch`分支。要完成如图的三个步骤，更新`HEAD`以指向`branch`分支，以`branch`指向的树更新暂存区和工作区。
* 命令：`git checkout`
汇总显示工作区、暂存区与HEAD的差异。

* 命令：`git checkout HEAD`
 同上.

* 命令：`git checkout – filename`
用暂存区中`filename`文件来覆盖工作区中的`filename`文件。相当于取消自上次执行`git add filename`以来（如果执行过）本地的修改。
这个命令很危险，因为对于本地的修改会悄无声息的覆盖，毫不留情。

* 命令：`git checkout branch – filename`
维持`HEAD`的指向不变。将`branch`所指向的提交中的`filename`替换暂存区和工作区中相应的文件。注意会将暂存区和工作区中的`filename`文件直接覆盖。

* 命令：`git checkout – ` 或写做 `git checkout .`
注意：`git checkout`命令后的参数为一个点（“.”）。这条命令最危险！会取消所有本地的修改（相对于暂存区）。相当于将暂存区的所有文件直接覆盖本地文件，不给用户任何确认的机会！

#### 用reflog挽救错误的重置
如果没有记下重置前master分支指向的提交ID，想要重置回原来的提交真的是一件麻烦的事情（去对象库中一个一个地找）。幸好Git提供了一个挽救机制，通过.git/logs目录下日志文件记录了分支的变更。默认非裸版本库（带有工作区）都提供分支日志功能，这是因为带有工作区的版本库都有如下设置：

```
$ git config core.logallrefupdates
true
```

查看一下`master`分支的日志文件`.git/logs/refs/heads/master`中的内容。下面命令显示了该文件的最后几行。为了排版的需要，还将输出中的40位的`SHA1`提交ID缩短。

```
$ tail -5 .git/logs/refs/heads/master
dca47ab a0c641e Jiang Xin <jiangxin@ossxp.com> 1290999606 +0800    commit (amend): who does commit?
a0c641e e695606 Jiang Xin <jiangxin@ossxp.com> 1291022581 +0800    commit: which version checked in?
e695606 4902dc3 Jiang Xin <jiangxin@ossxp.com> 1291435985 +0800    commit: does master follow this new commit?
4902dc3 e695606 Jiang Xin <jiangxin@ossxp.com> 1291436302 +0800    HEAD^: updating HEAD
e695606 9e8a761 Jiang Xin <jiangxin@ossxp.com> 1291436382 +0800    9e8a761: updating HEAD
```

可以看出这个文件记录了`master`分支指向的变迁，最新的改变追加到文件的末尾因此最后出现。最后一行可以看出因为执行了`git reset –hard`命令，指向的提交`ID`由`e695606`改变为`9e8a761`。
`Git`提供了一个`git reflog`命令，对这个文件进行操作。使用`show`子命令可以显示此文件的内容。

```
$ git reflog show master | head -5
9e8a761 master@{0}: 9e8a761: updating HEAD
e695606 master@{1}: HEAD^: updating HEAD
4902dc3 master@{2}: commit: does master follow this new commit?
e695606 master@{3}: commit: which version checked in?
a0c641e master@{4}: commit (amend): who does commit?
```

使用`git reflog`的输出和直接查看日志文件最大的不同在于显示顺序的不同，即最新改变放在了最前面显示，而且只显示每次改变的最终的`SHA1`哈希值。还有个重要的区别在于使用`git reflog`的输出中还提供一个方便易记的表达式：`<refname>@{<n>}`。这个表达式的含义是引用`<refname>`之前第`<n>`次改变时的`SHA1`哈希值。
那么将引用`master`切换到两次变更之前的值，可以使用下面的命令。
重置`master`为两次改变之前的值。

```
$ git reset --hard master@{2}
```
`HEAD is now at 4902dc3 does master follow this new commit?`

重置后工作区中文件new-commit.txt又回来了。

```
$ ls
new-commit.txt  welcome.txt
```

提交历史也回来了。

```
$ git log --oneline
4902dc3 does master follow this new commit?
e695606 which version checked in?
a0c641e who does commit?
9e8a761 initialized.
```

此时如果再用git reflog查看，会看到恢复master的操作也记录在日志中了。
```
$ git reflog show master | head -5
4902dc3 master@{0}: master@{2}: updating HEAD
9e8a761 master@{1}: 9e8a761: updating HEAD
e695606 master@{2}: HEAD^: updating HEAD
4902dc3 master@{3}: commit: does master follow this new commit?
e695606 master@{4}: commit: which version checked in?
```

### Git Cheat Sheet 
>看了前面那么多命令，是不是头有点晕了？ㄟ( ▔, ▔ )ㄏ平时开发用的到那么多命令吗？
没关系，给你一张好用的常见命令图，忘记了来着看下就行了！

![Git Cheat Sheet](http://oc98nass3.bkt.clouddn.com/2017-07-12-14998489359095.jpg)

### Git Branch

1. 查看分支列表
`$ git branch`
2. 新建分支
`$ git branch new_branch_name`
3. 切换到分支
`$ git checkout branch_name`
4. 合并支分支到`master`主分支
`$ git merge branch_name`
5. 删除分支
`$ git branch -d branch_name`

墙裂推荐查看:[3.1 Git 分支 - 分支简介](https://git-scm.com/book/zh/v2/Git-%E5%88%86%E6%94%AF-%E5%88%86%E6%94%AF%E7%AE%80%E4%BB%8B)
Git 的分支，其实本质上仅仅是指向提交对象的可变指针。 Git 的默认分支名字是 master。 在多次提交操作之后，你其实已经有一个指向最后那个提交对象的 master 分支。 它会在每次的提交操作中自动向前移动。
Git 的 “master” 分支并不是一个特殊分支。 它就跟其它分支完全没有区别。 之所以几乎每一个仓库都有 master 分支，是因为 git init 命令默认创建它，并且大多数人都懒得去改动它。

为了更加形象地说明，我们假设现在有一个工作目录，里面包含了三个将要被暂存和提交的文件。 暂存操作会为每一个文件计算校验和（使用我们在 起步 中提到的 SHA-1 哈希算法），然后会把当前版本的文件快照保存到 Git 仓库中（Git 使用 blob 对象来保存它们），最终将校验和加入到暂存区域等待提交：

Git 是怎么创建新分支的呢？ 很简单，它只是为你创建了一个可以移动的新的指针。 比如，创建一个 testing 分支， 你需要使用 git branch 命令：


![](http://oc98nass3.bkt.clouddn.com/2017-07-13-14999389044006.png)

那么，Git 又是怎么知道当前在哪一个分支上呢？ 也很简单，它有一个名为 HEAD 的特殊指针。 请注意它和许多其它版本控制系统（如 Subversion 或 CVS）里的 HEAD 概念完全不同。 在 Git 中，它是一个指针，指向当前所在的本地分支（译注：将 HEAD 想象为当前分支的别名）。 在本例中，你仍然在 master 分支上。 因为 git branch 命令仅仅 创建 一个新分支，并不会自动切换到新分支中去。
![](http://oc98nass3.bkt.clouddn.com/2017-07-13-14999389256791.png)

1. 新建本地分支，追踪本地分支
```
git checkout --track origin/trackingRemoteBranch
```
![](http://oc98nass3.bkt.clouddn.com/15188745680824.jpg)


### Git stash

暂存未跟踪或忽略的文件
默认情况下，git stash会缓存下列文件：
* 添加到暂存区的修改（staged changes）
* Git跟踪的但并未添加到暂存区的修改（unstaged changes）

但不会缓存一下文件：
* 在工作目录中新的文件（untracked files）
* 被忽略的文件（ignored files）

`git stash`（git储藏）可用于以下情形：
* 使用git的时候，我们往往使用分支（branch）解决任务切换问题，例如，我们往往会建一个自己的分支去修改和调试代码, 如果别人或者自己发现原有的分支上有个不得不修改的bug，我们往往会把完成一半的代码commit提交到本地仓库，然后切换分支去修改bug，改好之后再切换回来。这样的话往往log上会有大量不必要的记录。其实如果我们不想提交完成一半或者不完善的代码，但是却不得不去修改一个紧急Bug，那么使用git stash就可以将你当前未提交到本地（和服务器）的代码推入到Git的栈中，这时候你的工作区间和上一次提交的内容是完全一样的，所以你可以放心的修Bug，等到修完Bug，提交到服务器上后，再使用git stash apply将以前一半的工作应用回来。

* 经常有这样的事情发生，当你正在进行项目中某一部分的工作，里面的东西处于一个比较杂乱的状态，而你想转到其他分支上进行一些工作。问题是，你不想提交进行了一半的工作，否则以后你无法回到这个工作点。解决这个问题的办法就是git stash命令。储藏(stash)可以获取你工作目录的中间状态——也就是你修改过的被追踪的文件和暂存的变更——并将它保存到一个未完结变更的堆栈中，随时可以重新应用。

`git stash`可以暂存本地的改动到`stash stack`中

```
#show the stash stack list
git stash show list

#show the second one in the stashes stash stack
git stash show stash@{1}

#show the diff of stash
git stash show -p


#可以通过git stash apply命令恢复之前缓存的工作目录，不会将其从堆栈中移走
git stash apply

#recover the stashed diff delete the top stash for stash stack
#git stash pop命令恢复之前缓存的工作目录，同时立刻将其从堆栈中移走
git stash pop
```
实际应用中推荐给每个stash加一个message，用于记录版本，使用git stash save取代git stash命令。示例如下：

```
$ git stash save "test-cmd-stash"
Saved working directory and index state On autoswitch: test-cmd-stash
HEAD 现在位于 296e8d4 remove unnecessary postion reset in onResume function
$ git stash list
stash@{0}: On autoswitch: test-cmd-stash
```
### Git undo撤销方法

1. `git revert <SHA>`
2. `git commit --amend -m "Modify last add message"`
3. 撤销本地的修改`git checkout -- <bad filename>`
4. 重置本地的修改`git reset <last good SHA>`

[Git的各种Undo技巧](https://tonydeng.github.io/2015/07/08/how-to-undo-almost-anything-with-git/)


### Git Merge

使用`Xcode`的`FileMerge`合并代码
```
# Tell system when Xcode utilities live:
sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer

# Set "opendiff" as the default mergetool globally:
git config --global merge.tool opendiff
```

1. 代码冲突`! [rejected] master -> master (non-fast-forward)`的原因以及解决办法：
```
 ! [rejected]        master ->  master (non-fast-forward)  
error: failed to push some refs to 'git@github.com:archermind/LEDTorch.apk-for-Android.git'  
To prevent you from losing history, non-fast-forward updates were rejected  
Merge the remote changes before pushing again.  See the 'Note about  
fast-forwards' section of 'git push --help' for details.  
```
**操作命令：**

*  正确的做法是，在`push`之前`git fetch origin`，将`github`上的新代码拉下来，然后在本地`merge`，如果没有冲突就可以push了，如果有冲突的话要在本地解决冲突后，再`pus`h。具体做法就是：
```
git fetch origin
git merge origin (master)
```
* 这两步其实可以简化为
```
git pull origin master
```

`git-fetch - Download objects and refs from another repository`
`git-merge - Join two or more development histories together`


### Git log

```
Table 3. 限制 git log 输出的选项
选项	说明
-(n)

仅显示最近的 n 条提交

--since, --after

仅显示指定时间之后的提交。

--until, --before

仅显示指定时间之前的提交。

--author

仅显示指定作者相关的提交。

--committer

仅显示指定提交者相关的提交。

--grep

仅显示含指定关键字的提交

-S

仅显示添加或移除了某个关键字的提交

来看一个实际的例子，如果要查看 Git 仓库中，2008 年 10 月期间，Junio Hamano 提交的但未合并的测试文件，可以用下面的查询命令：

$ git log --pretty="%h - %s" --author=gitster --since="2008-10-01" \
   --before="2008-11-01" --no-merges -- t/
5610e3b - Fix testcase failure when extended attributes are in use
acd3b9e - Enhance hold_lock_file_for_{update,append}() API
f563754 - demonstrate breakage of detached checkout with symbolic link HEAD
d1a43f2 - reset --hard/read-tree --reset -u: remove unmerged new paths
51a94af - Fix "checkout --track -b newbranch" on detached HEAD
b0ad11e - pull: allow "git pull origin $something:$current_branch" into an unborn branch
在近 40000 条提交中，上面的输出仅列出了符合条件的 6 条记录。

prev | next

```

2. 显示每次提交的diff:
```
git log -p 
```

3. 按成员的提交历史
```
git shortlog
```

4. 在提交的历史改动中查找关键字，`-p`代表显示log提交的改动

```
git log -S"searchKeyWord" -p
```

5, 搜索提交的注释
```
git log --grep=“keyWord” 

```
6.  搜索某个用户的提交
```
git log --author=“authorName” 
```



### Git diff

当add了change后, `git diff`是不会显示已经add后的change的，可以制定stage的diff

```
git diff --staged
```

### Git config
Git的配置

1. 列出`Git`全局配置列表
```
git config --global --list
```
2. 列出`Git`本地仓库配置列表
```
git config --local --list
```

3. 设置用户名，邮箱密码等 
```
$ git config --global user.name "John Doe"
$ git config --global user.email johndoe@example.com
```


4. 设置编辑器
```
$ git config --global core.editor emacs
```

#### 设置`git`命令 别名

```
$ git config --global alias.st status
$ git config --global alias.co checkout
$ git config --global alias.ct commit
$ git config --global alias.df diff
$ git config --global alias.br branch
#git lg to view commit log like network graph
$ git config --global alias.lg "log --all --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%ci) %C(bold blue)<%an>%Creset' --abbrev-commit"
```

##### 强大的别名
GIT utilities -- repo summary, repl, changelog population, author commit percentages and more
[](https://github.com/tj/git-extras)
[git-extras/Commands.md at master · tj/git-extras](https://github.com/tj/git-extras/blob/master/Commands.md)

#### 同一台电脑可以有2个git账号（不同网站的）

[1.同一台电脑可以有2个git账号（不同网站的）](https://gist.github.com/suziewong/4378434)

这种情况下，需要几点注意

1.remote pull push的时候有问题，因为要设置邮箱问题了 pull的时候识别的是邮箱，2个github账号，2个邮箱，我们自然不能使用global的user.email了

1.取消global

```
git config --global --unset user.name
git config --global --unset user.email
```
2.设置每个项目repo的自己的user.email

```
git config  user.email "xxxx@xx.com"
git config  user.name "suzie"
```

之后push pull就木有问题了

备注
生成ssh key

ssh-keygen -m rsa -C "your mail" （当前目录） 然后可以命名默认id_rsa 或者id_rsa_second 把对应的pub放到公共服务器上。

###  fork命令
现在有这样一种情形：有一个叫做Joe的程序猿写了一个游戏程序，而你可能要去改进它。并且Joe将他的代码放在了GitHub仓库上。下面是你要做的事情：

fork并且更新GitHub仓库的图表演示
![](http://oc98nass3.bkt.clouddn.com/15174730715491.png)

1. Fork他的仓库：这是GitHub操作，这个操作会复制Joe的仓库（包括文件，提交历史，issues，和其余一些东西）。复制后的仓库在你自己的GitHub帐号下。目前，你本地计算机对这个仓库没有任何操作。

2. Clone你的仓库：这是Git操作。使用该操作让你发送"请给我发一份我仓库的复制文件"的命令给GitHub。现在这个仓库就会存储在你本地计算机上。

3. 更新某些文件：现在，你可以在任何程序或者环境下更新仓库里的文件。

4. 提交你的更改：这是Git操作。使用该操作让你发送"记录我的更改"的命令至GitHub。此操作只在你的本地计算机上完成。

5. 将你的更改push到你的GitHub仓库：这是Git操作。使用该操作让你发送"这是我的修改"的信息给GitHub。Push操作不会自动完成，所以直到你做了push操作，GitHub才知道你的提交。

6. 给Joe发送一个pull request：如果你认为Joe会接受你的修改，你就可以给他发送一个pull request。这是GitHub操作，使用此操作可以帮助你和Joe交流你的修改，并且询问Joe是否愿意接受你的"pull request"，当然，接不接受完全取决于他自己。

7. 如果Joe接受了你的pull request，他将把那些修改拉到自己的仓库。胜利！

#### 同步一个fork
Joe和其余贡献者已经对这个项目做了一些修改，而你将在他们的修改的基础上，还要再做一些修改。在你开始之前，你最好"同步你的fork"，以确保在最新的复制版本里工作。下面是你要做的
![](http://oc98nass3.bkt.clouddn.com/15174733991977.png)
1. 从Joe的仓库中取出那些变化的文件：这是Git操作，使用该命令让你库获取最新的文件。

2. 将这些修改合并到你自己的仓库：这是Git操作，使用该命令使得那些修改更新到你的本地计算机（那些修改暂时存放在一个"分支"中）。记住：步骤1和2经常结合为一个命令使用，合并后的Git命令叫做"pull"。

3. 将那些修改更新推送到你的GitHub仓库（可选）：记住，你本地计算机不会自动更新你的GitHub仓库。所以，唯一更新GitHub仓库的办法就是将那些修改推送上去。你可以在步骤2完成后立即执行push，也可以等到你做了自己的一些修改，并已经本地提交后再执行推送操作。

比较一下fork和同步工作流程的区别：当你最初fork一个仓库的时候，信息的流向是从Joe的仓库到你的仓库，然后再到你本地计算机。但是最初的过程之后，信息的流向是从Joe的仓库到你的本地计算机，之后再到你的仓库。

### 在github上同步一个分支(fork)
[在github上同步一个分支(fork)](http://leonardyp.github.io/git/%E5%9C%A8github%E4%B8%8A%E5%90%8C%E6%AD%A5%E4%B8%80%E4%B8%AA%E5%88%86%E6%94%AF%28fork%29/)
在同步之前，需要创建一个远程点指向上游仓库(repo).如果你已经派生了一个原始仓库，可以按照如下方法做。


```  
$ git remote -v  
    # List the current remotes （列出当前远程仓库）  
    # origin  https://github.com/user/repo.git (fetch)  
    # origin  https://github.com/user/repo.git (push)  
    $ git remote add upstream https://github.com/otheruser/repo.git  
    # Set a new remote (设置一个新的远程仓库)  
    $ git remote -v  
    # Verify new remote (验证新的原仓库)  
    # origin    https://github.com/user/repo.git (fetch)  
    # origin    https://github.com/user/repo.git (push)  
    # upstream  https://github.com/otheruser/repo.git (fetch)  
    # upstream  https://github.com/otheruser/repo.git (push)  
```
同步
同步上游仓库到你的仓库需要执行两步：首先你需要从远程拉去，之后你需要合并你希望的分支到你的本地副本分支。

拉取
从远程仓库拉取将取回其分支以及各自的提交。它们将存储在你本地仓库的指定分之下。

    $ git fetch upstream
    # Grab the upstream remote's branches
    # remote: Counting objects: 75, done.
    # remote: Compressing objects: 100% (53/53), done.
    # remote: Total 62 (delta 27), reused 44 (delta 9)
    # Unpacking objects: 100% (62/62), done.
    # From https://github.com/otheruser/repo
    #  * [new branch]      master     -> upstream/master
    
现在我们把上游master保存到了本地仓库，upstream/master
    $ git branch -va
    # List all local and remote-tracking branches
    # * master                  a422352 My local commit
    #   remotes/origin/HEAD     -> origin/master
    #   remotes/origin/master   a422352 My local commit
    #   remotes/upstream/master 5fdff0f Some upstream commit
合并
现在我们已经拉取了上游仓库，我们将要合并其变更到我们的本地分支。这将使该分支与上游同步，而不会失去我们的本地更改。

    $ git checkout master
    # Check out our local master branch
    # Switched to branch 'master'

    $ git merge upstream/master
    # Merge upstream's master into our own
    # Updating a422352..5fdff0f
    # Fast-forward
    #  README                    |    9 -------
    #  README.md                 |    7 ++++++
    #  2 files changed, 7 insertions(+), 9 deletions(-)
    #  delete mode 100644 README
    #  create mode 100644 README.md
如果您的本地分支没有任何独特的提交，Git会改为执行“fast-forward”。

    $ git merge upstream/master
    # Updating 34e91da..16c56ad
    # Fast-forward
    #  README.md                 |    5 +++--
    #  1 file changed, 3 insertions(+), 2 deletions(-)
最后将本地变更推送到远程服务器即可。




### Git Issue
1. [Git - how to track untracked content?](http://stackoverflow.com/questions/4161022/git-how-to-track-untracked-content)

```
On branch master
Your branch is up-to-date with 'origin/master'.
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)
  (commit or discard the untracked or modified content in submodules)

	modified:   themes/next (modified content, untracked content)
```


2. [git - fatal: Not a valid object name: 'master' - Stack Overflow](https://stackoverflow.com/questions/9162271/fatal-not-a-valid-object-name-master)
That is again correct behaviour. Until you commit, there is no master branch.

You haven't asked a question, but I'll answer the question I assumed you mean to ask. Add one or more files to your directory, and git add them to prepare a commit. Then git commit to create your initial commit and master branch.

没有提交的话是没有`master`分支的，也就无法创建新的分支，只了一次有提交记录后，才创建了`master`分支。

3. [error: There was a problem with the editor 'vi'. #6](https://github.com/google/vim-colorscheme-primary/issues/6)  

这是`Git`的全局配置的问题
It was a problem with git configuration. This fixed it for me:

```
git config --global core.editor /usr/bin/vim
```

4. [remote Permission to jlord/patchwork.git denied returned error: 403 · Issue #11600 · jlord/patchwork](https://github.com/jlord/patchwork/issues/11600)


```
When you get a 403 on this challenge it is because you are trying to push your changes to a repository you don't have access to i.e. my original one jlord/patchwork.

I'm going to update the app soon to make it more clear since this is catching quite a few people.

To see what your remotes are you can run:

git remote -v
You should have an origin that points to the copy (fork) on your GitHub account and one named upstream that points to my original jlord/patchwork. You can only pull from upstream, not push.

It seems like people are either pushing to upstream or have set the URL to origin incorrectly.

You can update your origin remote url by running:

git remote set-url origin <urltoyourfork>

```

### Git Tips

1. Git跟踪的是文件file的路径和内容，但是对文件夹并不清楚，无法追踪空的文件夹，如果需要在仓库中建立空文件夹到Git，需要在文件夹内添加一个隐藏文件`.keep`或者`.gitkkeep`.
2. 



## Git重点

1.  本地有改动先提交到暂存区(Staging)，`Push`之前应该先`Pull`，这样可以保证自己解决所有冲突之后，再把结果放到其他库。不要把麻烦留给别人！

```
git add 
git commit -m "commit messge"
git pull
git push
```

2.  提交时的`-- rebase`参数
` merge `操作的没意义提交记录~
![image.png](http://upload-images.jianshu.io/upload_images/225323-0a88ed64907f362b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

其实在 `pull` 操作的时候，，使用 `git pull --rebase` 选项即可很好地解决上述问题。 加上 `--rebase` 参数的作用是，提交线图有分叉的话，Git 会 rebase 策略来代替默认的 merge 策略。 使用 rebase 策略有什么好处呢？借用一下 man git-merge 中的图就可以很好地说明清楚了。
假设提交线图在执行 pull 前是这样的：
```
                 A---B---C  remotes/origin/master
                /
           D---E---F---G  master
```
如果是执行 git pull 后，提交线图会变成这样：
```
                 A---B---C remotes/origin/master
                /         \
           D---E---F---G---H master
```
结果多出了 `H` 这个没必要的提交记录。如果是执行 `git pull --rebase `的话，提交线图就会变成这样：
```
                       remotes/origin/master
                           |
           D---E---A---B---C---F'---G'  master
```
`F`、` G` 两个提交通过 `rebase `方式重新拼接在 `C `之后，多余的分叉去掉了，目的达到。

不过，如果你对使用 `git` 还不是十分熟练的话，我的建议是 `git pull --rebase` 多练习几次之后再使用，因为 `rebase` 在 `git` 中，算得上是『危险行为』。

1. [团队开发里频繁使用 git rebase 来保持树的整洁好吗? - SegmentFault 思否](https://segmentfault.com/q/1010000000430041)

3. 合并冲突

<<<<<<<head 是指你本地的分支的
<<<<<<< HEAD
b789
=======
b45678910
>>>>>>> 6853e5ff961e684d3a6c02d4d06183b5ff330dcc
head 到 =======里面的b789是您的commit的内容
=========到 >>>>68的是您下拉的内容

### 三、git rebase教程
`git rebase`用于把一个分支的修改合并到当前分支。

但是，如果你想让"mywork"分支历史看起来像没有经过任何合并一样，你也许可以用 git rebase:

```
$ git checkout mywork
$ git rebase origin

```这些命令会把你的"mywork"分支里的每个提交(commit)取消掉，并且把它们临时 保存为补丁(patch)(这些补丁放到".git/rebase"目录中),然后把"mywork"分支更新 为最新的"origin"分支，最后把保存的这些补丁应用到"mywork"分支上。
![](http://oc98nass3.bkt.clouddn.com/15192866815450.jpg)

当'mywork'分支更新之后，它会指向这些新创建的提交(commit),而那些老的提交会被丢弃。 如果运行垃圾收集命令(pruning garbage collection), 这些被丢弃的提交就会删除. （请查看 git gc)

以前遇到commit写错总是使用git reset --soft回退到之前的状态，再commit后push -f强推到远程库，能够覆盖掉之前的commit。

现在想想也是很low的做法，git rebase 可以帮你搞定这个问题。

好了，随便提交了几个
![](http://oc98nass3.bkt.clouddn.com/15178298763331.jpg)


二、解决冲突
在rebase的过程中，也许会出现冲突(conflict). 在这种情况，Git会停止rebase并会让你去解决 冲突；在解决完冲突后，用"git-add"命令去更新这些内容的索引(index), 然后，你无需执行 git-commit,只要执行:
```
$ git rebase --continue
```
这样git会继续应用(apply)余下的补丁。
在任何时候，你可以用--abort参数来终止rebase的行动，并且"mywork" 分支会回到rebase开始前的状态。
```
$ git rebase --abort
```

#### `git rebase -i`
工作中，我们可能不小心写错commit，例如上面那个 “测试 git rebase”我写错了，我想改一改，怎么办呢？

1.（打开terminal）

git rebase -i 233d7b3( 这个commit是在我们要修改的commit前一个)

git rebase -i 233d7b3

然后就进入下面这里：

![](http://oc98nass3.bkt.clouddn.com/15178298852746.jpg)


这里就是我们熟悉的vi，按i进入insert模式，

我们是要修改，所以改成

reword 345c70f 测试 git rebase

     esc ： wq 保存退出

![](http://oc98nass3.bkt.clouddn.com/15178298937726.jpg)


i进入insert模式，修改commit内容，esc  ： wq 保存退出。

最后害得强push

git push --force

那么我们要如何合并几个commit呢？

和上面类似，我们首先

git rebase -i f290515(我们要合并的commit的前一个)

![](http://oc98nass3.bkt.clouddn.com/15178299079398.jpg)

pick 766f348 dsfdsf

squash 233d7b3 sdfdsf

squash 345c70f 测试 git rebase

我们可以这样修改  将后面两个改成squash，就是合并到第一个上去

如果没有冲突就可以看到这个界面
![](http://oc98nass3.bkt.clouddn.com/15178299134967.jpg)


保存退出

最后git push -f


#### rebase和merge有什么区别呢

![](http://oc98nass3.bkt.clouddn.com/15178300610660.jpg)

现在我们在这个分支做一些修改，然后生成两个提交(commit).

$ 修改文件
$ git commit
$ 修改文件
$ git commit

但是与此同时，有些人也在"origin"分支上做了一些修改并且做了提交了. 这就意味着"origin"和"mywork"这两个分支各自"前进"了，它们之间"分叉"了

![](http://oc98nass3.bkt.clouddn.com/15178300701048.jpg)


在这里，你可以用"pull"命令把"origin"分支上的修改拉下来并且和你的修改合并； 结果看起来就像一个新的"合并的提交"(merge commit):
![](http://oc98nass3.bkt.clouddn.com/15178300745333.jpg)
但是，如果你想让"mywork"分支历史看起来像没有经过任何合并一样，你也许可以用 git rebase:


```
$ git checkout mywork
$ git rebase origin
```

这些命令会把你的"mywork"分支里的每个提交(commit)取消掉，并且把它们临时 保存为补丁(patch)(这些补丁放到".git/rebase"目录中),然后把"mywork"分支更新 为最新的"origin"分支，最后把保存的这些补丁应用到"mywork"分支上。

![](http://oc98nass3.bkt.clouddn.com/15178300786831.jpg)
![](http://oc98nass3.bkt.clouddn.com/15178301165540.jpg)
rebase黄金定律
永远不要rebase一个已经分享的分支（到非remote分支，比如rebase到master,develop,release分支上），也就是说永远不要rebase一个已经在中央库中存在的分支.只能rebase你自己使用的私有分支

如你和你的同事John都工作在一个feature开发上，你和他分别做了一些commit，随后你fetch了John的feature分支（或者已经被John分享到中央库的feature分支），那么你的repo的版本历史可能已经是下面的样子了：
![](http://oc98nass3.bkt.clouddn.com/15178302903450.jpg)

这时你希望集成John的feature开发工作，你也有两个选择，要么merge,要么rebase,
![](http://oc98nass3.bkt.clouddn.com/15178302864675.jpg)

记住在这个场景中，你rebase到John/feature分支的操作并不违反rebase的黄金定律，因为：

只有你的local本地私有（还未push的） `feature commits`被移动和重写历史了，而你的本地commit之前的所有commit都未做改变。这就像是说“把我的改动放到John的工作之上”。在大多数情况下，这种rebase比用merge要好很多


#### gitrebase使用笔记
1. [用了两年git，rebase原来这样用 - 简书](https://www.jianshu.com/p/384a945f6e7e)
2. [git rebase使用笔记](https://www.jianshu.com/p/cca69cb695a6)


# Git 一些好用的插件😝~

## GitFlow

1. [How to use a scalable Git branching model called Gitflow - Drupal Video Tutorial | BuildAModule](https://buildamodule.com/video/change-management-and-version-control-deploying-releases-features-and-fixes-with-git-how-to-use-a-scalable-git-branching-model-called-gitflow#viewing)

2. [git-flow 备忘清单](https://danielkummer.github.io/git-flow-cheatsheet/index.zh_CN.html)
## Gitsome
[Gitsome](https://github.com/donnemartin/gitsome) （2017-05-19）


### GitHub Integration Commands Listing （2018-01-20）

 命令  |  解释
 --- | ---
  configure            |    Configure gitsome.
  create-comment      |     Create a comment on the given issue.
  create-issue       |      Create an issue.
  create-repo       |       Create a repo.
  emails            |       List all the user's registered emails.
  emojis            |       List all GitHub supported emojis.
  feed                |     List all activity for the given user or repo.
  followers         |       List all followers and the total follower count.
  following           |     List all followed users and the total followed count.
  gitignore-template    |   Output the gitignore template for the given language.
  gitignore-templates  |    Output all supported gitignore templates.
  issue               |     Output detailed information about the given issue.
  issues             |      List all issues matching the filter.
  license            |      Output the license template for the given license.
  licenses            |     Output all supported license templates.
  me                   |    List information about the logged in user.
  notifications         |   List all notifications.
  octo                   |  Output an Easter egg or the given message from Octocat.
  pull-request           |  Output detailed information about the given pull request.
  pull-requests          |  List all pull requests.
  rate-limit             |  Output the rate limit.  Not available for Enterprise.
  repo                   |  Output detailed information about the given filter.
  repos                  |  List all repos matching the given filter.
  search-issues          |  Search for all issues matching the given query.
  search-repos           |  Search for all repos matching the given query.
  starred                |  Output starred repos.
  trending               |  List trending repos for the given language.
  user                   |  List information about the given user.
  view                   |  View the given index in the terminal or a browser.

### `Gitsome`查看`Github`上的流行库

```
gh trending objective-c  -w -p
gh trending swift  -w -b
```
`-b`是在浏览器中打开，`-p`是在`shell`中打开,`Github`有时候会抽，建议还是用`-p`

### `Gitsome`查看`Github`的通知、库、拉取请求、账户等信息

#### Searching Repos
Search all Python repos created on or after 2015, with >= 1000 stars:

```
$ gh search-repos "created:>=2015-01-01 stars:>=1000 language:python" --sort stars -p
```
![](http://oc98nass3.bkt.clouddn.com/15164121223660.jpg)


####  Listing Trending Repos and Devs
View trending repos:

```
$ gh trending [language] [-w/--weekly] [-m/--monthly] [-d/--devs] [-b/--browser]
```

#### Viewing Content
The view command
View the previously listed notifications, pull requests, issues, repos, users etc, with HTML nicely formatted for your terminal, or optionally in your browser:

```
$ gh view [#] [-b/--browser]
$ gh view
```
![](http://oc98nass3.bkt.clouddn.com/15164121912056.jpg)



```
gh repos
gh search-repos
gh starred

gh issues
gh pull-requests
gh search-issues

gh notifications
gh trending

gh user
gh me
```

eg. 栗子~

```
$ gh repos
$ gh view 1

$ gh starred
$ gh view 1 -b
$ gh view 1 --browser
```

## Github

>提到`Git`，我觉得很多人会想到`Github`，甚至很多人以为是同一回事，这里有必要提一下~

![Github知乎](http://upload-images.jianshu.io/upload_images/225323-fe9f3e6a5a6ebcd5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

作为关于世界上最大的"同Xin交友"平台，一些常见的特点就不在此说了，感兴趣的可以参考知乎上的这个问题[怎样使用 GitHub？](https://www.zhihu.com/question/20070065)，这里主要介绍一些`Github`上我觉得很好用的插件

### NO.1 [Zenhub](www.zenhub.com) —— GitHub 中的敏捷开发流~
[ZenHub Guide](https://www.zenhub.com/guides#reporting-with-zenhub)
[Zenhub-boards](https://www.zenhub.com/guides/setup-my-zenhub-boards)
[ZenHub - Agile GitHub Project Management](https://www.zenhub.com/guides/setup-my-zenhub-boards)
[Your first sprint using ZenHub](https://www.zenhub.com/guides/your-first-sprint-using-zenhub#what-goes-into-a-sprint)

#### Zenhub issuse template
![](http://oc98nass3.bkt.clouddn.com/2017-07-11-14997767891391.png)

#### ZenHub Board

![ZenHub Board](http://oc98nass3.bkt.clouddn.com/2017-07-11-14997732663573.jpg)
![Sprint-based workflow](http://oc98nass3.bkt.clouddn.com/2017-07-11-14997745630454.jpg)

* New Issues: 新问题：新问题自动登陆。你应该尽快把他们从这里拖出去。

* Icebox: 冰箱：冰箱代表着一个低优先级的产品待办事项。剩下的问题在冰箱上删除它们有助于避免循环提高重复的问题。冰箱的问题不应采取了团队成员的时间和脑力带宽；把想法放入冰箱管道获取他们出来的方式，帮助团队专注于当前的优先事项。

* Backlog: 待办事项：积压问题不是当前的焦点，但您将在某个时刻对它们进行处理。如果他们没有一个GitHub的里程碑，你可以考虑他们的一部分你的“产品积压”。一旦你添加了一个里程碑，它们就成为你的“待办事项待办事项”（即即将在即将到来的Sprint中完成的任务）的一部分。

* In progress:  在进展中：这里的问题应该有大量的细节，比如估计和需求，因为它们是你团队当前的焦点。这就是“你现在在做什么？”理想情况下，每个团队成员都应该一次只做一件事。在这里的任务应该按照优先受让人加入。

* Review/QA: 评审/ QA：使用评审/ QA专栏对团队开放的问题进行评审和测试。通常这意味着代码已经准备好部署，或者已经处于一个登台环境中。

* Done: 完成：如果你问三个人“完成”意味着什么，你可能会得到三种不同的答案。这就是为什么作为团队讨论你的“完成的定义”是非常重要的！
##### 查看看板

* 这种结构是否只包含我们所需要的，仅此而已？我的老板能看一下这个项目并了解她需要做的一切吗？

* 每一个重要的利益相关者代表吗？在设计，市场营销，或QA的人可以看看这个委员会，并知道确切的地方，他或她的帮助是必要的？

* 我们错过了重复的阶段吗？想想你的团队是如何构建产品的。这一切都是为了让问题在董事会中传播。如果你有一个QA部门，例如，你可能需要一个“准备好QA”的管道。

* “完成”真的完成了吗？我的团队知道并理解我们的定义吗？这种经常错过的步骤是任何敏捷项目的关键部分。

##### Epics


GitHub的问题没有真正的层次；它只是一个简单的列表。深入了解哪些问题是相关的、相互阻碍的、依赖于其他工作的，或者是对项目正在进行的工作的感觉是很难确定的。

zenhub add a crucial layer of hierarchy to your GitHub Issues. 
通过史诗，你可以在发布过程中获得更大的端到端控制权。zenhub史诗帮助束相似的任务为工作主题，以帮助您规划和跟踪更大目标的工作。

##### Issue Dependencies

zenhub依赖帮助团队的问题和故事，当运动项目正得到更好的端到端的能见度。这些信息使团队更了解为什么会发生阻塞，以及需要采取哪些措施来减少风险。


##### 流程

* 新的反馈和想法自动降落在新的问题管道中。

* 产品负责人审查每一个问题，并计算出如果它是可操作的。
注：“产品拥有者”指的是对最终产品和何时进行最终呼叫的人。通常，它是一个项目或产品经理。

* 如果你打算完成一个问题，但它还没有准备好开发（需要更多的细节或者团队没有额外工作的能力），这个问题被拖到了积压。这里的问题还没有一个里程碑。您将在冲刺开始时添加一个。

* 如果它是一个有价值的问题，但你没有计划去解决它在即将到来的冲刺，“冻结”在冰箱管道。

* 如果问题不能解决，就关闭它。如果它真的那么重要，你可以随时重新打开它！

* 问题准备好了吗？在这一点上，您的团队应该添加一些细节，如验收要求和用户故事（从用户利益的角度来描述一个简短的特性描述）。一旦一个评估和一个里程碑被附加到一个问题上，它就正式地成为你的“待办事项积压”（你将在下一次冲刺中处理的东西）。

* 当`Sprint`开始时，只需按里程碑过滤板子，看看需要做些什么。团队成员可以将任务拖到积压的顶部，以指示它们正在工作。简单的！

##### Your first sprint with Zenhub

从熟悉GitHub的里程碑和完成报告，成为更有效的利用zenhub冲刺计划，这将确保你知道插件和冲刺计划的最佳实践与ZenHub出局。

冲刺前要回答的重要问题

* 我们实际能处理多少工作？
* 我们真的能在接下来的两周内完成所有这些工作吗？我们可能从范围中删除哪些问题？
* 您的团队在Sprint计划前应处理的所有问题。但是你如何得到这些问题的答案呢？
你的几次冲刺，为了回答这些问题，最好的办法就是跟你的团队和有关于复杂性的工作你想完全开放的对话，以及确保应对即将到来的关键期限内必须完成。

* 决定什么进入你的冲刺

* 要想在里程碑中添加哪些问题，您需要有一个健康的产品待办事项清单。
* 
这意味着你的问题应该有：

* 估计你和你的团队一起决定

* 一个用户故事，它描述一个任务的对象和原因，以及任何需求。不要担心添加太多的细节-你会发现更多的信息，一旦你开始你的里程碑。

* 根据发行商的业务价值确定优先权

##### 创建使用GitHub的里程碑第一冲刺


为与终点一致的里程碑选择一个截止日期。一个经验法则来决定一个冲刺应该多长时间，如果你还没有测量时间的工作时间，那就是问问自己是否能得到一个新的特性或增强，团队在你所创建的时间范围内完成整个开发周期。

如果2周看起来太短了，那么看看你的问题，问问自己是不是太大了，不值得处理。将工作分解成更小的块不仅提高了它们被运送的可能性，而且消除了延迟发布的潜在缺陷数量。

一旦创建了里程碑，就应该向您的Sprint添加问题了！回到主板选项卡开始。

既然已经将Sprint定义为里程碑，那么您就可以计划在Sprint中完成什么工作了。记住一件事情，为你准备一个冲刺，从来没有一支球队拥有所有的信息需要向前完美的依赖，冲突，或某些bug修复可能出现的紧迫性…所有这些都是计划外的工作。

这些计划中的许多情况可以在计划会议中发现，也称作Sprint计划。在开始第一次冲刺之前，快速交谈是一个讨论的平台。

##### 向Sprint添加用户故事和任务

在GitHub上，一旦你添加了问题的一个里程碑，他们可以被认为是一个冲刺积压`Backlog`的一部分。

Sprint积压`Backlog`与产品积压`product backlog`问题不同，在您的积压管道中没有里程碑的是您的“产品待办事项”——这些事情您最终将处理，但不是您下一个工作的直接冲刺的一部分。Sprint积压是您的团队承诺在接下来的2周时间内完成的所有问题（或者您用来定义自己迭代的时间表）。

在一个项目的开始，估计是最好的猜测。与瀑布开发相反，大多数敏捷团队现在都会在任务和项目中发现更多关于任务的细节。在项目开始的时候你不会知道太多，这没关系。

为什么要估算软件？估算一个任务是有帮助的，当你整理你的Sprint待办事项：给定的预算和固定的时间，你怎么知道哪些问题要处理，如果不是为了估计？

其次，当历史数据配对（如速度图），估计照明如何快速你真的动–具有洞察力的有效项目管理的一个重要GitHub。

#### CircleCI

持续集成 — [Circleci](https://circleci.com/)
后续更新中...

#### Reviewable

代码Review — Reviewable
[Reviewable](https://reviewable.io/) GitHub code reviews done right
后续更新中...
#### Coveralls

[Coveralls](www.coveralls.com)
代码覆盖率 — Coveralls

后续更新中...


## Gitlab-CI

### 参考[GitLab Continuous Integration & Deployment Pipelines](https://about.gitlab.com/features/gitlab-ci-cd/)

1. [使用Gitlab CI进行持续集成](http://www.jianshu.com/p/315cfa4f9e3e)
2. 使用`Travis CI`[Travis CI 自动部署 Hexo 博客到 Github(带主题版)](http://ixiusama.com/2017/01/03/hexo-Automatic-deployment-on-github-theme-next/#more)
3. [GitLab integration #5931](https://github.com/travis-ci/travis-ci/issues/5931)
4. [How do travis-ci and gitlab-ci compare?](http://stackoverflow.com/questions/31338775/how-do-travis-ci-and-gitlab-ci-compare)


## 参考

1. [图解Git](https://marklodato.github.io/visual-git-guide/index-zh-cn.html#commands-in-detail)
2. [**git - the simple guide - no deep shit!**](http://rogerdudler.github.io/git-guide/index.zh.html)
3. [**LearnGitBranching**](http://learngitbranching.js.org/?NODEMO)
4. [**git-flow 备忘清单**](http://danielkummer.github.io/git-flow-cheatsheet/index.zh_CN.html)
5. [Gitsome](https://github.com/donnemartin/gitsome)
6. [Git Recipes](https://github.com/geeeeeeeeek/git-recipes/wiki)
7. [GitHub 漫游指南](https://player.vimeo.com/video/220706046/)

