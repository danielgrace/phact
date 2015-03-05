//
//  CollectionViewLayoutHelper.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 12/9/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UICollectionViewLayout_Warpable.h"

@interface CollectionViewLayoutHelper : NSObject

- (id)initWithCollectionViewLayout:(UICollectionViewLayout<UICollectionViewLayout_Warpable>*)collectionViewLayout;

- (NSArray *)modifiedLayoutAttributesForElements:(NSArray *)elements;

@property (nonatomic, weak, readonly) UICollectionViewLayout<UICollectionViewLayout_Warpable> *collectionViewLayout;
@property (strong, nonatomic) NSIndexPath *fromIndexPath;
@property (strong, nonatomic) NSIndexPath *toIndexPath;
@property (strong, nonatomic) NSIndexPath *hideIndexPath;
@end
