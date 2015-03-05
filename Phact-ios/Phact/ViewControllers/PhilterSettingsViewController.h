//
//  PhilterSettingsViewController.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 12/9/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICollectionView+Draggable.h"

@class Customer;

@interface PhilterSettingsViewController : UIViewController<UICollectionViewDataSource_Draggable, UICollectionViewDelegate>

@property (strong, nonatomic) Customer *customer;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
