## Git Learning


### Git Tips

1. Git跟踪的是文件file的路径和内容，但是对文件夹并不清楚，无法追踪空的文件夹，如果需要在仓库中建立空文件夹到Git，需要在文件夹内添加一个隐藏文件`.keep`或者`.gitkkeep`.

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


