//
//  ErrorManager.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 22/12/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ErrorManager : NSObject

+ (void)showErrorAlertWithError:(NSError *)error;

@end
