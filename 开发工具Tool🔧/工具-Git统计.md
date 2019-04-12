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


1.显示所有贡献者及其commit数

git shortlog --numbered --summary
2.只看某作者提交的commit：

git log --author="eisneim" --oneline --shortstat

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

Basic usage

```source-r
# by dir
cloc(system.file("extdata", package="cloc"))
#> # A tibble: 3 x 10
#>   source  language file_count file_count_pct   loc loc_pct blank_lines blank_line_pct comment_lines comment_line_pct
#>   <chr>   <chr>         <int>          <dbl> <int>   <dbl>       <int>          <dbl>         <int>            <dbl>
#> 1 extdata C++               1          0.333   142  0.493           41         0.621             63           0.457 
#> 2 extdata R                 1          0.333   138  0.479           24         0.364             71           0.514 
#> 3 extdata Java              1          0.333     8  0.0278           1         0.0152             4           0.0290

# by file
cloc(system.file("extdata", "qrencoder.cpp", package="cloc"))
#> # A tibble: 1 x 10
#>   source     language file_count file_count_pct   loc loc_pct blank_lines blank_line_pct comment_lines comment_line_pct
#>   <chr>      <chr>         <int>          <dbl> <int>   <dbl>       <int>          <dbl>         <int>            <dbl>
#> 1 qrencoder… C++               1             1\.   142      1\.          41             1\.            63               1.

# from a url
cloc("https://rud.is/dl/cloc-1.74.tar.gz")
#> # A tibble: 93 x 10
#>    source   language  file_count file_count_pct   loc loc_pct blank_lines blank_line_pct comment_lines comment_line_pct
#>    <chr>    <chr>          <int>          <dbl> <int>   <dbl>       <int>          <dbl>         <int>            <dbl>
#>  1 cloc-1.… Perl               5        0.0180  19712  0.598         1353       0.420             2430          0.443  
#>  2 cloc-1.… YAML             141        0.507    2887  0.0876           1       0.000311           141          0.0257 
#>  3 cloc-1.… Markdown           1        0.00360  2195  0.0666         226       0.0702              26          0.00474
#>  4 cloc-1.… ANTLR Gr…          2        0.00719  1012  0.0307         200       0.0621              59          0.0108 
#>  5 cloc-1.… R                  3        0.0108    698  0.0212          95       0.0295             312          0.0569 
#>  6 cloc-1.… C/C++ He…          1        0.00360   617  0.0187         191       0.0593             780          0.142  
#>  7 cloc-1.… C++                4        0.0144    570  0.0173         132       0.0410             173          0.0315 
#>  8 cloc-1.… Forth              2        0.00719   529  0.0160          17       0.00528             84          0.0153 
#>  9 cloc-1.… TypeScri…          3        0.0108    410  0.0124          52       0.0162              39          0.00711
#> 10 cloc-1.… Logtalk            1        0.00360   368  0.0112          59       0.0183              57          0.0104 
#> # ... with 83 more rows
```

Custom CRAN package counter:

```source-r
cloc_cran(c("archdata", "hrbrthemes", "iptools", "dplyr"))
#> # A tibble: 19 x 11
#>    source   language file_count file_count_pct    loc loc_pct blank_lines blank_line_pct comment_lines comment_line_pct
#>    <chr>    <chr>         <dbl>          <dbl>  <dbl>   <dbl>       <dbl>          <dbl>         <dbl>            <dbl>
#>  1 archdat… <NA>             0\.        0\.          0\. 0\.               0\.        0\.                 0\.         0\.      
#>  2 hrbrthe… R               20\.        0.690     927\. 0.627          183\.        0.523            549\.         0.823   
#>  3 hrbrthe… HTML             2\.        0.0690    366\. 0.248           48\.        0.137              2\.         0.00300 
#>  4 hrbrthe… CSS              1\.        0.0345    113\. 0.0765          27\.        0.0771             0\.         0\.      
#>  5 hrbrthe… Rmd              3\.        0.103      35\. 0.0237          78\.        0.223            116\.         0.174   
#>  6 hrbrthe… Markdown         1\.        0.0345     29\. 0.0196          14\.        0.0400             0\.         0\.      
#>  7 hrbrthe… YAML             2\.        0.0690      8\. 0.00541          0\.        0\.                 0\.         0\.      
#>  8 iptools… C++              4\.        0.143     846\. 0.423          167\.        0.408            375\.         0.289   
#>  9 iptools… HTML             2\.        0.0714    637\. 0.319           54\.        0.132              2\.         0.00154 
#> 10 iptools… R               19\.        0.679     431\. 0.216          125\.        0.306            625\.         0.482   
#> 11 iptools… Rmd              2\.        0.0714     48\. 0.0240          33\.        0.0807            72\.         0.0555  
#> 12 iptools… C/C++ H…         1\.        0.0357     37\. 0.0185          30\.        0.0733           223\.         0.172   
#> 13 dplyr_0… R              147\.        0.461   13231\. 0.465         2672\.        0.390           3879\.         0.673   
#> 14 dplyr_0… C/C++ H…       125\.        0.392    6689\. 0.235         1837\.        0.268            270\.         0.0469  
#> 15 dplyr_0… C++             33\.        0.103    4730\. 0.166          920\.        0.134            337\.         0.0585  
#> 16 dplyr_0… HTML             5\.        0.0157   2040\. 0.0718         174\.        0.0254             5\.         0.000868
#> 17 dplyr_0… Markdown         2\.        0.00627  1289\. 0.0453         624\.        0.0910             0\.         0\.      
#> 18 dplyr_0… Rmd              6\.        0.0188    421\. 0.0148         622\.        0.0907          1270\.         0.220   
#> 19 dplyr_0… C                1\.        0.00313    30\. 0.00106          7\.        0.00102            0\.         0\.      
#> # ... with 1 more variable: pkg <chr>
```

git tree

```source-r
cloc_git("~/packages/cloc")
#> # A tibble: 7 x 10
#>   source language file_count file_count_pct   loc  loc_pct blank_lines blank_line_pct comment_lines comment_line_pct
#>   <chr>  <chr>         <int>          <dbl> <int>    <dbl>       <int>          <dbl>         <int>            <dbl>
#> 1 cloc   Perl              1         0.0333 11153 0.912            835         0.705           1291          0.722  
#> 2 cloc   R                17         0.567    622 0.0509           207         0.175            360          0.201  
#> 3 cloc   Markdown          3         0.100    246 0.0201            49         0.0414             0          0\.     
#> 4 cloc   C++               1         0.0333   142 0.0116            41         0.0346            63          0.0352 
#> 5 cloc   YAML              3         0.100     35 0.00286           14         0.0118             3          0.00168
#> 6 cloc   Rmd               1         0.0333    24 0.00196           38         0.0321            71          0.0397 
#> 7 cloc   JSON              4         0.133      4 0.000327           0         0\.                 0          0.
```

git tree (with specific commit)

```source-r
cloc_git("~/packages/cloc", "3643cd09d4b951b1b35d32dffe35985dfe7756c4")
#> # A tibble: 5 x 10
#>   source language file_count file_count_pct   loc  loc_pct blank_lines blank_line_pct comment_lines comment_line_pct
#>   <chr>  <chr>         <int>          <dbl> <int>    <dbl>       <int>          <dbl>         <int>            <dbl>
#> 1 cloc   Perl              1          0.111 10059 0.987            787        0.911            1292         0.957   
#> 2 cloc   Markdown          2          0.222    60 0.00589           31        0.0359              0         0\.      
#> 3 cloc   R                 4          0.444    52 0.00510           22        0.0255             25         0.0185  
#> 4 cloc   Rmd               1          0.111    13 0.00128           21        0.0243             32         0.0237  
#> 5 cloc   YAML              1          0.111    10 0.000981           3        0.00347             1         0.000741
```

remote git tree

```source-r
cloc_git("git://github.com/maelle/convertagd.git")
#> # A tibble: 4 x 10
#>   source     language file_count file_count_pct   loc loc_pct blank_lines blank_line_pct comment_lines comment_line_pct
#>   <chr>      <chr>         <int>          <dbl> <int>   <dbl>       <int>          <dbl>         <int>            <dbl>
#> 1 convertag… R                 7         0.583    249  0.659           70          0.560            68           0.667 
#> 2 convertag… Markdown          2         0.167     77  0.204           23          0.184             0           0\.    
#> 3 convertag… YAML              2         0.167     42  0.111           16          0.128             4           0.0392
#> 4 convertag… Rmd               1         0.0833    10  0.0265          16          0.128            30           0.294
```

Detailed results by file

```source-r
# whole dir
str(cloc_by_file(system.file("extdata", package="cloc")))
#> Classes 'tbl_df', 'tbl' and 'data.frame':    3 obs. of  6 variables:
#>  $ source       : chr  "extdata" "extdata" "extdata"
#>  $ filename     : chr  "/Library/Frameworks/R.framework/Versions/3.5/Resources/library/cloc/extdata/qrencoder.cpp" "/Library/Frameworks/R.framework/Versions/3.5/Resources/library/cloc/extdata/dbi.r" "/Library/Frameworks/R.framework/Versions/3.5/Resources/library/cloc/extdata/App.java"
#>  $ language     : chr  "C++" "R" "Java"
#>  $ loc          : int  142 138 8
#>  $ blank_lines  : int  41 24 1
#>  $ comment_lines: int  63 71 4

# single file
str(cloc_by_file(system.file("extdata", "qrencoder.cpp", package="cloc")))
#> Classes 'tbl_df', 'tbl' and 'data.frame':    1 obs. of  6 variables:
#>  $ source       : chr "qrencoder.cpp"
#>  $ filename     : chr "/Library/Frameworks/R.framework/Versions/3.5/Resources/library/cloc/extdata/qrencoder.cpp"
#>  $ language     : chr "C++"
#>  $ loc          : int 142
#>  $ blank_lines  : int 41
#>  $ comment_lines: int 63
```

Recognized languages

```source-r
cloc_recognized_languages()
#> # A tibble: 242 x 2
#>    lang           extensions            
#>    <chr>          <chr>                 
#>  1 ABAP           abap                  
#>  2 ActionScript   as                    
#>  3 Ada            ada, adb, ads, pad    
#>  4 ADSO/IDSM      adso                  
#>  5 Agda           agda, lagda           
#>  6 AMPLE          ample, dofile, startup
#>  7 Ant            build.xml, build.xml  
#>  8 ANTLR Grammar  g, g4                 
#>  9 Apex Trigger   trigger               
#> 10 Arduino Sketch ino, pde              
#> # ... with 232 more rows
```

Strip comments and whitespace from individual source files

```source-r
cat(
  cloc_remove_comments("https://raw.githubusercontent.com/maelle/convertagd/master/README.Rmd")
)
#> library("knitr")
#> library("devtools")
#> install_github("masalmon/convertagd")
#> library("convertagd")
#> file <- system.file("extdata", "dummyCHAI.agd", package = "convertagd")
#> testRes <- read_agd(file, tz = "GMT")
#> kable(testRes[["settings"]])
#> kable(head(testRes[["raw.data"]]))
#> path_to_directory <- system.file("extdata", package = "convertagd")
#> batch_read_agd(path_to_directory, tz="GMT")
```

## [](https://github.com/hrbrmstr/cloc#cloc-metrics)


## 参考文章

* [AlDanial/cloc: cloc counts blank lines, comment lines, and physical lines of source code in many programming languages.](https://github.com/AlDanial/cloc)
* [hrbrmstr/cloc: 🔢 R package to the perl cloc script (which counts blank lines, comment lines, and physical lines of source code in source files/trees/archives)](https://github.com/hrbrmstr/cloc)
* [git代码行统计命令集](http://www.jianshu.com/p/8fd14064c201)
* [统计本地Git仓库中不同贡献者的代码行数的一些方法](http://www.94joy.com/archives/115#comment-319)
* [使用Git工具统计代码](http://blog.cyeam.com/kaleidoscope/2015/01/17/gitstats)