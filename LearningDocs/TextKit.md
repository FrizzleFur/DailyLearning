
# TextKit




```NSFontAttributeName // 设置字体属性，UIFont 对象，默认值：字体：Helvetica(Neue) 字号：12
NSParagraphStyleAttributeName // 设置文本段落排版格式，NSParagraphStyle 对象
NSForegroundColorAttributeName // 设置字体颜色，UIColor对象，默认值为黑色
NSBackgroundColorAttributeName // 设置字体所在区域背景颜色，UIColor对象，默认值为 nil, 透明
NSLigatureAttributeName // 设置连体属性，NSNumber 对象(整数)，0 表示没有连体字符，1 表示使用默认的连体字符
NSKernAttributeName // 设置字符间距，NSNumber 对象（整数），正值间距加宽，负值间距变窄
NSStrikethroughStyleAttributeName // 设置删除线，NSNumber 对象（整数）
NSStrikethroughColorAttributeName // 设置删除线颜色，UIColor 对象，默认值为黑色
NSUnderlineStyleAttributeName // 设置下划线，NSNumber 对象（整数），枚举常量 NSUnderlineStyle中的值，与删除线类似
NSUnderlineColorAttributeName // 设置下划线颜色，UIColor 对象，默认值为黑色
NSStrokeWidthAttributeName // 设置笔画宽度(粗细)，NSNumber 对象（整数），负值填充效果，正值中空效果
NSStrokeColorAttributeName // 填充部分颜色，不是字体颜色，UIColor 对象
NSShadowAttributeName // 设置阴影属性，NSShadow 对象
NSTextEffectAttributeName // 设置文本特殊效果，NSString 对象，目前只有图版印刷效果可用
NSBaselineOffsetAttributeName // 设置基线偏移值，NSNumber （float）,正值上偏，负值下偏
NSObliquenessAttributeName // 设置字形倾斜度，NSNumber （float）,正值右倾，负值左倾
NSExpansionAttributeName // 设置文本横向拉伸属性，NSNumber （float）,正值横向拉伸文本，负值横向压缩文本
NSWritingDirectionAttributeName // 设置文字书写方向，从左向右书写或者从右向左书写
NSVerticalGlyphFormAttributeName // 设置文字排版方向，NSNumber 对象(整数)，0 表示横排文本，1 表示竖排文本
NSLinkAttributeName // 设置链接属性，点击后调用浏览器打开指定 URL 地址(注意只有 UITextView 可以通过其代理方法实现操作，其它口渴男关键只能显示样式而无法点击)
NSAttachmentAttributeName // 设置文本附件,NSTextAttachment 对象,常用于文字图片混排
```
需要注意的是文本显示控件中的 attributedText 属性并不会继承 text 属性中的文本设置，初学者往往会遗漏掉经常在普通文本中设置的诸如字体大小和颜色等基本属性，造成显示效果失常。


如果用 NSAttachmentAttributeName 类型对象的方式以属性插入附件，会有一个问题是不好确认 range。所幸 NSTextAttachment 类中提供了一个 NSAttributedString 的分类初始化方法：


```
+ (NSAttributedString *)attributedStringWithAttachment:(NSTextAttachment *)attachment;

```




```// 利用 block 对匹配字段进行设置(NSTextCheckingResult 类中有 range 属性，即匹配字段的范围)
- (void)enumerateMatchesInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range usingBlock:(void (^)(NSTextCheckingResult * __nullable result, NSMatchingFlags flags, BOOL *stop))block;
// 返回匹配字段的 NSTextCheckingResult 对象数组
- (NSArray<NSTextCheckingResult *> *)matchesInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range;
// 匹配字段个数
- (NSUInteger)numberOfMatchesInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range;
// 返回第一个匹配字段的 NSTextCheckingResult 对象
- (nullable NSTextCheckingResult *)firstMatchInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range;
// 返回第一个匹配字段的 range
- (NSRange)rangeOfFirstMatchInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range;
```
### Helpful Links

1. [[iOS] 利用 NSAttributedString 进行富文本处理 – 技术学习小组](http://blog.qiji.tech/archives/8335)


