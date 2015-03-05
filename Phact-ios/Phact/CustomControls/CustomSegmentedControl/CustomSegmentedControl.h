//
//  CustomSegmentedControl.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 1/24/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SegmentedControlMode) {
    SegmentedControlModeSticky,
    SegmentedControlModeButton,
    SegmentedControlModeMultipleSelectionable,
};

@interface CustomSegmentedControl : UIControl

@property (nonatomic, strong, readwrite) NSArray *buttonsArray;
@property (nonatomic, strong, readwrite) UIImage *backgroundImage;
@property (nonatomic, strong, readwrite) UIImage *separatorImage;
@property (nonatomic, strong, readwrite) NSIndexSet *selectedIndexes;
@property (nonatomic, assign, readwrite) UIEdgeInsets contentEdgeInsets;
@property (nonatomic, assign, readwrite) SegmentedControlMode segmentedControlMode;

- (void)setSelectedIndex:(NSUInteger)index;
- (void)setSelectedIndexes:(NSIndexSet *)indexSet byExpandingSelection:(BOOL)expandSelection;

@end
