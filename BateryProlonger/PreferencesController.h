//
//  PreferencesController.h
//  BateryProlonger
//
//  Created by Pavel Linkesch on 10/20/13.
//  Copyright (c) 2013 Pavel Linkesch. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesController : NSWindowController
{
    IBOutlet NSButton *startAtLoginMenuItem;
    IBOutlet NSButton *playSoundItem;
    IBOutlet NSButton *autoCloseItem;
    IBOutlet NSSlider *topLimitSlider;
    IBOutlet NSSlider *bottomLimitSlider;
    IBOutlet NSTextField *topLimit;
    IBOutlet NSTextField *bottomLimit;
}

- (IBAction) toogleLoginItem:(id)sender;
- (bool) findAppInLoginItem;
- (void) addAppAsLoginItem;
- (void) deleteAppFromLoginItem;
- (IBAction)togglePlaySoundItem:(id)sender;
- (IBAction)toggleAutoCloseItem:(id)sender;
- (IBAction)changeTopLimit:(id)sender;
- (IBAction)changeBottomLimit:(id)sender;

@end
