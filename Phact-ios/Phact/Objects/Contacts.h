//
//  Contacts.h
//  Phact
//
//  Created by Tigran Kirakosyan on 2/25/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface Contacts : NSObject
{
    ABAddressBookRef addressBook;
    NSMutableArray *contacts;
}
@property (assign, nonatomic) BOOL bSendContacts;

typedef void (^CompletionHandler)(id result, NSError *error);

+ (Contacts*)sharedInstance;
- (NSMutableArray *)contacts;

- (void)registerAddressBookChange;
- (void)unRegisterAddressBookChange;
- (void)sendAddressBook:(CompletionHandler)completionHandler;

void MyAddressBookExternalChangeCallback (
                                          ABAddressBookRef addressBook,
                                          CFDictionaryRef info,
                                          void *context
                                          );

@end