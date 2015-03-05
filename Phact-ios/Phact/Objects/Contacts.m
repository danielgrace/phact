//
//  Contacts.m
//  Phact
//
//  Created by Tigran Kirakosyan on 2/25/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "Contacts.h"
#import "PhactPrivateService.h"

void MyAddressBookExternalChangeCallback (
                                          ABAddressBookRef addressBook,
                                          CFDictionaryRef info,
                                          void *context
                                          )
{
    NSLog(@"AddressBookExternalChangeCallback called ");
    [[Contacts sharedInstance] sendAddressBook:^(id result, NSError *error) {
		if (!error) {
			[[PhactPrivateService sharedInstance] findFriends:^(id methodResults, NSError *error) {
				if(!error){
				}
				else {
				}
			}];
		}
	}];
}

@implementation Contacts

+ (Contacts*)sharedInstance
{
    static Contacts *sharedInstance = nil;
	
    @synchronized(self)
    {
        if (sharedInstance == nil)
        {
            sharedInstance = [[Contacts alloc] init];
        }
    }
    return sharedInstance;
}

- (void)sendAddressBook:(CompletionHandler)completionHandler {
	if(self.bSendContacts) {
		[contacts removeAllObjects];
		//	if(ABAddressBookGetAuthorizationStatus) {
		ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (error || !granted)
				{
					// handle error
					NSLog(@"ERROR: %@",error);
					
					if(!granted) { //(ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized)
						// show alert (get access to contact list)
						UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Phact does not have access to your contacts"
																		message: @"To enable access go to: Settings > Privacy > Contacts > Phact set to 'On'"
																	   delegate: self
															  cancelButtonTitle: @"OK"
															  otherButtonTitles: nil, nil];
						[alert show];
					}
					completionHandler([NSNumber numberWithBool:NO], nil);
				}
				else
				{
					ABAddressBookRevert(addressBook);
					NSArray *allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
					
					NSUInteger i = 0; for (i = 0; i < [allContacts count]; i++)
					{
						ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
						
						CFStringRef firstNameRef = ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
						NSString *firstName = (__bridge NSString *)firstNameRef;
						CFStringRef lastNameRef = ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
						NSString *lastName = (__bridge NSString *)lastNameRef;
//						NSData *imageData = (__bridge NSData*)ABPersonCopyImageDataWithFormat(contactPerson, kABPersonImageFormatThumbnail);
						
						ABMultiValueRef emails = ABRecordCopyValue(contactPerson, kABPersonEmailProperty);
						
						if(ABMultiValueGetCount(emails) > 0) {
							NSMutableArray *emailList = [[NSMutableArray alloc] init];
							
//							NSLog(@"firstName = %@ lastName = %@", firstName, lastName);
							for (NSInteger j = 0; j < ABMultiValueGetCount(emails); j++) {
								NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, j);
//								NSLog(@"person.email = %@ ", email);
								
								[emailList addObject:email];
							}
							[contacts addObject:[NSDictionary dictionaryWithObjectsAndKeys:emailList,@"email",firstName,@"firstname",lastName,@"lastname", nil]];
						}
						if(emails)
							CFRelease(emails);
						if(firstNameRef)
							CFRelease(firstNameRef);
						if(lastNameRef)
							CFRelease(lastNameRef);
					}
//					NSLog(@"Contacts count = %d",contacts.count);
					if(contacts.count > 0) {
						// send contact list to server
						[[PhactPrivateService sharedInstance] sendAddressBook:contacts onCompletion:^(id result, NSError *error) {
							if(error) {
								completionHandler(nil, error);
							} else {
								if(result)
								{
									completionHandler(result, error);
								}
								else
								{
									completionHandler([NSNumber numberWithBool:NO], nil);
								}
							}
						}];
					}
					else {
						completionHandler([NSNumber numberWithBool:YES], nil);
					}
				}
			});
		});
		//	}
	}
	else
		completionHandler([NSNumber numberWithBool:YES], nil);
}

- (void)registerAddressBookChange {
	ABAddressBookRegisterExternalChangeCallback (addressBook,
												 MyAddressBookExternalChangeCallback,
												 (__bridge void *)self
												 );
}

- (void)unRegisterAddressBookChange {
	ABAddressBookUnregisterExternalChangeCallback (addressBook,
												 MyAddressBookExternalChangeCallback,
												 (__bridge void *)self
												 );
}

- (NSMutableArray *)contacts {
	return contacts;
}

- (id)init
{
    if ((self = [super init]))
    {
		CFErrorRef error = NULL;
		addressBook = ABAddressBookCreateWithOptions(NULL, &error);
		contacts = [[NSMutableArray alloc] init];
    }
    return self;
}

@end