//
//  HorizSlideView.m
//  MichaelMao
//
//  Created by kiefer on 15/7/30.
//  Copyright (c) 2015年 Neo Yang. All rights reserved.
//

#import "HorizSlideView.h"

@implementation HorizSlideView

- (void)dealloc {
    [_viewControllers removeAllObjects];
    [_scrollView setDelegate:nil];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsHorizontalScrollIndicator = false;
        _scrollView.showsVerticalScrollIndicator = false;
        _scrollView.scrollsToTop = false;
        _scrollView.pagingEnabled = true;
        _scrollView.bounces = false;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        
        [_scrollView setUserInteractionEnabled:true];
        [_scrollView.panGestureRecognizer addTarget:self action:@selector(actionPanGesture:)];

        _viewControllers = [[NSMutableArray alloc] init];
        _contentOffsetX = 0;
        _selectedIndex = 0;
    }
    return self;
}

- (void)addChildViewWithIndex:(NSUInteger)index {
    if (index < _viewControllers.count) {
        UIViewController *childViewController = _viewControllers[index];
        UIView *childView = childViewController.view;
        if (childView.superview) return;

        CGFloat viewWidth  = self.frame.size.width;
        CGFloat viewHeight = self.frame.size.height;
        childView.frame = CGRectMake(viewWidth * index, 0, viewWidth, viewHeight);
        [_scrollView addSubview:childView];
    }
}

// 重载数据
- (void)reloadData {
    [_viewControllers removeAllObjects];

    NSUInteger count = [self.delegate numberOfTabsInSlideView:self];
    for (int i = 0; i < count; i++) {
        UIViewController *viewController = [self.delegate slideView:self viewForTabIndex:i];
        [_viewControllers addObject:viewController];
    }
    _scrollView.contentSize = CGSizeMake(self.frame.size.width * _viewControllers.count, 0);
    [self addChildViewWithIndex:_selectedIndex];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _scrollView.frame = self.bounds;

    CGFloat viewWidth  = self.frame.size.width;
    CGFloat viewHeight = self.frame.size.height;
    _scrollView.frame = CGRectMake(0, 0, viewWidth, viewHeight);
    for (int i = 0; i < _viewControllers.count; i++) {
        UIViewController *viewController = _viewControllers[i];
        if (viewController.view.superview) {
            viewController.view.frame = CGRectMake(viewWidth * i, 0, viewWidth, viewHeight);
        }
    }
}

- (void)actionPanGesture:(UIPanGestureRecognizer *)panGesture {
    if (_scrollView.contentOffset.x <= 0) {
        if ([self.delegate respondsToSelector:@selector(slideView:panLeftEdge:)]) {
            [self.delegate slideView:self panLeftEdge:panGesture];
        }
    } else if (_scrollView.contentOffset.x >= (_scrollView.contentSize.width - _scrollView.bounds.size.width)) {
        if ([self.delegate respondsToSelector:@selector(slideView:panRightEdge:)]) {
            [self.delegate slideView:self panRightEdge:panGesture];
        }
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [self setSelectedIndex:selectedIndex animated:false];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated {
    if (_selectedIndex != selectedIndex) {
        _selectedIndex = selectedIndex;
        [_scrollView setContentOffset:CGPointMake(self.frame.size.width * selectedIndex, 0) animated:animated];

        if ([self.delegate respondsToSelector:@selector(slideView:didSelectTab:)]) {
            [self.delegate slideView:self didSelectTab:selectedIndex];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _contentOffsetX = scrollView.contentOffset.x;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 判断用户是否左滚动还是右滚动
    if (_contentOffsetX < scrollView.contentOffset.x) {
        _isLeftScroll = true;
    } else {
        _isLeftScroll = false;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int index = scrollView.contentOffset.x / scrollView.bounds.size.width;
    self.selectedIndex = index;
}

@end
