//
//  BateryProlongerTests.m
//  BateryProlongerTests
//
//  Created by Pavel Linkesch on 9/30/13.
//  Copyright (c) 2013 Pavel Linkesch. All rights reserved.
//

#import "BateryProlongerTests.h"

@implementation BateryProlongerTests

- (void)setUp
{
    [super setUp];
    
    appDelegate = [[AppDelegate alloc] init];
    viewController = [[[NSApplication sharedApplication] keyWindow] windowController];
    view = viewController.view;
}

- (void)tearDown
{
    
    [super tearDown];
}

- (void)testAppDelegate
{
    STAssertNotNil(appDelegate, @"appDelegate should not be nil");
}

- (void)testFindAppInLoginItem
{
    STAssertFalse([appDelegate findAppInLoginItem], @"findAppInLoginItem should be false");
}

- (void)testAddAppAsLoginItem
{
    [appDelegate addAppAsLoginItem];
    STAssertTrue([appDelegate findAppInLoginItem], @"findAppInLoginItem should be true if called after findAppInLoginItem");
}

- (void)testDeleteAppFromLoginItem
{
    [appDelegate deleteAppFromLoginItem];
    STAssertFalse([appDelegate findAppInLoginItem], @"findAppInLoginItem should be false if called after deleteAppFromLoginItem");
}

- (void)testToogleLoginItem
{
    id menuItem = [view viewWithTag:2];    
    [appDelegate toogleLoginItem:menuItem];
    STAssertTrue([appDelegate findAppInLoginItem], @"findAppInLoginItem should be true if called after toogleLoginItem");
}


@end
