//
//  AppDelegate.m
//  Pass4 It
//
//  Created by Max Mitchell on 13/11/2015.
//  Copyright © 2015 Pass4 It. All rights reserved.
//

#import "AppDelegate.h"
#import <Carbon/Carbon.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self onlyOneInstanceOfApp];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTextDidChange:)  name:NSControlTextDidEndEditingNotification object:nil];
    
    //initialise variables
    _storedStuff = [NSUserDefaults standardUserDefaults];
    
    [self createStatusBarItem];
    if ([_storedStuff objectForKey:@"number"] == nil && [_storedStuff objectForKey:@"upperCase"] == nil && [_storedStuff objectForKey:@"lowerCase"] == nil) {
        [_numbers setState:NSOnState];
        [_upperCase setState:NSOnState];
        [_lowCase setState:NSOnState];
        [_specialChars setState:NSOnState];
    }else{
        if([[_storedStuff objectForKey:@"number"]  isEqual: @"1"]){
            [_numbers setState:NSOnState];
        }else{
            [_numbers setState:NSOffState];
        }
        
        if([[_storedStuff objectForKey:@"upperCase"]  isEqual: @"1"]){
            [_upperCase setState:NSOnState];
        }else{
            [_upperCase setState:NSOffState];
        }
        
        if([[_storedStuff objectForKey:@"specialChars"]  isEqual: @"1"]){
            [_specialChars setState:NSOnState];
        }else{
            [_specialChars setState:NSOffState];
        }
        
        if([[_storedStuff objectForKey:@"lowerCase"]  isEqual: @"1"] || ![self checkAllStatesOn]){
            [_lowCase setState:NSOnState];
        }else{
            [_lowCase setState:NSOffState];
        }
    }
    
    if (![_storedStuff integerForKey:@"passwordLength"]){
        _passwordLength = 9;
    }else{
        _passwordLength = (int)[_storedStuff integerForKey:@"passwordLength"];
    }
    
    //tick nsmenuitem
    NSMenuItem* item= [_passLengthMenu itemWithTag:_passwordLength];
    [item setState:NSOnState];
    _lastPassLengthItem = item;
    
    [self generatePassword];
    
    int shouldShowOnStartup = (int)[_storedStuff integerForKey:@"openOnStartup"];
    //2 on | 1 off | 0 not set
    if (shouldShowOnStartup == 0) {
        [self openOnStartup];
    }else if(shouldShowOnStartup == 2){
        [_showOnStartupItem setState:NSOnState];
    }
}

#pragma mark - menu bar
- (void)createStatusBarItem {
    _statusBar = [NSStatusBar systemStatusBar];
    _statusItem = [_statusBar statusItemWithLength:NSSquareStatusItemLength];
    _statusItem.image = [NSImage imageNamed:@"key.png" ];
    _statusItem.highlightMode = YES;
    _statusItem.menu = [self defaultStatusBarMenu];
    [_statusItem setTarget:self];
}

- (NSMenu *)defaultStatusBarMenu {
    _mainMenu = [[NSMenu alloc] init];
    
    NSMenuItem* passwordTitle = [[NSMenuItem alloc] initWithTitle:@"Password:" action:nil keyEquivalent:@""];
    [passwordTitle setTarget:self];
    [passwordTitle setEnabled:false];
    [_mainMenu addItem:passwordTitle];
    
    _password = [[NSMenuItem alloc] initWithTitle:@"" action:@selector(clickedPass) keyEquivalent:@""];
    [_password setTarget:self];
    [_mainMenu addItem:_password];
    
    [_mainMenu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem* options = [[NSMenuItem alloc] initWithTitle:@"Settings" action:nil keyEquivalent:@""];
    [options setSubmenu: [self settingsMenu]];
    [_mainMenu addItem:options];
    
    [_mainMenu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem* quit = [[NSMenuItem alloc] initWithTitle:@"Quit Pass For It" action:@selector(quit) keyEquivalent:@""];
    [quit setTarget:self];
    [_mainMenu addItem:quit];
    
    // Disable auto enable
    [_mainMenu setAutoenablesItems:NO];
    [_mainMenu setDelegate:(id)self];
    return _mainMenu;
}

-(NSMenu *)settingsMenu {
    NSMenu *menu = [[NSMenu alloc] init];
    
    NSMenuItem* options = [[NSMenuItem alloc] initWithTitle:@"Password Options" action:nil keyEquivalent:@""];
    [options setSubmenu: [self passTypeMenu]];
    [menu addItem:options];
    
    NSMenuItem* length = [[NSMenuItem alloc] initWithTitle:@"Password Length" action:nil keyEquivalent:@""];
    [length setSubmenu: [self passLengthMenu]];
    [menu addItem:length];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    _showOnStartupItem = [[NSMenuItem alloc] initWithTitle:@"Open Pass For It at login" action:@selector(openOnStartup) keyEquivalent:@""];
    [_showOnStartupItem setTarget:self];
    [menu addItem:_showOnStartupItem];
    
    // Disable auto enable
    [menu setAutoenablesItems:NO];
    [menu setDelegate:(id)self];
    return menu;
}

-(NSMenu *)passTypeMenu {
    NSMenu *menu = [[NSMenu alloc] init];
    
    _numbers = [[NSMenuItem alloc] initWithTitle:@"Numbers" action:@selector(clickedNumbers) keyEquivalent:@""];
    [_numbers setTarget:self];
    [menu addItem:_numbers];
    
    _upperCase = [[NSMenuItem alloc] initWithTitle:@"Upper Case Letters" action:@selector(clickedUpperCase) keyEquivalent:@""];
    [_upperCase setTarget:self];
    [menu addItem:_upperCase];
    
    _lowCase = [[NSMenuItem alloc] initWithTitle:@"Lower Case Letters" action:@selector(clickedLowCase) keyEquivalent:@""];
    [_lowCase setTarget:self];
    [menu addItem:_lowCase];
    
    _specialChars = [[NSMenuItem alloc] initWithTitle:@"Special Characters & Symbols" action:@selector(clickedSpecialChars) keyEquivalent:@""];
    [_specialChars setTarget:self];
    [menu addItem:_specialChars];
    
    // Disable auto enable
    [menu setAutoenablesItems:NO];
    [menu setDelegate:(id)self];
    return menu;
}

-(NSMenu *)passLengthMenu {
    _passLengthMenu = [[NSMenu alloc] init];
    
    for (int x = 6; x < 129; x++){
        NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%d",x] action:@selector(setPassLength:) keyEquivalent:@""];
        [item setTarget:self];
        [item setTag:x];
        [_passLengthMenu addItem:item];
    }
    
    [_passLengthMenu addItem:[NSMenuItem separatorItem]];
    
    //MASSIVE
    NSMenuItem* item256 = [[NSMenuItem alloc] initWithTitle:@"256" action:@selector(setPassLength:) keyEquivalent:@""];
    [item256 setTarget:self];
    [item256 setTag:256];
    [_passLengthMenu addItem:item256];
    
    NSMenuItem* item512 = [[NSMenuItem alloc] initWithTitle:@"512" action:@selector(setPassLength:) keyEquivalent:@""];
    [item512 setTarget:self];
    [item512 setTag:512];
    [_passLengthMenu addItem:item512];
    
    NSMenuItem* item1024 = [[NSMenuItem alloc] initWithTitle:@"1024" action:@selector(setPassLength:) keyEquivalent:@""];
    [item1024 setTarget:self];
    [item1024 setTag:1024];
    [_passLengthMenu addItem:item1024];
    
    NSMenuItem* item2048 = [[NSMenuItem alloc] initWithTitle:@"2048" action:@selector(setPassLength:) keyEquivalent:@""];
    [item2048 setTarget:self];
    [item2048 setTag:2048];
    [_passLengthMenu addItem:item2048];
    
    // Disable auto enable
    [_passLengthMenu setAutoenablesItems:NO];
    [_passLengthMenu setDelegate:(id)self];
    return _passLengthMenu;
}

- (NSMenu *)coppiedStatusBarMenu {
    _mainMenu = [[NSMenu alloc] init];
    
    NSMenuItem* passwordTitle = [[NSMenuItem alloc] initWithTitle:@"Copied To Clipboard!" action:nil keyEquivalent:@""];
    [passwordTitle setTarget:self];
    [passwordTitle setEnabled:false];
    [_mainMenu addItem:passwordTitle];
    
    // Disable auto enable
    [_mainMenu setAutoenablesItems:NO];
    [_mainMenu setDelegate:(id)self];
    return _mainMenu;
}

-(IBAction)setPassLength:(id) sender
{
    NSMenuItem *item = (NSMenuItem*)sender;
    int cmdVal = (int)[item tag];
    _passwordLength = cmdVal;
    
    [_lastPassLengthItem setState:NSOffState];
    _lastPassLengthItem = item;
    [item setState:NSOnState];
    
    [_storedStuff setInteger:_passwordLength forKey:@"passwordLength"];
    [_storedStuff synchronize];
    
    [self generatePassword];
}


#pragma mark - clicked options

-(void)clickedPass{
    //copy code and paste to mac
    [self copyCode:_password.title];
    [self paste];
    
    [self generatePassword];
}

-(void)clickedNumbers{
    if(_numbers.state != NSOnState){
        [_numbers setState:NSOnState];
        [_storedStuff setObject:@"1" forKey:@"number"];
    }else{
        [_numbers setState:NSOffState];
        [_storedStuff setObject:@"0" forKey:@"number"];
    }
    
    if(![self checkAllStatesOn]){
        [_numbers setState:NSOnState];
        [_storedStuff setObject:@"1" forKey:@"number"];
    }
    
    [_storedStuff synchronize];
    [self generatePassword];
}

-(void)clickedUpperCase{
    if(_upperCase.state != NSOnState){
        [_upperCase setState:NSOnState];
        [_storedStuff setObject:@"1" forKey:@"upperCase"];
    }else{
        [_upperCase setState:NSOffState];
        [_storedStuff setObject:@"0" forKey:@"upperCase"];
    }
    
    if(![self checkAllStatesOn]){
        [_upperCase setState:NSOnState];
        [_storedStuff setObject:@"1" forKey:@"upperCase"];
    }
    
    [_storedStuff synchronize];
    [self generatePassword];
}

-(void)clickedLowCase{
    if(_lowCase.state != NSOnState){
        [_lowCase setState:NSOnState];
        [_storedStuff setObject:@"1" forKey:@"lowerCase"];
    }else{
        [_lowCase setState:NSOffState];
        [_storedStuff setObject:@"0" forKey:@"lowerCase"];
    }
    
    if(![self checkAllStatesOn]){
        [_lowCase setState:NSOnState];
        [_storedStuff setObject:@"1" forKey:@"lowerCase"];
    }
    
    [_storedStuff synchronize];
    [self generatePassword];
}

-(void)clickedSpecialChars{
    if(_specialChars.state != NSOnState){
        [_specialChars setState:NSOnState];
        [_storedStuff setObject:@"1" forKey:@"specialChars"];
    }else{
        [_specialChars setState:NSOffState];
        [_storedStuff setObject:@"0" forKey:@"specialChars"];
    }
    
    if(![self checkAllStatesOn]){
        [_specialChars setState:NSOnState];
        [_storedStuff setObject:@"1" forKey:@"specialChars"];
    }
    
    [_storedStuff synchronize];
    [self generatePassword];
}

-(BOOL)checkAllStatesOn{
    if(!(_lowCase.state != NSOnState && _upperCase.state != NSOnState && _numbers.state != NSOnState && _specialChars.state != NSOnState)){
        return true;
    }else{
        return false;
    }
}

#pragma mark - actions

-(void)generatePassword{
    //generating password
    NSString* numbers = @"0123456789";
    NSString* upperCase= @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSString* lowCase = @"abcdefghijklmnopqrstuvwxyz";
    NSString* specialChars = @"@%+\\/'!#$^?:.(){}[]~-_";
    NSString* charachters = @"";
    
    if(_numbers.state == NSOnState){
        charachters = [NSString stringWithFormat:@"%@%@",charachters,numbers];
    }
    if(_upperCase.state == NSOnState){
        charachters = [NSString stringWithFormat:@"%@%@",charachters,upperCase];
    }
    if(_lowCase.state == NSOnState){
        charachters = [NSString stringWithFormat:@"%@%@",charachters,lowCase];
    }
    if(_specialChars.state == NSOnState){
        charachters = [NSString stringWithFormat:@"%@%@",charachters,specialChars];
    }
    
    int charachterLength = (int)[charachters length];
    NSString* randomString = @"";
    
    for (int x = 0; x < _passwordLength; x++) {
        randomString = [NSString stringWithFormat:@"%@%@",randomString,[charachters substringWithRange:NSMakeRange(arc4random_uniform(charachterLength), 1)]];
    }
    
    _password.title = randomString;
}

-(int)passwordQuality:(NSString*)pass{
    //using http://www.passwordmeter.com/ algo
    int score = 0; //out of 100
    
    //string info
    int strlen = (int)[pass length];
    int upperCount=0;
    int lowerCount=0;
    int numberCount=0;
    int symbolCount=0;
    
    int reqCounter=0;
    int repeatCharCounter = 0;
    int posSeq = 0;
    for (int i = 0; i < strlen; i++) {
        char charachter = [pass characterAtIndex:i];
        if([[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:charachter]){
            upperCount++;
        }else if([[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:charachter]){
            lowerCount++;
        }else if([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:charachter]){
            numberCount++;
        }else{
            symbolCount++;
        }
        
        if([pass characterAtIndex:i - 1] == charachter){
            repeatCharCounter++;
        }else{
            repeatCharCounter = 0;
        }
        
        //sequintial number
        int nextChar = (int)[pass characterAtIndex:i - 1];
        if((int)charachter - 1 == nextChar){
            posSeq++;
        }else{
            posSeq = 0;
        }
    }
    
    int negSeq = 0;
    for (int i = strlen; i > -1; i--) {
        char charachter = [pass characterAtIndex:i];
        int nextChar = (int)[pass characterAtIndex:i - 1];
        if((int)charachter + 1 == nextChar){
            negSeq++;
        }else{
            negSeq = 0;
        }
    }
    
    //check requirements
    if (upperCount > 0) {
        reqCounter++;
    }else if (lowerCount > 0) {
        reqCounter++;
    }else if(numberCount > 0){
        reqCounter++;
    }else if(symbolCount > 0){
        reqCounter++;
    }
    
    //--- calculate score ---
    //+
    score += strlen * 4;
    score += ((strlen-upperCount) * 2);
    score += ((strlen-lowerCount) * 2);
    score += numberCount * 4;
    score += symbolCount * 6;
    
    //-
    if(numberCount == 0 && symbolCount == 0){ //only letters
        score -= upperCount + lowerCount;
    }
    
    if(upperCount == 0 && lowerCount == 0 && symbolCount == 0){ //numbers only
        score -= numberCount;
    }
    
    //requirements
    if (reqCounter >= 3 && strlen >= 8){
        score += (reqCounter + 1) * 2; // +1 for 8 char requirement
    }
    
    
    return score;
}

#pragma mark - copy and paste
-(void)paste{
    NSLog(@"paste");
    CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateCombinedSessionState);
    CGEventRef pasteCommandDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_V, YES);
    CGEventSetFlags(pasteCommandDown, kCGEventFlagMaskCommand);
    
    CGEventRef pasteCommandUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_V, NO);
    
    CGEventPost(kCGAnnotatedSessionEventTap, pasteCommandDown);
    CGEventPost(kCGAnnotatedSessionEventTap, pasteCommandUp);
    
    CFRelease(pasteCommandUp);
    CFRelease(pasteCommandDown);
    CFRelease(source);
}

-(void)copyCode:(NSString*)code{
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
    [pasteBoard setString:code forType:NSStringPboardType];
}


#pragma mark - open on startup

- (BOOL)loginItemExistsWithLoginItemReference{
    BOOL found = NO;
    UInt32 seedValue;
    CFURLRef thePath = NULL;
    LSSharedFileListRef theLoginItemsRefs = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    // We're going to grab the contents of the shared file list (LSSharedFileListItemRef objects)
    // and pop it in an array so we can iterate through it to find our item.
    CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(theLoginItemsRefs, &seedValue);
    for (id item in (__bridge NSArray *)loginItemsArray) {
        LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)item;
        if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &thePath, NULL) == noErr) {
            if ([[(__bridge NSURL *)thePath path] hasPrefix:appPath]) {
                found = YES;
                break;
            }
            // Docs for LSSharedFileListItemResolve say we're responsible
            // for releasing the CFURLRef that is returned
            if (thePath != NULL) CFRelease(thePath);
        }
    }
    if (loginItemsArray != NULL) CFRelease(loginItemsArray);
    
    return found;
}

- (void)enableLoginItemWithURL
{
    if(![self loginItemExistsWithLoginItemReference]){
        LSSharedFileListRef loginListRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
        
        if (loginListRef) {
            // Insert the item at the bottom of Login Items list.
            LSSharedFileListItemRef loginItemRef = LSSharedFileListInsertItemURL(loginListRef,
                                                                                 kLSSharedFileListItemBeforeFirst,
                                                                                 NULL,
                                                                                 NULL,
                                                                                 (__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]],
                                                                                 NULL,
                                                                                 NULL);
            if (loginItemRef) {
                CFRelease(loginItemRef);
            }
            CFRelease(loginListRef);
        }
    }
}

- (void)removeLoginItemWithURL
{
    if([self loginItemExistsWithLoginItemReference]){
        LSSharedFileListRef loginListRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
        
        LSSharedFileListItemRef loginItemRef = LSSharedFileListInsertItemURL(loginListRef,
                                                                             kLSSharedFileListItemBeforeFirst,
                                                                             NULL,
                                                                             NULL,
                                                                             (__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]],
                                                                             NULL,
                                                                             NULL);
        
        // Insert the item at the bottom of Login Items list.
        LSSharedFileListItemRemove(loginListRef, loginItemRef);
    }
}

-(void)openOnStartup{
    int shouldOpenOnStartup;
    if(![self loginItemExistsWithLoginItemReference]){
        [self enableLoginItemWithURL];
        [_showOnStartupItem setState:NSOnState];
        shouldOpenOnStartup = 2;
    }else{
        [self removeLoginItemWithURL];
        [_showOnStartupItem setState:NSOffState];
        shouldOpenOnStartup = 1;
    }
    [_storedStuff setInteger:shouldOpenOnStartup forKey:@"openOnStartup"];
    [_storedStuff synchronize];
}


#pragma mark - quit

-(void)quit{
    [NSApp terminate:self];
}

- (void)onlyOneInstanceOfApp {
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]] count] > 1) {
        [self quit];
    }
}

@end
