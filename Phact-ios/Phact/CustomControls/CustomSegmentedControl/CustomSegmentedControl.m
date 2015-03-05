//
//  CustomSegmentedControl.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 1/24/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "CustomSegmentedControl.h"

// Default separator width.
static CGFloat const kAKButtonSeparatorWidth = 0.0;

@interface CustomSegmentedControl ()

@property (nonatomic, strong) NSMutableArray *separatorsArray;
@property (nonatomic, strong) UIImageView *backgroundImageView;

// Init
- (void)commonInitializer;

@end

@implementation CustomSegmentedControl

#pragma mark - Init and Dealloc

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    [self commonInitializer];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) return nil;
    
    [self commonInitializer];
    
    return self;
}

- (void)commonInitializer {
    _separatorsArray = [NSMutableArray array];
    self.selectedIndexes = [NSIndexSet indexSet];
    self.contentEdgeInsets = UIEdgeInsetsZero;
    self.segmentedControlMode = SegmentedControlModeSticky;
    self.buttonsArray = [[NSArray alloc] init];
    
    [self addSubview:self.backgroundImageView];
}

#pragma mark - Layout

- (void)layoutSubviews {
    CGRect contentRect = UIEdgeInsetsInsetRect(self.bounds, _contentEdgeInsets);
    
    NSUInteger buttonsCount    = _buttonsArray.count;
    NSUInteger separtorsNumber = buttonsCount - 1;
    CGFloat separatorWidth     = (_separatorImage != nil) ? _separatorImage.size.width : kAKButtonSeparatorWidth;
    CGFloat buttonWidth        = floorf((CGRectGetWidth(contentRect) - (separtorsNumber * separatorWidth)) / buttonsCount);
    CGFloat buttonHeight       = CGRectGetHeight(contentRect);
    CGSize buttonSize          = CGSizeMake(buttonWidth, buttonHeight);
    
    __block CGFloat offsetX      = CGRectGetMinX(contentRect);
    __block CGFloat offsetY      = CGRectGetMinY(contentRect);
    __block CGFloat spaceLeft    = CGRectGetWidth(contentRect) - (buttonsCount * buttonSize.width) - (separtorsNumber * separatorWidth);
    __block CGFloat dButtonWidth = 0;
    __block NSUInteger increment = 0;
    
    [_buttonsArray enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        if (![button isKindOfClass:UIButton.class]) {
            return;
        }
        
        dButtonWidth = buttonSize.width;
        
        if (spaceLeft != 0) {
            dButtonWidth++;
            spaceLeft--;
        }
        
        if (increment != 0) {
            offsetX += separatorWidth;
        }
        
        button.frame = CGRectMake(offsetX, offsetY, dButtonWidth, buttonSize.height);
        
        if (increment < separtorsNumber) {
            UIImageView *separatorImageView = _separatorsArray[increment];
            [separatorImageView setFrame:CGRectMake(CGRectGetMaxX(button.frame),
                                                    offsetY,
                                                    separatorWidth,
                                                    CGRectGetHeight(self.bounds) - _contentEdgeInsets.top - _contentEdgeInsets.bottom)];
        }
        
        increment++;
        offsetX = CGRectGetMaxX(button.frame);
    }];
    
    [_backgroundImageView setFrame:self.bounds];
}

#pragma mark - Button Actions

- (void)segmentButtonPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    if (![button isKindOfClass:UIButton.class]) {
        return;
    }
    
    NSUInteger selectedIndex = button.tag;
    NSIndexSet *set = _selectedIndexes;
    
    if (_segmentedControlMode == SegmentedControlModeMultipleSelectionable) {

        NSMutableIndexSet *mutableSet = [set mutableCopy];
        if ([_selectedIndexes containsIndex:selectedIndex]) {
            [mutableSet removeIndex:selectedIndex];
        }
        
        else {
            [mutableSet addIndex:selectedIndex];
        }
        
        [self setSelectedIndexes:[mutableSet copy]];
    }
    
    else {
        [self setSelectedIndex:selectedIndex];
    }
    
    BOOL willSendAction = (![_selectedIndexes isEqualToIndexSet:set] || _segmentedControlMode == SegmentedControlModeButton);
    
    if (willSendAction) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
}

#pragma mark - Setters

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    [_backgroundImageView setImage:_backgroundImage];
}

- (void)setButtonsArray:(NSArray *)buttonsArray {
    [_buttonsArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_separatorsArray removeAllObjects];
    
    _buttonsArray = buttonsArray;
    
    [_buttonsArray enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        [self addSubview:button];
        [button addTarget:self action:@selector(segmentButtonPressed:) forControlEvents:UIControlEventTouchDown];
        [button setTag:idx];
    }];
    
    [self rebuildSeparators];
    [self updateButtons];
}

- (void)setSeparatorImage:(UIImage *)separatorImage {
    _separatorImage = separatorImage;
    [self rebuildSeparators];
}

- (void)setSegmentedControlMode:(SegmentedControlMode)segmentedControlMode {
    _segmentedControlMode = segmentedControlMode;
    [self updateButtons];
}

- (void)setSelectedIndex:(NSUInteger)index {
    _selectedIndexes = [NSIndexSet indexSetWithIndex:index];
    [self updateButtons];
}

- (void)setSelectedIndexes:(NSIndexSet *)indexSet byExpandingSelection:(BOOL)expandSelection {
    
    if (_segmentedControlMode != SegmentedControlModeMultipleSelectionable) {
        return;
    }
    
    if (!expandSelection) {
        _selectedIndexes = [NSIndexSet indexSet];
    }
    
    NSMutableIndexSet *mutableIndexSet = [_selectedIndexes mutableCopy];
    [mutableIndexSet addIndexes:indexSet];
    [self setSelectedIndexes:mutableIndexSet];
}

- (void)setSelectedIndexes:(NSIndexSet *)selectedIndexes {
    _selectedIndexes = [selectedIndexes copy];
    [self updateButtons];
}

#pragma mark - Rearranging

- (void)rebuildSeparators {
    [_separatorsArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSUInteger separatorsNumber = [_buttonsArray count] - 1;
    
    [_separatorsArray removeAllObjects];
    [_buttonsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx < separatorsNumber) {
            UIImageView *separatorImageView = [[UIImageView alloc] initWithImage:_separatorImage];
            [self addSubview:separatorImageView];
            [_separatorsArray addObject:separatorImageView];
        }
    }];
}

- (UIImageView *)backgroundImageView {
    if (_backgroundImageView == nil) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [_backgroundImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    }
    
    return _backgroundImageView;
}

- (void)updateButtons {
    
    if ([_buttonsArray count] == 0) {
        return;
    }
    
    [_buttonsArray makeObjectsPerformSelector:@selector(setSelected:) withObject:nil];
    
    [_selectedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        
        if (_segmentedControlMode != SegmentedControlModeButton) {
            if (idx >= [_buttonsArray count]) return;
            
            UIButton *button = _buttonsArray[idx];
            button.selected = YES;
        }
    }];
}

@end
