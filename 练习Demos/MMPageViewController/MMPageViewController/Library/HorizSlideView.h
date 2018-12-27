//
//  HorizSlideView.h
//  MichaelMao
//
//  Created by kiefer on 15/7/30.
//  Copyright (c) 2015年 Neo Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HorizSlideViewDelegate;
@interface HorizSlideView : UIView <UIScrollViewDelegate> {
    UIScrollView *_scrollView;
    NSMutableArray *_viewControllers;
    NSUInteger _selectedIndex;
    CGFloat _contentOffsetX;
    CGFloat _isLeftScroll;
}

@property(nonatomic, weak) id<HorizSlideViewDelegate> delegate;
@property(nonatomic) NSUInteger selectedIndex;

- (void)addChildViewWithIndex:(NSUInteger)index;
// 重载数据
- (void)reloadData;

@end

@protocol HorizSlideViewDelegate <NSObject>
@required
// 顶部tab个数
- (NSUInteger)numberOfTabsInSlideView:(HorizSlideView *)slideView;
// 每个tab所属的viewController
- (UIViewController *)slideView:(HorizSlideView *)slideView viewForTabIndex:(NSUInteger)tabIndex;

@optional
// 点击tab
- (void)slideView:(HorizSlideView *)slideView didSelectTab:(NSUInteger)tabIndex;
// 滑动左边界时传递手势
- (void)slideView:(HorizSlideView *)slideView panLeftEdge:(UIPanGestureRecognizer *)panGesture;
// 滑动右边界时传递手势
- (void)slideView:(HorizSlideView *)slideView panRightEdge:(UIPanGestureRecognizer *)panGesture;

@end
