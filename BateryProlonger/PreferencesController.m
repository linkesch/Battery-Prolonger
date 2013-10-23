//
//  PreferencesController.m
//  BateryProlonger
//
//  Created by Pavel Linkesch on 10/20/13.
//  Copyright (c) 2013 Pavel Linkesch. All rights reserved.
//

#import "PreferencesController.h"

@interface PreferencesController ()
    
@end

@implementation PreferencesController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        
    }
    
    return self;
}

- (void)windowDidLoad
{
    NSString *default1;
    NSString *default2;
    NSInteger default3;
    NSInteger default4;
    NSInteger tempLimit;
    
    [super windowDidLoad];
    
    if ([self findAppInLoginItem])
    {
        [startAtLoginMenuItem setState: NSOnState];
    }
    
    if(NSClassFromString(@"NSUserNotificationCenter"))
    {
        [autoCloseItem setTransparent:YES];
    }
    
    default1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"playSound"];
    if ([default1 isEqual: @"true"]) {
        [playSoundItem setState: NSOnState];
    }
    default2 = [[NSUserDefaults standardUserDefaults] objectForKey:@"autoClose"];
    if ([default2 isEqual: @"true"]) {
        [autoCloseItem setState: NSOnState];
    }
    
    default3 = [[[NSUserDefaults standardUserDefaults] objectForKey:@"topLimit"] integerValue];
    default4 = [[[NSUserDefaults standardUserDefaults] objectForKey:@"bottomLimit"] integerValue];
    
    if (default3 < default4)
    {
        tempLimit = default3;
        default3 = default4;
        default4 = tempLimit;
    }
    
    [topLimitSlider setIntegerValue:default3];
    [topLimit setIntegerValue:default3];
    
    [bottomLimitSlider setIntegerValue:default4];
    [bottomLimit setIntegerValue:default4];
}

- (IBAction) toogleLoginItem:(id)sender
{
    if ([self findAppInLoginItem])
    {
        [startAtLoginMenuItem setState: NSOffState];
        [self deleteAppFromLoginItem];
    }
    else
    {
        [startAtLoginMenuItem setState: NSOnState];
        [self addAppAsLoginItem];
    }
}

- (bool) findAppInLoginItem
{
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:appPath]);
    
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
    
	if (loginItems) {
		UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray  *loginItemsArray = (NSArray *)CFBridgingRelease(LSSharedFileListCopySnapshot(loginItems, &seedValue));
		int i = 0;
		for(i = 0 ; i< [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)CFBridgingRetain([loginItemsArray
                                                                        objectAtIndex:i]);
			//Resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(NSURL*)CFBridgingRelease(url) path];
				if ([urlPath compare:appPath] == NSOrderedSame){
					return true;
				}
			}
		}
		//[loginItemsArray release];
	}
    
    return false;
}

- (void) addAppAsLoginItem
{
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:appPath]);
    
	// Create a reference to the shared file list.
    // We are adding it to the current user only.
    // If we want to add it all users, use
    // kLSSharedFileListGlobalLoginItems instead of
    //kLSSharedFileListSessionLoginItems
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		//Insert an item to the list.
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
                                                                     kLSSharedFileListItemLast, NULL, NULL,
                                                                     url, NULL, NULL);
		if (item){
			CFRelease(item);
        }
	}
    
	CFRelease(loginItems);
}

- (void) deleteAppFromLoginItem
{
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:appPath]);
    
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
    
	if (loginItems) {
		UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray  *loginItemsArray = (NSArray *)CFBridgingRelease(LSSharedFileListCopySnapshot(loginItems, &seedValue));
		int i = 0;
		for(i = 0 ; i< [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)CFBridgingRetain([loginItemsArray
                                                                        objectAtIndex:i]);
			//Resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(NSURL*)CFBridgingRelease(url) path];
				if ([urlPath compare:appPath] == NSOrderedSame){
					LSSharedFileListItemRemove(loginItems,itemRef);
				}
			}
		}
		//[loginItemsArray release];
	}
}

- (IBAction)togglePlaySoundItem:(id)sender{
    if ([sender state] == NSOnState) {
        [[NSUserDefaults standardUserDefaults] setObject:@"true" forKey:@"playSound"];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"false" forKey:@"playSound"];
    }
}

- (IBAction)toggleAutoCloseItem:(id)sender
{
    if ([sender state] == NSOnState) {
        [[NSUserDefaults standardUserDefaults] setObject:@"true" forKey:@"autoClose"];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"false" forKey:@"autoClose"];
    }
}

- (IBAction)changeTopLimit:(id)sender{
    [topLimit setIntegerValue:[sender integerValue]];
    [[NSUserDefaults standardUserDefaults] setObject:[sender stringValue] forKey:@"topLimit"];
}

- (IBAction)changeBottomLimit:(id)sender
{
    [bottomLimit setIntegerValue:[sender integerValue]];
    [[NSUserDefaults standardUserDefaults] setObject:[sender stringValue] forKey:@"bottomLimit"];
}


@end
