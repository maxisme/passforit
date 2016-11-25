//
//  AppDelegate.h
//  Pass4 It
//
//  Created by Max Mitchell on 13/11/2015.
//  Copyright © 2015 Pass4 It. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (nonatomic) NSUserDefaults *storedStuff;

@property (nonatomic) NSStatusItem *statusItem;
@property (nonatomic) NSMenu *mainMenu;
@property (nonatomic) NSMenu *passLengthMenu;
@property (nonatomic) NSStatusBar *statusBar;
@property (nonatomic) NSMenuItem *password;
@property (nonatomic) int passwordLength;
@property (nonatomic) int passwordType;

//settings menu bar
@property (nonatomic) NSMenuItem* numbers;
@property (nonatomic) NSMenuItem* upperCase;
@property (nonatomic) NSMenuItem* lowCase;
@property (nonatomic) NSMenuItem* specialChars;
@property (nonatomic) NSMenuItem* showOnStartupItem;

//previous passLength item
@property (nonatomic) NSMenuItem *lastPassLengthItem;

@property (nonatomic) NSTextField *tf;
@end

