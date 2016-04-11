//
//  AppDelegate.h
//  JSONCreatorPlus
//
//  Created by andylee1988 on 13-4-10.
//  Copyright (c) 2013年 andylee1988. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JSONWindowController.h"
@interface AppDelegate : NSObject <NSApplicationDelegate> {
    JSONWindowController *jsonWindowController;
}

@property (assign) IBOutlet NSWindow *window;

@end
