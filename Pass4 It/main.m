//
//  main.m
//  Pass4 It
//
//  Created by Max Mitchell on 13/11/2015.
//  Copyright © 2015 Pass4 It. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, const char * argv[]) {
    NSArray *tl;
    NSApplication *application = [NSApplication sharedApplication];
    [[NSBundle mainBundle] loadNibNamed:@"mainWindow" owner:application topLevelObjects:&tl];
    
    AppDelegate *applicationDelegate = [[AppDelegate alloc] init];      // Instantiate App  delegate
    [application setDelegate:applicationDelegate];                      // Assign delegate to the NSApplication
    [application run];                                                  // Call the Apps Run method
    
    return 0;       // App Never gets here.
}