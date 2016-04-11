//
//  JSONWindowController.h
//  JSONCreatorPlus
//
//  Created by andylee1988 on 13-4-10.
//  Copyright (c) 2013年 andylee1988. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "JSONKit.h"
#import "Utils.h"



@interface JSONWindowController : NSWindowController {
    NSArrayController *myArrayController;
    NSString *strPath;
}
@property (nonatomic,strong) IBOutlet NSTextView *jsonContentTextView;
@property (nonatomic,strong) IBOutlet NSTextField *classNameTextField;
@property (nonatomic,strong) IBOutlet NSTextField *jsonURLTextField;


- (IBAction)useTestURLAction:(id)sender;
- (IBAction)getJSONWithURLAction:(id)sender;
- (IBAction)generateClassAction:(id)sender;

@end
