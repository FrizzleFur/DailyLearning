## HexoBlog


### HexoBlog优化

- [x] Tag问题，博客`tag`现在不显示;(2017-04-26)
- [x] 添加点击星星;(2017-04-26)
- [x] 使用`MWeb`自动发布; (2017-04-26)
- [x] 添加评论（Hexo blog add comments （2017-05-02）
       - [hypercomments](http://admin.hypercomments.com/comments/approve/90397)) (2017-05-02)
       - [livere](https://livere.com/insight/managereply/period)(2017-05-02)

- [x] 添加网易云音乐 （2017-05-02）
- [x] 添加备份[Bitbucket备份](https://bitbucket.org/MichaelMaoMao/myblog)（2017-05-02）

- [x] 每篇文章添加查看次数和人数;（2017-05-02）

- [x] 添加网页缩略图`favicon`和描述还有头像`Avatar`;（2017-05-03）

- [x] 添加搜索
    - [algolia](https://www.algolia.com/apps/6V4V7RXQEC/dashboard)
    - [Local Search](http://theme-next.iissnan.com/third-party-services.html#local-search)（2017-05-02）
    - [x]解决输入未实时搜索的情况（2017-05-10）

- [x]添加字数统计 2,850 |  阅读时长 13[Hexo博客设置进阶](http://blog.junyu.io/posts/0010-hexo-learn-from-Never-yu.html#outline)(2017-05-15)参考[为Hexo NexT主题添加字数统计功能](https://eason-yang.com/2016/11/05/add-word-count-to-hexo-next/)

- [添加`分类于`标识](http://blog.junyu.io/posts/0010-hexo-learn-from-Never-yu.html#outline)
 ![](http://oc98nass3.bkt.clouddn.com/2017-05-15-14948216390897.jpg)


### HexoBlog美化 
- [ ] Hexo美化♣️[Hexo+nexT主题搭建个人博客
](http://www.wuxubj.cn/2016/08/Hexo-nexT-build-personal-blog/) 
    - [love](http://www.wuxubj.cn/mylove/)  
    - [Hackerzhou/Love](http://hackerzhou.me/ex_love/)  
    - [ ] [http://moxfive.xyz/2016/05/31/hexo-local-search/#搜索重置](http://moxfive.xyz/2016/05/31/hexo-local-search/#搜索重置)

- [ ] 去除底部多余样式
![](http://oc98nass3.bkt.clouddn.com/14938557402763.jpg)

- [ ] 参考[泊学网](https://boxueio.com/series/ios-101/ebook/110)优化背景色和代码高亮显示

- [ ] [添加版权申明](https://creativecommons.org/licenses/by-nc-sa/3.0/)(版权声明： 本博客所有文章除特别声明外，均采用 CC BY-NC-SA 3.0   许可协议。转载请注明出处！)
![](http://oc98nass3.bkt.clouddn.com/2017-05-15-14948183164436.jpg)
参考[为博客文章添加版权声明](http://qimingyu.com/2016/06/05/%E4%B8%BA%E5%8D%9A%E5%AE%A2%E6%96%87%E7%AB%A0%E6%B7%BB%E5%8A%A0%E7%89%88%E6%9D%83%E5%A3%B0%E6%98%8E/)
用记事本打开，把上面代码写进去，然后保存成copyright.js文件，注意编码格式为UTF-8，否则为乱码，放在文件hexo–>themes–>next–>scripts中。
然后用MarkDown语法写一段版权声明相关的文字，同样也为UTF-8编码格式，保存为tail.md,放在文件hexo的根目录中即可，注意如果是其他地方，上面的脚本可能会找不到该文件。
如果有的文章不需要加版权声明的话，在post文章中加如下代码即可：
`copyright: false`

```
// Add a tail to every post from tail.md
// Great for adding copyright info

var fs = require('fs');

hexo.extend.filter.register('before_post_render', function(data){
    if(data.copyright == false) 
		return data;
    var file_content = fs.readFileSync('tail.md');
    if(file_content && data.content.length > 50) 
    {
        data.content += file_content;
        var permalink = '\n本文永久链接：' + data.permalink;
        data.content += permalink;
    }
    return data;
});
```


### 参考文章

1. [Qiufengyu Hexo](https://qiufengyu.github.io/tags/hexo/)





