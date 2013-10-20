//
//  AppDelegate.m
//  BateryProlonger
//
//  Created by Pavel Linkesch on 9/30/13.
//  Copyright (c) 2013 Pavel Linkesch. All rights reserved.
//

#import "AppDelegate.h"
#import "aboutController.h"
#import "preferencesController.h"

@implementation AppDelegate

bool notified1 = false;
bool notified2 = false;
int lastPowerSource;

+ (void)initialize
{
    NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"true", @"autoClose", @"80", @"topLimit", @"40", @"bottomLimit", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (void)awakeFromNib
{
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSImage* icon = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon-small" ofType:@"png"]];
    [statusItem setImage:icon];
    [statusItem setMenu:statusMenu];
    [statusItem setHighlightMode:YES];
    
    
    [self refresh:NULL];
    
	[[NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(refresh:) userInfo:nil repeats:YES] retain];
}

- (void) refresh:(NSTimer *) theTimer
{
    CFTypeRef info;
	CFArrayRef list;
	CFDictionaryRef	battery;
    NSInteger topLimit;
    NSInteger bottomLimit;
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
    
    topLimit = [[[NSUserDefaults standardUserDefaults] objectForKey:@"topLimit"] integerValue];
    bottomLimit = [[[NSUserDefaults standardUserDefaults] objectForKey:@"bottomLimit"] integerValue];
    
    if(batteryCharging == 1 && batteryCurrent > topLimit && notified1 == false)
    {
        NSString *notification = @"Your battery is charged enough.\n\nYou can unplug your MacBook now.";
        [self showNotification:notification];
        notified1 = true;
        notified2 = false;
    }
    else if(batteryCharging == 0 && batteryCurrent < bottomLimit && notified2 == false)
    {
        
        NSString *notification =[NSString stringWithFormat:@"Your battery is charged to less than %li%%.\n\nPlease, plug in your MacBook to a power adapter.", bottomLimit];
        [self showNotification:notification];
        notified1 = false;
        notified2 = true;
    }
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
    Boolean isSticky = YES;
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"autoClose"] isEqual: @"true"])
    {
        isSticky = NO;
    }
    
    if (growlBundle && [growlBundle load])
    {
        [GrowlApplicationBridge setGrowlDelegate:self];
        
        [GrowlApplicationBridge notifyWithTitle:@"Battery Prolonger" description:notification notificationName:@"Notification" iconData:nil priority:2 isSticky:isSticky clickContext:[NSDate date]];
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"playSound"] isEqual: @"true"])
        {
            [[NSSound soundNamed:@"Purr"] play];
        }
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

- (IBAction)openPreferencesWindow:(id)sender
{
    if (!preferencesController)
    {
        preferencesController = [[PreferencesController alloc] initWithWindowNibName:@"Preferences"];
    }
    [preferencesController showWindow:self];
}

@end
