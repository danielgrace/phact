//
//  DraggableCollectionViewFlowLayout.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 12/9/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICollectionViewLayout_Warpable.h"
#import "CollectionViewLayoutHelper.h"

@interface DraggableCollectionViewFlowLayout : UICollectionViewFlowLayout <UICollectionViewLayout_Warpable>

@property (readonly, nonatomic) CollectionViewLayoutHelper *layoutHelper;
@end
