//
//  UIViewController+NavigationBar.m
//  navBarDemo
//
//  Created by MichaelMao on 2018/4/13.
//  Copyright © 2018年 czm. All rights reserved.
//

#import "UIViewController+NavigationBar.h"
#import <objc/runtime.h>

#define NavigationBarDefaultTitleColor  [UIColor blackColor]

@implementation UIViewController (NavigationBar)

static char navigationBarTitleColorKey;

// MARK:  Method swizzle

//静态就交换静态，实例方法就交换实例方法
void swizzleMethod(Class cls, SEL originalSelector, SEL swizzledSelector) {
  // the method might not exist in the class, but in its superclass
  Method originalMethod = class_getInstanceMethod(cls, originalSelector);
  Method swizzledMethod = nil;
  if (!originalMethod) {//处理为类的方法
    originalMethod = class_getClassMethod(cls, originalSelector);
    swizzledMethod = class_getClassMethod(cls, swizzledSelector);
    if (!originalMethod || !swizzledMethod) return;
  } else {//处理为事例的方法
    swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
    if (!swizzledMethod) return;
  }
  
  // class_addMethod will fail if original method already exists
  BOOL didAddMethod = class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
  
  // the method doesn’t exist and we just added one
  if (didAddMethod) {
    class_replaceMethod(cls, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
  } else {
    method_exchangeImplementations(originalMethod, swizzledMethod);
  }
}


+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    
    SEL originalSelector = @selector(viewWillAppear:);
    SEL swizzledSelector = @selector(sp_viewWillAppear:);
    swizzleMethod([self class], originalSelector, swizzledSelector);
    
    originalSelector = @selector(viewWillDisappear:);
    swizzledSelector = @selector(sp_viewWillDisappear:);
    swizzleMethod([self class], originalSelector, swizzledSelector);
  });
}


- (void)sp_viewWillAppear:(BOOL)animated {
  [self sp_viewWillAppear:animated];
  [self setNaviBarTitleColor:self.navigationBarTitleColor];
}

- (void)sp_viewWillDisappear:(BOOL)animated {
  [self sp_viewWillDisappear:animated];
}


// MARK: Associate object

- (UIColor *)navigationBarTitleColor{
  return objc_getAssociatedObject(self, &navigationBarTitleColorKey);
}

- (void)setNavigationBarTitleColor:(UIColor *)navigationBarTitleColor {
  objc_setAssociatedObject(self, &navigationBarTitleColorKey, navigationBarTitleColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


// MARK: set title color

- (void)setNaviBarTitleColor:(UIColor *)naviTitleColor{
  if (naviTitleColor == nil) naviTitleColor = NavigationBarDefaultTitleColor;
  
  UINavigationBar *navigationBar = self.navigationController.navigationBar;
  if (navigationBar.titleTextAttributes == nil) {
    
    [navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: naviTitleColor}];
   
  }else{
    NSMutableDictionary *textAttrs = [navigationBar.titleTextAttributes mutableCopy];
    textAttrs[NSForegroundColorAttributeName] = naviTitleColor;
    navigationBar.titleTextAttributes = textAttrs;
 }
}

@end
