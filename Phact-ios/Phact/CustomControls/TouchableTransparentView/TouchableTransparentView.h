//
//  TouchableTransparentView.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 11/26/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TouchProtocol <NSObject>

- (void)touchesBegan;

@end

@interface TouchableTransparentView : UIView

@property (nonatomic,strong)  id<TouchProtocol> delegate;

@end
