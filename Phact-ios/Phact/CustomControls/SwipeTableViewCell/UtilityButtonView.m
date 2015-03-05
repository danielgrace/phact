//
//  UtilityButtonView.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 1/29/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//


#import "UtilityButtonView.h"

#define kUtilityButtonsWidthMax 260
#define kUtilityButtonWidthDefault 90

@implementation UtilityButtonTapGestureRecognizer

@end


@implementation UtilityButtonView

#pragma mark - SWUtilityButonView initializers

- (id)initWithUtilityButtons:(NSArray *)utilityButtons parentCell:(SwipeTableViewCell *)parentCell utilityButtonSelector:(SEL)utilityButtonSelector
{
    self = [super init];
    
    if (self) {
        self.utilityButtons = utilityButtons;
        self.utilityButtonWidth = [self calculateUtilityButtonWidth];
        self.parentCell = parentCell;
        self.utilityButtonSelector = utilityButtonSelector;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame utilityButtons:(NSArray *)utilityButtons parentCell:(SwipeTableViewCell *)parentCell utilityButtonSelector:(SEL)utilityButtonSelector
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.utilityButtons = utilityButtons;
        self.utilityButtonWidth = [self calculateUtilityButtonWidth];
        self.parentCell = parentCell;
        self.utilityButtonSelector = utilityButtonSelector;
    }
    
    return self;
}

#pragma mark Populating utility buttons

- (CGFloat)calculateUtilityButtonWidth
{
    CGFloat buttonWidth = kUtilityButtonWidthDefault;
    if (buttonWidth * _utilityButtons.count > kUtilityButtonsWidthMax)
    {
        CGFloat buffer = (buttonWidth * _utilityButtons.count) - kUtilityButtonsWidthMax;
        buttonWidth -= (buffer / _utilityButtons.count);
    }
    return buttonWidth;
}

- (CGFloat)utilityButtonsWidth
{
    return (_utilityButtons.count * _utilityButtonWidth);
}

- (void)populateUtilityButtons
{
    NSUInteger utilityButtonsCounter = 0;
    for (UIButton *utilityButton in _utilityButtons)
    {
        CGFloat utilityButtonXCord = 0;
        if (utilityButtonsCounter >= 1) utilityButtonXCord = _utilityButtonWidth * utilityButtonsCounter;
        [utilityButton setFrame:CGRectMake(utilityButtonXCord, 0, _utilityButtonWidth, CGRectGetHeight(self.bounds))];
        [utilityButton setTag:utilityButtonsCounter];
        UtilityButtonTapGestureRecognizer *utilityButtonTapGestureRecognizer = [[UtilityButtonTapGestureRecognizer alloc] initWithTarget:_parentCell
                                                                                                                                      action:_utilityButtonSelector];
        utilityButtonTapGestureRecognizer.buttonIndex = utilityButtonsCounter;
        [utilityButton addGestureRecognizer:utilityButtonTapGestureRecognizer];
        [self addSubview: utilityButton];
        utilityButtonsCounter++;
    }
}

- (void)setHeight:(CGFloat)height
{
    for (NSUInteger utilityButtonsCounter = 0; utilityButtonsCounter < _utilityButtons.count; utilityButtonsCounter++)
    {
        UIButton *utilityButton = (UIButton *)_utilityButtons[utilityButtonsCounter];
        CGFloat utilityButtonXCord = 0;
        if (utilityButtonsCounter >= 1) utilityButtonXCord = _utilityButtonWidth * utilityButtonsCounter;
        [utilityButton setFrame:CGRectMake(utilityButtonXCord, 0, _utilityButtonWidth, height)];
    }
}

@end

