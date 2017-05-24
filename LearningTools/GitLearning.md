## Git Learning

记录小白学习`Git`的过程，如有错误，万望指正，感激不尽。

`2017-05-01`

>The Git workflow consists of editing files in the working directory, adding files to the staging area, and saving changes to a Git repository. In Git, we save changes with a commit, which we will learn more about in this lesson.

##### Git
A Git project can be thought of as having three parts:

![](http://oc98nass3.bkt.clouddn.com/14936106948535.jpg)

1. A Working Directory: where you'll be doing all the work: creating, editing, deleting and organizing files
2. A Staging Area: where you'll list changes you make to the working directory
3. A Repository: where Git permanently stores those changes as different versions of the project

![](http://oc98nass3.bkt.clouddn.com/14936109243775.jpg)

##### 工作区、版本库、暂存区原理图

![](http://oc98nass3.bkt.clouddn.com/14936261372760.png)
在这个图中，可以看到部分Git命令是如何影响工作区和暂存区（stage，亦称index）的。下面就对这些命令进行简要的说明，而要彻底揭开这些命令的面纱要在接下来的几个章节。
图中左侧为工作区，右侧为版本库。在版本库中标记为index的区域是暂存区（stage，亦称index），标记为master的是master分支所代表的目录树。
图中可以看出此时HEAD实际是指向master分支的一个“游标”。所以图示的命令中出现HEAD的地方可以用master来替换。
图中的objects标识的区域为Git的对象库，实际位于.git/objects目录下，会在后面的章节重点介绍。
当对工作区修改（或新增）的文件执行git add命令时，暂存区的目录树被更新，同时工作区修改（或新增）的文件内容被写入到对象库中的一个新的对象中，而该对象的ID被记录在暂存区的文件索引中。
当执行提交操作（git commit）时，暂存区的目录树写到版本库（对象库）中，master分支会做相应的更新。即master最新指向的目录树就是提交时原暂存区的目录树。
当执行git reset HEAD命令时，暂存区的目录树会被重写，被master分支指向的目录树所替换，但是工作区不受影响。
当执行git rm –cached <file>命令时，会直接从暂存区删除文件，工作区则不做出改变。
当执行git checkout .或者git checkout – <file>命令时，会用暂存区全部或指定的文件替换工作区的文件。这个操作很危险，会清除工作区中未添加到暂存区的改动。
当执行git checkout HEAD .或者git checkout HEAD <file>命令时，会用HEAD指向的master分支中的全部或者部分文件替换暂存区和以及工作区中的文件。这个命令也是极具危险性的，因为不但会清除工作区中未提交的改动，也会清除暂存区中未提交的改动。

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

#### 设置`git`命令 别名
`$ git config --global alias.st status`
`$ git config --global alias.co checkout`
`$ git config --global alias.ct commit`
`$ git config --global alias.df diff`
`$ git config --global alias.br branch`

#### `Git`删除文件

[git 删除文件](http://www.jianshu.com/p/c3ff8f0da85e)

#### 深入了解git reset命令
![](http://oc98nass3.bkt.clouddn.com/14936268028934.png)

重置命令（git reset）是Git最常用的命令之一，也是最危险，最容易误用的命令。来看看git reset命令的用法。
用法一： git reset [-q] [<commit>] [--] <paths>...
用法二： git reset [--soft | --mixed | --hard | --merge | --keep] [-q] [<commit>]
上面列出了两个用法，其中 <commit> 都是可选项，可以使用引用或者提交ID，如果省略 <commit> 则相当于使用了HEAD的指向作为提交ID。
上面列出的两种用法的区别在于，第一种用法在命令中包含路径<paths>。为了避免路径和引用（或者提交ID）同名而冲突，可以在<paths>前用两个连续的短线（减号）作为分隔。
第一种用法（包含了路径<paths>的用法）不会重置引用，更不会改变工作区，而是用指定提交状态（<commit>）下的文件（<paths>）替换掉暂存区中的文件。例如命令git reset HEAD <paths>相当于取消之前执行的git add <paths>命令时改变的暂存区。
第二种用法（不使用路径<paths>的用法）则会重置引用。根据不同的选项，可以对暂存区或者工作区进行重置。参照下面的版本库模型图，来看一看不同的参数对第二种重置语法的影响。

#### 深入了解git checkout命令
检出命令（git checkout）是Git最常用的命令之一，同样也很危险，因为这条命令会重写工作区。
```
用法一： git checkout [-q] [<commit>] [--] <paths>...
用法二： git checkout [<branch>]
用法三： git checkout [-m] [[-b|--orphan] <new_branch>] [<start_point>]
```
![](http://oc98nass3.bkt.clouddn.com/14936268612321.jpg)

下面通过一些示例，具体的看一下检出命令的不同用法。
>命令：git checkout branch
检出branch分支。要完成如图的三个步骤，更新HEAD以指向branch分支，以branch指向的树更新暂存区和工作区。
命令：git checkout
汇总显示工作区、暂存区与HEAD的差异。
命令：git checkout HEAD
同上。
命令：git checkout – filename
用暂存区中filename文件来覆盖工作区中的filename文件。相当于取消自上次执行git add filename以来（如果执行过）本地的修改。
这个命令很危险，因为对于本地的修改会悄无声息的覆盖，毫不留情。
命令：git checkout branch – filename
维持HEAD的指向不变。将branch所指向的提交中的filename替换暂存区和工作区中相应的文件。注意会将暂存区和工作区中的filename文件直接覆盖。
命令：git checkout – . 或写做 git checkout .
注意：git checkout命令后的参数为一个点（“.”）。这条命令最危险！会取消所有本地的修改（相对于暂存区）。相当于将暂存区的所有文件直接覆盖本地文件，不给用户任何确认的机会！

#### 用reflog挽救错误的重置
如果没有记下重置前master分支指向的提交ID，想要重置回原来的提交真的是一件麻烦的事情（去对象库中一个一个地找）。幸好Git提供了一个挽救机制，通过.git/logs目录下日志文件记录了分支的变更。默认非裸版本库（带有工作区）都提供分支日志功能，这是因为带有工作区的版本库都有如下设置：
$ git config core.logallrefupdates
true
查看一下master分支的日志文件.git/logs/refs/heads/master中的内容。下面命令显示了该文件的最后几行。为了排版的需要，还将输出中的40位的SHA1提交ID缩短。
$ tail -5 .git/logs/refs/heads/master
dca47ab a0c641e Jiang Xin <jiangxin@ossxp.com> 1290999606 +0800    commit (amend): who does commit?
a0c641e e695606 Jiang Xin <jiangxin@ossxp.com> 1291022581 +0800    commit: which version checked in?
e695606 4902dc3 Jiang Xin <jiangxin@ossxp.com> 1291435985 +0800    commit: does master follow this new commit?
4902dc3 e695606 Jiang Xin <jiangxin@ossxp.com> 1291436302 +0800    HEAD^: updating HEAD
e695606 9e8a761 Jiang Xin <jiangxin@ossxp.com> 1291436382 +0800    9e8a761: updating HEAD
可以看出这个文件记录了master分支指向的变迁，最新的改变追加到文件的末尾因此最后出现。最后一行可以看出因为执行了git reset –hard命令，指向的提交ID由e695606改变为9e8a761。
Git提供了一个git reflog命令，对这个文件进行操作。使用show子命令可以显示此文件的内容。
$ git reflog show master | head -5
9e8a761 master@{0}: 9e8a761: updating HEAD
e695606 master@{1}: HEAD^: updating HEAD
4902dc3 master@{2}: commit: does master follow this new commit?
e695606 master@{3}: commit: which version checked in?
a0c641e master@{4}: commit (amend): who does commit?
使用git reflog的输出和直接查看日志文件最大的不同在于显示顺序的不同，即最新改变放在了最前面显示，而且只显示每次改变的最终的SHA1哈希值。还有个重要的区别在于使用git reflog的输出中还提供一个方便易记的表达式：<refname>@{<n>}。这个表达式的含义是引用<refname>之前第<n>次改变时的SHA1哈希值。
那么将引用master切换到两次变更之前的值，可以使用下面的命令。
重置master为两次改变之前的值。
$ git reset --hard master@{2}
HEAD is now at 4902dc3 does master follow this new commit?
重置后工作区中文件new-commit.txt又回来了。
$ ls
new-commit.txt  welcome.txt
提交历史也回来了。
$ git log --oneline
4902dc3 does master follow this new commit?
e695606 which version checked in?
a0c641e who does commit?
9e8a761 initialized.
此时如果再用git reflog查看，会看到恢复master的操作也记录在日志中了。
$ git reflog show master | head -5
4902dc3 master@{0}: master@{2}: updating HEAD
9e8a761 master@{1}: 9e8a761: updating HEAD
e695606 master@{2}: HEAD^: updating HEAD
4902dc3 master@{3}: commit: does master follow this new commit?
e695606 master@{4}: commit: which version checked in?

### Git分支
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


### Git撤销方法

1. `git revert <SHA>`
2. `git commit --amend -m "Modify last add message"`
3. 撤销本地的修改`git checkout -- <bad filename>`
4. 重置本地的修改`git reset <last good SHA>`

[Git的各种Undo技巧](https://tonydeng.github.io/2015/07/08/how-to-undo-almost-anything-with-git/)


### Git 冲突

1. 代码冲突“! [rejected] master -> master (non-fast-forward)”的原因以及解决办法：
 ! [rejected]        master ->  master (non-fast-forward)  
error: failed to push some refs to 'git@github.com:archermind/LEDTorch.apk-for-Android.git'  
To prevent you from losing history, non-fast-forward updates were rejected  
Merge the remote changes before pushing again.  See the 'Note about  
fast-forwards' section of 'git push --help' for details.  

**操作命令：**


*  正确的做法是，在push之前git fetch origin，将github上的新代码拉下来，然后在本地merge，如果没有冲突就可以push了，如果有冲突的话要在本地解决冲突后，再push。具体做法就是。

`git fetch origin`
`git merge origin (master)`
* 这两步其实可以简化为`git pull origin master`
>`git push origin master`

### issue
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

## Gitlab-CI

### 参考[GitLab Continuous Integration & Deployment Pipelines](https://about.gitlab.com/features/gitlab-ci-cd/)

1. [使用Gitlab CI进行持续集成](http://www.jianshu.com/p/315cfa4f9e3e)
2. 使用`Travis CI`[Travis CI 自动部署 Hexo 博客到 Github(带主题版)](http://ixiusama.com/2017/01/03/hexo-Automatic-deployment-on-github-theme-next/#more)
3. [GitLab integration #5931](https://github.com/travis-ci/travis-ci/issues/5931)
4. [How do travis-ci and gitlab-ci compare?](http://stackoverflow.com/questions/31338775/how-do-travis-ci-and-gitlab-ci-compare)

## Gitsome
[Gitsome](https://github.com/donnemartin/gitsome) （2017-05-19）
花了些时间，把`Python`环境换成`V3.5`的，搞好`Gitsome`。发现几个比较好用的命令😝
### 一、查看`Github`上的流行库
`gh trending objective-c  -w -p`
`gh trending swift  -w -b`
`-b`是在浏览器中打开，`-p`是在`shell`中打开,`Github`有时候会抽，建议还是用`-p`
### 二、 查看`github`的通知、库、拉取请求、账户等信息
`gh view`

>View the given notification/repo/issue/pull_request/user index in the terminal or a browser.

>This method is meant to be called after one of the following commands which outputs a table of notifications/repos/issues/pull_requests/users:


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

栗子~


```
$ gh repos
$ gh view 1

$ gh starred
$ gh view 1 -b
$ gh view 1 --browser
```

## 参考

1. [图解Git](https://marklodato.github.io/visual-git-guide/index-zh-cn.html#commands-in-detail)
2. [Gitsome](https://github.com/donnemartin/gitsome)




