//
//  AppDelegate.m
//  BateryProlonger
//
//  Created by Pavel Linkesch on 9/30/13.
//  Copyright (c) 2013 Pavel Linkesch. All rights reserved.
//

#import "AppDelegate.h"
#import "aboutController.h"

@implementation AppDelegate

bool notified1 = false;
bool notified2 = false;
int lastPowerSource;

- (void)awakeFromNib
{
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSImage* icon = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon-small" ofType:@"png"]];
    [statusItem setImage:icon];
    
    //[statusItem setTitle:@"Battery Prolonger"];
    [statusItem setMenu:statusMenu];
    [statusItem setHighlightMode:YES];
    
    
    
    if ([self findAppInLoginItem])
    {
        [startAtLoginMenuItem setState: NSOnState];
    }
    
    
    [self refresh:NULL];
    
	[[NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(refresh:) userInfo:nil repeats:YES] retain];
}

- (void) refresh:(NSTimer *) theTimer
{
    CFTypeRef info;
	CFArrayRef list;
	CFDictionaryRef	battery;
    bool batteryCharging;
    int batteryCurrent;
	
	info = IOPSCopyPowerSourcesInfo();
	if(info == NULL)
    {
        return;
    }
	list = IOPSCopyPowerSourcesList(info);
	if(list == NULL)
    {
		CFRelease(info);
		return;
	}
    
    
	if(CFArrayGetCount(list) && (battery = IOPSGetPowerSourceDescription(info, CFArrayGetValueAtIndex(list, 0))))
    {
        batteryCharging = [[(NSDictionary*)battery objectForKey:@kIOPSIsChargingKey] boolValue];
        batteryCurrent = [[(NSDictionary*)battery objectForKey:@kIOPSCurrentCapacityKey] intValue];
    }
    else
    {
        return;
    }
    
    if(lastPowerSource != batteryCharging)
    {
        lastPowerSource = batteryCharging;
        notified1 = notified2 = false;
    }
    
    if(batteryCharging == 1 && batteryCurrent > 80 && notified1 == false)
    {
        NSString *notification = @"Your battery is charged enough.\n\nYou can unplug your MacBook now.";
        [self showNotification:notification];
        notified1 = true;
        notified2 = false;
    }
    else if(batteryCharging == 0 && batteryCurrent < 40 && notified2 == false)
    {
        
        NSString *notification = @"Your battery is charged on less than 40%.\n\nPlease, plug in your MacBook to power adapter.";
        [self showNotification:notification];
        notified1 = false;
        notified2 = true;
    }
    else
    {
        //NSLog(@"Do nothing");
    }

	//[theTimer release];
}


- (NSDictionary *) registrationDictionaryForGrowl
{
    NSArray *array = [NSArray arrayWithObjects:@"Notification", @"error", nil];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:1], @"TicketVersion", array, @"AllNotifications", array, @"DefaultNotifications", nil];
    
    return dict;
}

- (void)showNotification:(NSString *)notification
{
    NSBundle *myBundle = [NSBundle bundleForClass:[AppDelegate class]];
    NSString *growlPath = [[myBundle privateFrameworksPath] stringByAppendingPathComponent:@"Growl.framework"];
    NSBundle *growlBundle = [NSBundle bundleWithPath:growlPath];
    
    if (growlBundle && [growlBundle load])
    {
        [GrowlApplicationBridge setGrowlDelegate:self];
        
        [GrowlApplicationBridge notifyWithTitle:@"Alert" description:notification notificationName:@"Notification" iconData:nil priority:2 isSticky:NO clickContext:[NSDate date]];
    }
}

- (IBAction)openAboutWindow:(id)sender
{
    if (!aboutController)
    {
        aboutController = [[AboutController alloc] initWithWindowNibName:@"About"];
    }
    [aboutController showWindow:self];
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
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath];
    
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
    
	if (loginItems) {
		UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray  *loginItemsArray = (NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
		int i = 0;
		for(i = 0 ; i< [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)[loginItemsArray
                                                                        objectAtIndex:i];
			//Resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(NSURL*)url path];
				if ([urlPath compare:appPath] == NSOrderedSame){
					return true;
				}
			}
		}
		[loginItemsArray release];
	}
    
    return false;
}

- (void) addAppAsLoginItem
{
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath];
    
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
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath];
    
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
    
	if (loginItems) {
		UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray  *loginItemsArray = (NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
		int i = 0;
		for(i = 0 ; i< [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)[loginItemsArray
                                                                        objectAtIndex:i];
			//Resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(NSURL*)url path];
				if ([urlPath compare:appPath] == NSOrderedSame){
					LSSharedFileListItemRemove(loginItems,itemRef);
				}
			}
		}
		[loginItemsArray release];
	}
}

@end
