## Git统计

# [git代码统计](https://segmentfault.com/a/1190000008542123)

[](https://segmentfault.com/a/1190000008542123)

*   [git](https://segmentfault.com/t/git/blogs)

## 命令行

### 查看git上的个人代码量：

```
git log --author="username" --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "added lines: %s, removed lines: %s, total lines: %s\n", add, subs, loc }' -
```

结果示例：(记得修改 username)

```
added lines: 120745, removed lines: 71738, total lines: 49007
```

### 统计每个人增删行数

```
git log --format='%aN' | sort -u | while read name; do echo -en "$name\t"; git log --author="$name" --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "added lines: %s, removed lines: %s, total lines: %s\n", add, subs, loc }' -; done
```

结果示例

```
Max-laptop    added lines: 1192, removed lines: 748, total lines: 444
chengshuai    added lines: 120745, removed lines: 71738, total lines: 49007
cisen    added lines: 3248, removed lines: 1719, total lines: 1529
max-h    added lines: 1002, removed lines: 473, total lines: 529
max-l    added lines: 2440, removed lines: 617, total lines: 1823
mw    added lines: 148721, removed lines: 6709, total lines: 142012
spider    added lines: 2799, removed lines: 1053, total lines: 1746
thy    added lines: 34616, removed lines: 13368, total lines: 21248
wmao    added lines: 12, removed lines: 8, total lines: 4
xrl    added lines: 10292, removed lines: 6024, total lines: 4268
yunfei.huang    added lines: 427, removed lines: 10, total lines: 417
³ö    added lines: 5, removed lines: 3, total lines: 2
```

### 查看仓库提交者排名前 5

```
git log --pretty='%aN' | sort | uniq -c | sort -k1 -n -r | head -n 5
```

### 贡献值统计

```
git log --pretty='%aN' | sort -u | wc -l
```

### 提交数统计

```
git log --oneline | wc -l
```

### 添加或修改的代码行数：

```
git log --stat|perl -ne 'END { print $c } $c += $1 if /(\d+) insertions/'
```

## 使用gitstats

[GitStats项目](https://github.com/hoxu/gitstats)，用Python开发的一个工具，通过封装Git命令来实现统计出来代码情况并且生成可浏览的网页。官方文档可以参考这里。

### 使用方法

```
git clone git://github.com/hoxu/gitstats.git
cd gitstats
./gitstats 你的项目的位置 生成统计的文件夹位置
```

可能会提示没有安装gnuplot画图程序，那么需要安装再执行：

```
//mac osx
brew install gnuplot
//centos linux
yum install gnuplot
```

生成的统计文件为HTML：
![2014-8-16-git.jpg](https://segmentfault.com/img/bVJ0s4?w=900&h=675 "2014-8-16-git.jpg")

## 使用cloc

```
npm install -g cloc
```

![image](https://segmentfault.com/img/remote/1460000010648166 "image")

## 参考文章

[git代码行统计命令集](http://www.jianshu.com/p/8fd14064c201)
[统计本地Git仓库中不同贡献者的代码行数的一些方法](http://www.94joy.com/archives/115#comment-319)
[使用Git工具统计代码](http://blog.cyeam.com/kaleidoscope/2015/01/17/gitstats)