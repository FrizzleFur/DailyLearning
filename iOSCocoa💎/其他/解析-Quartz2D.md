# 解析-Quartz2D

## Quartz2D在iOS开发中的价值
 
01-带有边框的图片裁剪
 
具体实现思路:
1.假设边框宽度为BorderW
2.开启的图片上下文的尺寸就应该是原始图片的宽高分别加上两倍的BorderW,这样开启的目的是为了不让原始图片变形.
3.在上下文上面添加一个圆形填充路径.位置从0,0点开始,宽高和上下文尺寸一样大.设置颜色为要设置的边框颜色.
4.继续在上下文上面添加一个圆形路径,这个路径为裁剪路径.
它的x,y分别从BorderW这个点开始.宽度和高度分别和原始图片的宽高一样大.
将绘制的这个路径设为裁剪区域.
5.把原始路径绘制到上下文当中.绘制的位置和是裁剪区域的位置相同,x,y分别从border开始绘制.
6.从上下文状态当中取出图片.
7.关闭上下文状态.
 
 
02-截屏
 
截屏效果实现具体思路为:把UIView的东西绘制图片上下文当中,生成一张新的图片.
注意:UIView上的东西是不能直接画到上下文当中的.
UIView之所以能够显示是因为内部的一个层(layer),所以我要把层上的东西渲染到UIView上面的.
怎样把图层当中的内容渲染到上下文当中?
 
直接调用layer的renderInContext:方法
renderInContext:带有一个参数, 就是要把图层上的内容渲染到哪个上下文.
 
截屏具体实现代码为:
1.开启一个图片上下文
UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0);
获取当前的上下文.
CGContextRef ctx = UIGraphicsGetCurrentContext();
2.把控制器View的内容绘制上下文当中.
[self.view.layer renderInContext:ctx];
3.从上下文当中取出图片
UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
4.关闭上下文.
UIGraphicsEndImageContext();
 
 
 
 
03-图片擦除
 
图片擦除思路.
弄两个不同的图片.上面一张, 下面一张.
添加手势,手指在上面移动,擦除图片.
擦除前要先确定好擦除区域.
假设擦除区域的宽高分别为30.
那点当前的擦除范围应该是通过当前的手指所在的点来确定擦除的范围,位置.
那么当前擦除区域的x应该是等于当前手指的x减去擦除范围的一半,同样,y也是当前手指的y减去高度的一半.
 
有了擦除区域,要让图片办到擦除的效果,首先要把图片绘制到图片上下文当中, 在图片上下文当中进行擦除.
之后再生成一张新的图片,把新生成的这一张图片设置为上部的图片.那么就可以通过透明的效果,看到下部的图片了.
 
第一个参数, 要擦除哪一个上下文
第二人参数,要擦除的区域.
CGContextClearRect(ctx, rect);
 
具体实现代码为:
 
确定擦除的范围
CGFloat rectWH = 30;
获取手指的当前点.curP
CGPoint curP = [pan locationInView:pan.view];
CGFloat x = curP.x - rectWH * 0.5;
CGFloat y = curP.y - rectWH * 0.5;
CGRect rect = CGRectMake(x, y,rectWH, rectWH);
 
先把图片绘制到上下文.
UIGraphicsBeginImageContextWithOptions(self.imageView.bounds.size, NO, 0);
获取当前的上下文
CGContextRef ctx = UIGraphicsGetCurrentContext();
把上面一张图片绘制到上下文.
[self.imageView.layer renderInContext:ctx];
再绘上下文当中图片进行擦除.
CGContextClearRect(ctx, rect);
生成一张新图片
UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
再把新的图片给重新负值
self.imageView.image = newImage;
关闭上下文.
UIGraphicsEndImageContext();
 
 
04-图片截屏
 
图片截屏实现思路.
手指在屏幕上移动的时
添加一个半透明的UIView,
然后开启一个上下文把UIView的frame设置成裁剪区域.把图片显示的图片绘制到上下文当中,生成一张新的图片
再把生成的图片再赋值给原来的UImageView.
 
具体实现步骤:
1.给图片添加一个手势,监听手指在图片上的拖动,添加手势时要注意,UIImageView默认是不接事件的.
要把它设置成能够接收事件
2.监听手指的移动.手指移动的时候添加一个UIView，
x,y就是起始点,也就是当前手指开始的点.
width即是x轴的偏移量,
高度即是Y轴的偏移量.
UIView的尺寸位置为CGrect(x,y,witdth,height);
 
计算代码为:
CGFloat offSetX = curP.x - self.beginP.x;
CGFloat offsetY = curP.y - self.beginP.y;
CGRect rect = CGRectMake(self.beginP.x, self.beginP.y, offSetX, offsetY);
 
UIView之需要添加一次,所以给UIView设置成懒加载的形式,
保证之有一个.每次移动的时候,只是修改UIView的frame.
 
3.开启一个图片上下文,图片上下文的大小为原始图片的尺寸大小.使得整个屏幕都能够截屏.
利用UIBezierPath设置一个矩形的裁剪区域.
然后把这个路径设置为裁剪区域.
把路径设为裁剪区域的方法为:
[path addClip];
 
4.把图片绘制到图片上下文当中
由于是一个UIImageView上面的图片,所以也得需要渲染到上下文当中.
要先获取当前的上下文,
把UIImageView的layer渲染到当前的上下文当中.
CGContextRef ctx = UIGraphicsGetCurrentContext();
[self.imageV.layer renderInContext:ctx];
 
5.取出新的图片,重新赋值图片.
UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
self.imageV.image = newImage;
 
6.关闭上下文,移除上面半透明的UIView
UIGraphicsEndImageContext();
[self.coverView removeFromSuperview];
 