//
//  ViewController.m
//  MMPageViewController
//
//  Created by MichaelMao on 17/3/4.
//  Copyright © 2017年 MichaelMao. All rights reserved.
//

#import "HomeViewController.h"
#import "ChildViewController.h"
#import "HorizSlideView.h"

@interface HomeViewController ()<HorizSlideViewDelegate>

@property(nonatomic, copy) NSArray *pageNames;
@property(nonatomic, strong) UISegmentedControl *segmentedControl;
@property(nonatomic, strong) HorizSlideView *contentView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createDataSource];
    
    [self.view addSubview:self.segmentedControl];
    [self.view addSubview:self.contentView];
    [self.contentView reloadData];
}

#pragma mark - Data

- (NSArray *)pageNames{
    if (!_pageNames) {
        _pageNames = @[@"Tab 1", @"Tab 2", @"Tab 3", @"Tab 4"];
    }
    return _pageNames;
}

- (UISegmentedControl *)segmentedControl{
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:self.pageNames];
        _segmentedControl.frame = CGRectMake(0, 20, self.view.width, 44);
        _segmentedControl.selectedSegmentIndex = 0;
        [_segmentedControl addTarget:self
                              action:@selector(segmentControllerMode:)
                    forControlEvents:UIControlEventValueChanged];
    }
    return _segmentedControl;
}

- (HorizSlideView *)contentView{
    if (!_contentView) {
        _contentView = [[HorizSlideView alloc] initWithFrame:CGRectMake(0, self.segmentedControl.bottom, self.view.width, self.view.height - self.segmentedControl.bottom)];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.selectedIndex = 0;
        _contentView.delegate = self;
    }
    return _contentView;
}

- (void)createDataSource{
    [self removeViewControllers];
    
    for (NSString *title in self.pageNames) {
        ChildViewController *viewController = [[ChildViewController alloc] init];
        viewController.view.frame = self.contentView.bounds;
//        viewController.view.frame = CGRectInset(self.view.frame, 0, _segmentedControl.height);
        viewController.pageTitle = title;
        [self addChildViewController:viewController];
    }
}

#pragma mark - Function

- (void)segmentControllerMode:(UISegmentedControl *)segmentController{
    NSInteger destination = segmentController.selectedSegmentIndex;
    [self.contentView setSelectedIndex:destination];
}

- (void)removeViewControllers {
    if (!self.childViewControllers || self.childViewControllers.count == 0) return;
    
    for (UIViewController *viewController in self.childViewControllers) {
        [viewController.view removeFromSuperview];
        [viewController removeFromParentViewController];
    }
}

#pragma mark - HorizSlideViewDelegate
// number of tab
- (NSUInteger)numberOfTabsInSlideView:(HorizSlideView *)slideView {
    return [self.childViewControllers count];
}

// viewController belongs to the tab
- (UIViewController *)slideView:(HorizSlideView *)slideView viewForTabIndex:(NSUInteger)tabIndex {
    if (tabIndex < [self.childViewControllers count]) {
        return self.childViewControllers[tabIndex];
    }
    return nil;
}

//click tab
- (void)slideView:(HorizSlideView *)slideView didSelectTab:(NSUInteger)tabIndex {
    if (tabIndex < [self.childViewControllers count]) {
        [_segmentedControl setSelectedSegmentIndex:tabIndex];
        [self.contentView addChildViewWithIndex:tabIndex];
        [self setScrollsToTopWithIndex:tabIndex];
    }
}
//tableView scrolls to top
- (void)setScrollsToTopWithIndex:(NSUInteger)index {
    if (!self.childViewControllers || self.childViewControllers.count == 0) return;
    
    for (int i = 0; i < self.childViewControllers.count; i++) {
        UIViewController *viewController = self.childViewControllers[i];
        BOOL scrollsToTop = (i == index) ? true : false;
        if ([viewController isKindOfClass:[ChildViewController class]]) {
            [((ChildViewController*)viewController).tableView setScrollsToTop:scrollsToTop];
        }
    }
}

@end