//
//  PopListView.m
//  Phact
//
//  Created by Tigran Kirakosyan on 2/6/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "PopListView.h"
#import "PopListViewCell.h"
#import "PhactCategory.h"
#import "UIColor-Expanded.h"
#import "PhactAppDelegate.h"
#import "Customer.h"
#import "PhactCategories.h"

#define POPLISTVIEW_SCREENINSET 40.

@interface PopListView ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSMutableArray *options;
@property (nonatomic, strong) NSMutableArray *selectedIndexes;

- (void)fadeIn;
- (void)fadeOut;
@end

@implementation PopListView

#pragma mark - initialization & cleaning up
- (id)initWithTitle:(NSString *)aTitle options:(NSMutableArray *)aOptions selectedOptions:(NSMutableArray *)sOptions {
    CGRect rect = [[UIScreen mainScreen] applicationFrame];
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        rect.size = CGSizeMake(rect.size.height, rect.size.width);
    }
    if (self = [super initWithFrame:rect]) {
        self.backgroundColor = [UIColor clearColor];
        _title = aTitle;
        _options = aOptions;
        _selectedIndexes = [[NSMutableArray alloc] initWithArray:sOptions];

		CGRect frame = CGRectMake(POPLISTVIEW_SCREENINSET, POPLISTVIEW_SCREENINSET + 20.0, rect.size.width - 2 * POPLISTVIEW_SCREENINSET, rect.size.height - 2 * POPLISTVIEW_SCREENINSET);
		if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7) {
			frame = CGRectMake(POPLISTVIEW_SCREENINSET, POPLISTVIEW_SCREENINSET, rect.size.width - 2 * POPLISTVIEW_SCREENINSET, rect.size.height - 2 * POPLISTVIEW_SCREENINSET);
		}
		
		UIView *contentView = [[UIView alloc] initWithFrame:frame];
		contentView.backgroundColor = [UIColor clearColor];

        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0,
                                                                   0.0,
                                                                   frame.size.width,
                                                                   frame.size.height - 2 * POPLISTVIEW_SCREENINSET)];
        _tableView.separatorColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1.0];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
		_tableView.showsVerticalScrollIndicator = NO;
		_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

		CGRect frame1 = CGRectMake(0.0, frame.size.height - 2 * POPLISTVIEW_SCREENINSET, frame.size.width, POPLISTVIEW_SCREENINSET);
		UIView *view1 = [[UIView alloc] initWithFrame:frame1];
		view1.backgroundColor = [UIColor whiteColor];
		
		UIButton *createButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[createButton addTarget:self action:@selector(createButtonPressed:) forControlEvents:UIControlEventTouchDown];
		[createButton setTitle:@"Create new tag" forState:UIControlStateNormal];
		[createButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
		[createButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
		[createButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
		createButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
		createButton.titleLabel.textAlignment = NSTextAlignmentLeft;
		[createButton setBackgroundColor:[UIColor clearColor]];
//		[createButton setShowsTouchWhenHighlighted:YES];
		createButton.frame = CGRectMake(130.0, 10.0, 120.0, 20.0);

		[view1 addSubview:createButton];
				
		CGRect frame2 = CGRectMake(0.0, frame.size.height - POPLISTVIEW_SCREENINSET, frame.size.width, 14.0);
		UIView *view2 = [[UIView alloc] initWithFrame:frame2];
		view2.backgroundColor = [UIColor clearColor];

		UIImageView *popupIcon = [[UIImageView alloc] initWithFrame:CGRectMake(23.0, 0.0, 25.0, 14.0)];
		popupIcon.image = [UIImage imageNamed:@"popup_part.png"];
		[view2 addSubview:popupIcon];
		
		[contentView addSubview:_tableView];
		[contentView addSubview:view1];
		[contentView addSubview:view2];
		
		[self addSubview:contentView];
    }
    return self;
}

- (id)initWithTitle:(NSString *)aTitle
            options:(NSMutableArray *)aOptions
			selectedOptions:(NSMutableArray *)sOptions
            handler:(void (^)(NSArray *indexes))aHandlerBlock {
    
    if(self = [self initWithTitle:aTitle options:aOptions selectedOptions:sOptions])
        self.handlerBlock = aHandlerBlock;
    
    return self;
}


#pragma mark - Private Methods
- (void)fadeIn {
//    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
//        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
	
}

- (void) orientationDidChange: (NSNotification *) not {
    CGRect rect = [[UIScreen mainScreen] applicationFrame]; // portrait bounds
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        rect.size = CGSizeMake(rect.size.height, rect.size.width);
    }
    [self setFrame:rect];
    [self setNeedsDisplay];
}

- (void)fadeOut {
    [UIView animateWithDuration:.35 animations:^{
//        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self removeFromSuperview];
        }
    }];
}

- (void)createButtonPressed:(id)sender {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Create New Label" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	alert.tag = 100;
	UITextField *textField = [alert textFieldAtIndex:0];
	textField.font = [UIFont systemFontOfSize:16.0];
	textField.placeholder = @"Label Name";
	textField.keyboardType = UIKeyboardTypeDefault;
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 100) {
		if (buttonIndex == 1) {
            NSString *name = [alertView textFieldAtIndex:0].text;
			
            [PhactCategory createCategory:name onCompletion:^(id methodResults, NSError *error){
                if(!error)
                {
                    PhactCategory *category = methodResults;
                    [self.options addObject:category];
                    [self.tableView reloadData];
					[self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height) animated:YES];                    

					[self updateCustomerProfile];
				}
                else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: nil
                                                                    message: [error localizedDescription]
                                                                   delegate: self
                                                          cancelButtonTitle: @"OK"
                                                          otherButtonTitles: nil, nil];
                    [alert show];
                }
            }];
		}
	}
}

-(void) updateCustomerProfile {
	PhactAppDelegate *app = (PhactAppDelegate *)[UIApplication sharedApplication].delegate;
	Customer *customer = [app getCustomerProfile];
	
	[customer.categories.categoriesArray setArray:self.options];
	
	NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:customer.categories];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:encodedObject forKey:@"Categories"];
    [defaults synchronize];
}

#pragma mark - Instance Methods
- (void)showInView:(UIView *)aView animated:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(orientationDidChange:)
												 name: UIApplicationDidChangeStatusBarOrientationNotification
											   object: nil];
    [aView addSubview:self];
    if (animated) {
        [self fadeIn];
    }
}

#pragma mark - Tableview datasource & delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _options.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 8.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *headerView = [[UIView alloc] init];
	headerView.backgroundColor = [UIColor clearColor];
	
	return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentity = @"PopListViewCell";
    
	UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_grey.png"]];

    PopListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if (!cell)
        cell = [[PopListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
    
	if ([_selectedIndexes indexOfObject:[NSNumber numberWithInteger:indexPath.row]] != NSNotFound) {
		cell.accessoryView = accessoryView;
    } else {
		cell.accessoryView = nil;
    }
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
    if ([_options[indexPath.row] isKindOfClass:[PhactCategory class]]) {
		PhactCategory *phactCategory = _options[indexPath.row];
		cell.icon.backgroundColor = [UIColor colorWithHexString:phactCategory.color];
        cell.label.text = phactCategory.name;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

	UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_grey.png"]];
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    NSNumber *row = [NSNumber numberWithInteger:indexPath.row];
    NSUInteger index = [_selectedIndexes indexOfObject:row];
    if (index != NSNotFound) {
        [_selectedIndexes removeObjectAtIndex:index];
		cell.accessoryView = nil;
    } else {
		if(_selectedIndexes.count > 0) {
			UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[[_selectedIndexes objectAtIndex:0] integerValue] inSection:0]];
			[_selectedIndexes removeObjectAtIndex:0];
			selectedCell.accessoryView = nil;
		}
        [_selectedIndexes addObject:row];
		cell.accessoryView = accessoryView;
    }
	
	if ([_delegate respondsToSelector:@selector(popListView:didSelectIndexes:)])
        [_delegate popListView:self didSelectIndexes:_selectedIndexes];
    
    if (_handlerBlock)
        _handlerBlock(_selectedIndexes);
	
    [self fadeOut];
}

#pragma mark - Touch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if ([_delegate respondsToSelector:@selector(popListView:didSelectIndexes:)])
        [_delegate popListView:self didSelectIndexes:_selectedIndexes];
    
    if (_handlerBlock)
        _handlerBlock(_selectedIndexes);

    [self fadeOut];
}

@end
