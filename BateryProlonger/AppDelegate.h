//
//  AppDelegate.h
//  BateryProlonger
//
//  Created by Pavel Linkesch on 9/30/13.
//  Copyright (c) 2013 Pavel Linkesch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>
#import <IOKit/ps/IOPowerSources.h>
#import <IOKit/ps/IOPSKeys.h>
@class AboutController;
@class PreferencesController;

@interface AppDelegate : NSObject <GrowlApplicationBridgeDelegate>
{
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    AboutController *aboutController;
    PreferencesController *preferencesController;
}

- (void) refresh:(NSTimer *) theTimer;
- (void) showNotification:(NSString *)notification;
- (IBAction) openAboutWindow:(id)sender;
- (IBAction) openPreferencesWindow:(id)sender;

@end
