//
//  DraggableCollectionViewFlowLayout.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 12/9/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "DraggableCollectionViewFlowLayout.h"
#import "CollectionViewLayoutHelper.h"

@interface DraggableCollectionViewFlowLayout ()
{
    CollectionViewLayoutHelper *_layoutHelper;
}
@end

@implementation DraggableCollectionViewFlowLayout

- (CollectionViewLayoutHelper *)layoutHelper
{
    if(_layoutHelper == nil) {
        _layoutHelper = [[CollectionViewLayoutHelper alloc] initWithCollectionViewLayout:self];
    }
    return _layoutHelper;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [self.layoutHelper modifiedLayoutAttributesForElements:[super layoutAttributesForElementsInRect:rect]];
}

@end
