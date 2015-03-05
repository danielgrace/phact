//
//  UICollectionViewLayout+Warpable.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 12/9/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CollectionViewLayoutHelper;

@protocol UICollectionViewLayout_Warpable <NSObject>
@required

@property (readonly, nonatomic) CollectionViewLayoutHelper *layoutHelper;
@end