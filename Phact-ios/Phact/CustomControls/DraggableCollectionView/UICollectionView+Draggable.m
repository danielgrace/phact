//
//  UICollectionView+Draggable.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 12/9/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "UICollectionView+Draggable.h"
#import "CollectionViewHelper.h"
#import <objc/runtime.h>

@implementation UICollectionView (Draggable)

- (CollectionViewHelper *)getHelper
{
    CollectionViewHelper *helper = objc_getAssociatedObject(self, "CollectionViewHelper");
    if(helper == nil) {
        helper = [[CollectionViewHelper alloc] initWithCollectionView:self];
        objc_setAssociatedObject(self, "CollectionViewHelper", helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return helper;
}

- (BOOL)draggable
{
    return [self getHelper].enabled;
}

- (void)setDraggable:(BOOL)draggable
{
    [self getHelper].enabled = draggable;
}

- (UIEdgeInsets)scrollingEdgeInsets
{
    return [self getHelper].scrollingEdgeInsets;
}

- (void)setScrollingEdgeInsets:(UIEdgeInsets)scrollingEdgeInsets
{
    [self getHelper].scrollingEdgeInsets = scrollingEdgeInsets;
}

- (CGFloat)scrollingSpeed
{
    return [self getHelper].scrollingSpeed;
}

- (void)setScrollingSpeed:(CGFloat)scrollingSpeed
{
    [self getHelper].scrollingSpeed = scrollingSpeed;
}

@end
