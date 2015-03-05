//
//  PhactCell.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 2/10/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "PhactCell.h"

@interface PhactCell ()

@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRightGesture;

@end

@implementation PhactCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib{
    [self.deleteButton setHidden:YES];

/*    _swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
    self.swipeRightGesture.numberOfTouchesRequired = 1;
    [self.swipeRightGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self addGestureRecognizer:self.swipeRightGesture];
*/
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(activateDeletionMode:)];
    [self addGestureRecognizer:longPress];
}

-(void)handleSwipeRight:(UISwipeGestureRecognizer *)swipe {
    [self.deleteButton setHidden:NO];
}

- (void)activateDeletionMode:(UILongPressGestureRecognizer *)gr
{
    if (gr.state == UIGestureRecognizerStateBegan)
    {
        [self.delegate activateDeletionMode:self];
//        [self.deleteButton setHidden:NO];
    }
}

-(IBAction)clickDeleteButton{
    [self.delegate deleteButtonClick:self];
    [self.deleteButton setHidden:YES];
}

@end
