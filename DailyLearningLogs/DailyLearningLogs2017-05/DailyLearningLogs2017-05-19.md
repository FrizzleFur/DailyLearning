# DailyLearningLogs  2017-05-19

## Todo

- [x] Running~  (2017-05-19)
- [x] 《养眼就是养精神》CornellNote (2017-05-20)

## Done

- [x] 整理项目结构模块 (2017-05-18)
- [x] Gitsome （2017-05-19）
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

