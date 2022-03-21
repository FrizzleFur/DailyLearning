# 工具-GitCommit-gitmoji



[carloscuesta/gitmoji: An emoji guide for your commit messages. 😜](https://github.com/carloscuesta/gitmoji)


![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220321082624.png)


### commit 格式

`git commit` 时，提交信息遵循以下格式：

```sh
:emoji1: :emoji2: 主题

提交信息主体

Ref <###>12345
```

初次提交示例：

```sh
git commit -m ":tada: Initialize Repo"1
```


## 使用示例

如果您需要一些想法来将 gitmoji 集成到您的项目中，这里有一个实用的方法来使用它：

```
<intention> [scope?][:?] <message>

```

*   `intention`：列表中的表情符号。
*   `scope`: 一个可选字符串，为更改范围添加上下文信息。
*   `message:`更改的简要说明。


### emoji 指南

| emoji | emoji 代码 | commit 说明 |
| :-- | :-- | :-- |
| :art: (调色板) | `:art:` | 改进代码结构/代码格式 |
|*   :zap: (闪电):racehorse: (赛马) | *   `:zap:“:racehorse:` | 提升性能 |
| :fire: (火焰) | `:fire:` | 移除代码或文件 |
| :bug: (bug) | `:bug:` | 修复 bug |
| :ambulance: (急救车) | `:ambulance:` | 重要补丁 |
| :sparkles: (火花) | `:sparkles:` | 引入新功能 |
| :memo: (备忘录) | `:memo:` | 撰写文档 |
| :rocket: (火箭) | `:rocket:` | 部署功能 |
| :lipstick: (口红) | `:lipstick:` | 更新 UI 和样式文件 |
| :tada: (庆祝) | `:tada:` | 初次提交 |
| :white_check_mark: (白色复选框) | `:white_check_mark:` | 增加测试 |
| :lock: (锁) | `:lock:` | 修复安全问题 |
| :apple: (苹果) | `:apple:` | 修复 macOS 下的问题 |
| :penguin: (企鹅) | `:penguin:` | 修复 Linux 下的问题 |
| :checkered_flag: (旗帜) | `:checked_flag:` | 修复 Windows 下的问题 |
| :bookmark: (书签) | `:bookmark:` | 发行/版本标签 |
| :rotating_light: (警车灯) | `:rotating_light:` | 移除 linter 警告 |
| :construction: (施工) | `:construction:` | 工作进行中 |
| :green_heart: (绿心) | `:green_heart:` | 修复 CI 构建问题 |
| :arrow_down: (下降箭头) | `:arrow_down:` | 降级依赖 |
| :arrow_up: (上升箭头) | `:arrow_up:` | 升级依赖 |
| :construction_worker: (工人) | `:construction_worker:` | 添加 CI 构建系统 |
| :chart_with_upwards_trend: (上升趋势图) | `:chart_with_upwards_trend:` | 添加分析或跟踪代码 |
| :hammer: (锤子) | `:hammer:` | 重大重构 |
| :heavy_minus_sign: (减号) | `:heavy_minus_sign:` | 减少一个依赖 |
| :whale: (鲸鱼) | `:whale:` | Docker 相关工作 |
| :heavy_plus_sign: (加号) | `:heavy_plug_sign:` | 增加一个依赖 |
| :wrench: (扳手) | `:wrench:` | 修改配置文件 |
| :globe_with_meridians: (地球) | `:globe_with_meridians:` | 国际化与本地化 |
| :pencil2: (铅笔) | `:pencil2:` | 修复 typo |


## Using [gitmoji-cli](https://github.com/carloscuesta/gitmoji-cli)

To use gitmojis from your command line install [gitmoji-cli](https://github.com/carloscuesta/gitmoji-cli). A gitmoji interactive client for using emojis on commit messages.

```source-shell
npm i -g gitmoji-cli
```

## [](https://github.com/carloscuesta/gitmoji#example-of-usage)