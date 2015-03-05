//
//  SwipeTableViewCell.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 1/29/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "SwipeCellScrollView.h"
#import "NSMutableArray+UtilityButtons.h"

@class SwipeTableViewCell;

typedef enum {
    kCellStateCenter,
    kCellStateLeft,
    kCellStateRight
} SWCellState;

@interface SwipeLongPressGestureRecognizer : UILongPressGestureRecognizer

@end

@protocol SwipeTableViewCellDelegate <NSObject>

@optional
- (void)swipeableTableViewCell:(SwipeTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index;
- (void)swipeableTableViewCell:(SwipeTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index;
- (void)swipeableTableViewCell:(SwipeTableViewCell *)cell scrollingToState:(SWCellState)state;
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SwipeTableViewCell *)cell;
- (BOOL)swipeableTableViewCell:(SwipeTableViewCell *)cell canSwipeToState:(SWCellState)state;

@end

@interface SwipeTableViewCell : UITableViewCell

@property (nonatomic, strong) NSArray *leftUtilityButtons;
@property (nonatomic, strong) NSArray *rightUtilityButtons;
@property (nonatomic, weak) id <SwipeTableViewCellDelegate> delegate;
@property (nonatomic, strong) SwipeCellScrollView *cellScrollView;
@property (nonatomic, weak) UITableView *containingTableView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier containingTableView:(UITableView *)containingTableView leftUtilityButtons:(NSArray *)leftUtilityButtons rightUtilityButtons:(NSArray *)rightUtilityButtons;

- (void)setCellHeight:(CGFloat)height;
- (void)setBackgroundColor:(UIColor *)backgroundColor;
- (void)hideUtilityButtonsAnimated:(BOOL)animated;
- (void)setAppearanceWithBlock:(void (^) ())appearanceBlock force:(BOOL)force;

@end
