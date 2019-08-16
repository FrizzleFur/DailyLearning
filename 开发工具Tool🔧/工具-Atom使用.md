# 工具-Atom使用


## 常用快捷键
Atom 专门有个模块列出所有的快捷键，这里给出一些常用的供大家参考：

# 快捷键

## 文件切换

| 快捷键 | 快捷键的功能 |
| --- | --- |
| `cmd-shift-o` | 打开目录 |
| `cmd-\` | 显示或隐藏目录树 |
| `ctrl-0` | 焦点移到目录树 注意这里是数字 0 非常实用也可以用 `cmd+\`来变相达到效果 |
| `使用a，m，delete` | 目录树下，使用a，m，delete来增加，修改和删除 |
| `cmd-t 或 cmd-p` | 查找文件 |
| `cmd-b` | 在打开的文件之间切换 |
| `cmd-shift-b` | 只搜索从上次 git commit 后修改或者新增的文件 |

## 导航

| 快捷键 | 快捷键的功能 |
| --- | --- |
| `ctrl-p` | 前一行 |
| `ctrl-n` | 后一行 |
| `ctrl-f` | 前一个字符 |
| `ctrl-b` | 后一个字符 |
| `alt-B, alt-left` | 移动到单词开始 |
| `alt-F, alt-right` | 移动到单词末尾 |
| `cmd-right, ctrl-E` | 移动到一行结束 |
| `cmd-left, ctrl-A` | 移动到一行开始 |
| `cmd-up` | 移动到文件开始 |
| `cmd-down` | 移动到文件结束 |
| `ctrl-g` | 移动到指定行 row:column 处 |
| `cmd-r` | 在方法之间跳转 |

## 目录树操作

| 快捷键 | 快捷键的功能 |
| --- | --- |
| `cmd-\` 或者 `cmd-k cmd-b` | 显示(隐藏)目录树 |
| `ctrl-0` | 焦点切换到目录树(再按一次或者Esc退出目录树) |
| 在目录下 |
| `a` | 添加文件 |
| `d` | 将当前文件另存为(duplicate) |
| `i` | 显示(隐藏)版本控制忽略的文件 |
| `alt-right` 和 `alt-left` | 展开(隐藏)所有目录 |
| `ctrl-al-]` 和 `ctrl-al-[` | 同上 |
| `ctrl-[` 和 `ctrl-]` | 展开(隐藏)当前目录 |
| `cmd-k h` 或者 `cmd-k left` | 在左半视图中打开文件 |
| `cmd-k j` 或者 `cmd-k down` | 在下半视图中打开文件 |
| `cmd-k k` 或者 `cmd-k up` | 在上半视图中打开文件 |
| `cmd-k l` 或者 `cmd-k right` | 在右半视图中打开文件 |
| `ctrl-shift-C` | 复制当前文件绝对路径 |

## 分屏操作

| 快捷键 | 快捷键的功能 |
| --- | --- |
| `cmd-k h` 或者 `cmd-k left` | 在左半视图中打开文件 |
| `cmd-k j` 或者 `cmd-k down` | 在下半视图中打开文件 |
| `cmd-k k` 或者 `cmd-k up` | 在上半视图中打开文件 |
| `cmd-k l` 或者 `cmd-k right` | 在右半视图中打开文件 |
| `cmd-k cmd-k` 或者 `cmd-k cmd-right` | 在右半视图中打开文件 |

## 书签

| 快捷键 | 快捷键的功能 |
| --- | --- |
| `cmd-F2` | 在本行增加书签 |
| `F2` | 跳到当前文件的下一条书签 |
| `shift-F2` | 跳到当前文件的上一条书签 |
| `ctrl-F2` | 列出当前工程所有书签 |

## 选取

> 大部分和导航一致，只不过加上shift

| 快捷键 | 快捷键的功能 |
| --- | --- |
| `ctrl-shift-P` | 选取至上一行 |
| `ctrl-shift-N` | 选取至下一样 |
| `ctrl-shift-B` | 选取至前一个字符 |
| `ctrl-shift-F` | 选取至后一个字符 |
| `alt-shift-B`, `alt-shift-left` | 选取至字符开始 |
| `alt-shift-F`, `alt-shift-right` | 选取至字符结束 |
| `ctrl-shift-E`, `cmd-shift-right` | 选取至本行结束 |
| `ctrl-shift-A`, `cmd-shift-left` | 选取至本行开始 |
| `cmd-shift-up` | 选取至文件开始 |
| `cmd-shift-down` | 选取至文件结尾 |
| `cmd-A` | 全选 |
| `cmd-L` | 选取一行，继续按回选取下一行 |
| `ctrl-shift-W` | 选取当前单词 |

## 编辑和删除文本

| 快捷键 | 快捷键的功能 |
| --- | --- |
| `ctrl-T` | 使光标前后字符交换 |
| `cmd-J` | 将下一行与当前行合并 |
| `ctrl-cmd-up`, `ctrl-cmd-down` | 使当前行向上或者向下移动 |
| `cmd-shift-D` | 复制当前行到下一行 |

## Atom大小写转换

| 快捷键 | 快捷键的功能 |
| --- | --- |
| `cmd-K`, `cmd-U` | 使当前字符大写 |
| `cmd-K`, `cmd-L` | 使当前字符小写 |

## 删除和剪切

| 快捷键 | 快捷键的功能 |
| --- | --- |
| `ctrl-shift-K` | 删除当前行 |
| `cmd-backspace` | 删除到当前行开始 |
| `cmd-fn-backspace` | 删除到当前行结束 |
| `ctrl-K` | 剪切到当前行结束 |
| `alt-backspace` 或 `alt-H` | 删除到当前单词开始 |
| `alt-delete` 或 `alt-D` | 删除到当前单词结束 |

## 多光标和多处选取

| 快捷键 | 快捷键的功能 |
| --- | --- |
| `cmd-click` | 增加新光标 |
| `cmd-shift-L` | 将多行选取改为多行光标 |
| `ctrl-shift-up`, `ctrl-shift-down` | 增加上（下）一行光标 |
| `cmd-D` | 选取文档中和当前单词相同的下一处 |
| `ctrl-cmd-G` | 选取文档中所有和当前光标单词相同的位置 |

## 括号跳转

| 快捷键 | 快捷键的功能 |
| --- | --- |
| `ctrl-m` | 相应括号之间，html tag之间等跳转 |
| `ctrl-cmd-m` | 括号(tag)之间文本选取 |
| `alt-cmd-.` | 关闭当前XML/HTML tag |

## 编码方式

| 快捷键 | 快捷键的功能 |
| --- | --- |
| `ctrl-shift-U` | 调出切换编码选项 |

## 查找和替换

| 快捷键 | 快捷键的功能 |
| --- | --- |
| `cmd-F` | 在buffer中查找 |
| `cmd-shift-f` | 在整个工程中查找 |

## 代码片段

| 快捷键 | 快捷键的功能 |
| --- | --- |
| `alt-shift-S` | 查看当前可用代码片段 |

> 在~/.atom目录下snippets.cson文件中存放了你定制的snippets

## 折叠

| 快捷键 | 快捷键的功能 |
| --- | --- |
| `alt-cmd-[` | 折叠 |
| `alt-cmd-]` | 展开 |
| `alt-cmd-shift-{` | 折叠全部 |
| `alt-cmd-shift-}` | 展开全部 |
| `cmd-k cmd-N` | 指定折叠层级 N为层级数 |

## 文件语法高亮

| 快捷键 | 快捷键的功能 |
| --- | --- |
| `ctrl-shift-L` | 选择文本类型 |

## 使用Atom进行写作

| 快捷键 | 快捷键的功能 |
| --- | --- |
| `ctrl-shift-M` | Markdown预览 |

> 可用代码片段

> ```
> b, legal, img, l, i, code, t, table
> 
> ```

## git操作

| 快捷键 | 快捷键的功能 |
| --- | --- |
| `cmd-alt-z checkout` | HEAD 版本cmd-shift-B 弹出untracked 和 modified文件列表 |
| `alt-g down alt-g up` | 在修改处跳转 |
| `alt-G D` | 弹出diff列表 |
| `alt-G O` | 在github上打开文件 |
| `alt-G G` | 在github上打开项目地址 |
| `alt-G B` | 在github上打开文件blame |
| `alt-G H` | 在gitmhub上打开文件history |
| `alt-G I` | 在github上打开issues |
| `alt-G R` | 在github打开分支比较 |
| `alt-G C` | 拷贝当前文件在gihub上的网址 |

## 配置

# 插件

* minimap-git-diff
* linter
* git-control
* tree-view-git-status
* atom-beautify
* ide-swift
* swift-debugger
* [autocomplete-paths](https://atom.io/packages/autocomplete-paths)
* [minimap](https://atom.io/packages/minimap)

### 备份

* sync-settings
* [sync-settings](https://atom.io/packages/sync-settings)

* Open Sync Settings configuration in Atom Settings.
* Create a new personal access token which has the gist scope and be sure to activate permissions: Gist -> create gists.
* Copy the access token to Sync Settings configuration or set it as an environmental variable GITHUB_TOKEN.
* Create a new gist:
* The description can be left empty. It will be set when invoking the backup command the first time.
* Use packages.json as the filename.
* Put some arbitrary non-empty content into the file. It will be overwritten by the first invocation of the backup command
* Save the gist.
* Copy the gist id (last part of url after the username) to Sync Settings configuration or set it as an environmental variable GIST_ID.


## 参考

1. [mehcode/awesome-atom: A curated list of delightful Atom packages and resources.](awesome-atom/README-cn.md at master · iawia002/awesome-atom)
2. [iawia002/awesome-atom: Some useful Atom packages](https://github.com/iawia002/awesome-atom)
3. [查找和替换 · Atom Flight Manual](http://mazhuang.org/atom-flight-manual/chapter-2-using-atom/find-and-replace.html)

