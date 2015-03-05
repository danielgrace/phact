//
//  PhactsArchiveViewController.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 2/7/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhactCell.h"

@interface PhactsArchiveViewController : UIViewController<UICollectionViewDelegate, CellDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (assign, nonatomic) NSInteger mode;

- (void)loadPhactsByCategory:(NSInteger)categoryId categoryName:(NSString *)categoryName;
- (void)loadOwnPhacts;

@end
