//
//  AppDelegate.m
//  JSONCreatorPlus
//
//  Created by andylee1988 on 13-4-10.
//  Copyright (c) 2013年 andylee1988. All rights reserved.
//

#import "AppDelegate.h"
#import "JSONWindowController.h"
@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    jsonWindowController = [[JSONWindowController alloc] initWithWindowNibName:@"JSONWindowController"];
    [[jsonWindowController window] makeKeyAndOrderFront:nil];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    [[jsonWindowController window] orderFront:nil];
    return YES;
}

- (void)orderFrontStandardAboutPanel:(id)sender {
    NSLog(@"xxxx");
}


@end
