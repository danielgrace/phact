//
//  PopListView.h
//  Phact
//
//  Created by Tigran Kirakosyan on 2/6/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopListViewDelegate;
@interface PopListView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<PopListViewDelegate> delegate;
@property (copy, nonatomic) void(^handlerBlock)(NSArray *indexes);

- (id)initWithTitle:(NSString *)aTitle options:(NSMutableArray *)aOptions selectedOptions:(NSMutableArray *)sOptions;
- (id)initWithTitle:(NSString *)aTitle
            options:(NSMutableArray *)aOptions
            selectedOptions:(NSMutableArray *)sOptions
            handler:(void (^)(NSArray *))aHandlerBlock;

// If animated is YES, PopListView will be appeared with FadeIn effect.
- (void)showInView:(UIView *)aView animated:(BOOL)animated;
@end

@protocol PopListViewDelegate <NSObject>
- (void)popListView:(PopListView *)popListView didSelectIndexes:(NSArray *)indexes;
@end