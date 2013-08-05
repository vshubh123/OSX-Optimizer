//
//  OptimizerAppDelegate.m
//  OSX Optimizer
//
//  Created by Shubham Vij on 2013-07-09.
//  Copyright (c) 2013 Shubham Vij. All rights reserved.
//

#import "OptimizerAppDelegate.h"

@interface OptimizerAppDelegate ()
    
@property (strong, nonatomic) NSAppleScript * Script;

#pragma mark GameBoosterVars
@property (weak) IBOutlet NSButton *GameBooster_Dashboard;
@property (weak) IBOutlet NSButton *GameBooster_Notification;
@property (weak) IBOutlet NSButton *GameBooster_Dock;
@property (weak) IBOutlet NSButton *GameBooster_Memory;
@property (weak) IBOutlet NSButton *GameBooster_ApplicationsClose;
@property (weak) IBOutlet NSButton *GameBooster_Transparency;
@property (weak) IBOutlet NSPathControl *GameBooster_OpenGame;
@property (weak) IBOutlet NSProgressIndicator *GameBooster_Progress;

#pragma mark MemoryVars
@property (weak) IBOutlet NSButton *Purge_Button;
@property (nonatomic) BOOL moneyPurgeActive;


#pragma mark Optimize-CleanMyMacVars
@property (weak) IBOutlet NSButton *CleanMyMac_ClearTrash;
@property (weak) IBOutlet NSButton *CleanMyMac_EraseFreeSpace;
@property (weak) IBOutlet NSButton *CleanMyMac_SystemCache;
@property (weak) IBOutlet NSButton *CleanMyMac_Permissions;
@property (weak) IBOutlet NSButton *CleanMyMac_FontCache;

@property (weak) IBOutlet NSProgressIndicator *CleanMyMac_Progress;



@end

@implementation OptimizerAppDelegate

#pragma mark CleanMyMac

- (IBAction)CleanMyMac:(NSButton *)sender {
    NSMutableArray *scriptsToCall = [[NSMutableArray alloc] init];
   
    NSLog(@"Cleaning your mac sir!");
    
    if (self.CleanMyMac_ClearTrash.state == NSOnState)
    {
        [scriptsToCall addObject:@"tell application \"Finder\"\n\
         empty the trash\n\
         end tell\""];
    }
  //  if (self.CleanMyMac_EraseFreeSpace.state == NSOnState)
    //{
      //  [scriptsToCall addObject:@""];
   // }
    if (self.CleanMyMac_FontCache.state == NSOnState)
    {
        [scriptsToCall addObject:@"do shell script \"atsutil databases -remove\""];
    }
    if (self.CleanMyMac_Permissions.state == NSOnState)
    {
        [scriptsToCall addObject:@"tell application \"Terminal\" \n\
         do script \"sudo diskutil repairPermissions \"\n\
         end tell\""];
    }
    if (self.CleanMyMac_SystemCache.state == NSOnState)
    {
        [scriptsToCall addObject:@"do shell script \"dscacheutil -flushcache\""];
    }
    
    [self runScriptsInArray:scriptsToCall withProgressBar:self.CleanMyMac_Progress];
    
}


#pragma mark GameBooster
- (IBAction)GameBooster_Activate:(NSButton *)sender {
    
    NSMutableArray *scriptsToCall = [[NSMutableArray alloc] init];
    
    /* Kill the dashboard and widgets*/
    if (self.GameBooster_Dashboard.state == NSOnState)
    {
        [scriptsToCall addObject:@"do shell script \"defaults write com.apple.dashboard mcx-disabled -boolean YES\""];
        [scriptsToCall addObject:@"do shell script \"killall Dock\""];
    }
    
    if (self.GameBooster_Notification.state == NSOnState)
    {
        [scriptsToCall addObject:@"do shell script \"launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist\""];
        [scriptsToCall addObject:@"do shell script \"killall NotificationCenter\""];
    }
    
    if (self.GameBooster_Dock.state == NSOnState)
    {
        [scriptsToCall addObject:@"do shell script \"defaults write com.apple.dock no-glass -boolean yes\""];
        [scriptsToCall addObject:@"do shell script \"killall Dock\""];
    }
    
    if (self.GameBooster_ApplicationsClose.state == NSOnState)
    {
        [scriptsToCall addObject:
                   @"\
                   tell application \"System Events\" to set the visible of every process to true\n\
                   set white_list to {\"Finder\", \"AppleScript Editor\", \"OSX Optimizer\", \"Xcode\"}\n\
                   try\n\
                   tell application \"Finder\"\n\
                   set process_list to the name of every process whose visible is true\n\
                   end tell\n\
                   repeat with i from 1 to (number of items in process_list)\n\
                   set this_process to item i of the process_list\n\
                   if this_process is not in white_list then\n\
                   tell application this_process\n\
                   quit\n\
                   end tell\n\
                   end if\n\
                   end repeat\n\
                   on error\n\
                   tell the current application to display dialog \"An error has occurred!\" & return & \"This script will now quit\" buttons {\"Quit\"} default button 1 with icon 0\n\
                   end try"];
    }
    
    if (self.GameBooster_Transparency.state == NSOnState)
    {
        [scriptsToCall addObject:@"do shell script \"defaults write NSGlobalDomain AppleEnableMenuBarTransparency -bool false\""];
    }
    
    if (self.GameBooster_Memory.state == NSOnState)
    {
        [scriptsToCall addObject:@"do shell script \"purge\""];
    }
    
    NSString *pathToGame = [self.GameBooster_OpenGame.URL.path stringByReplacingOccurrencesOfString:@" " withString:@"\\\\ "];
    [scriptsToCall addObject:
      [NSString stringWithFormat:@"do shell script \"open %@\"",pathToGame]];
    
    [scriptsToCall addObject:@"Terminate"];
    
    [self runScriptsInArray:scriptsToCall withProgressBar:self.GameBooster_Progress];
}
- (IBAction)GameBooster_Deactivate:(NSButton *)sender {
    
    NSMutableArray *scriptsToCall = [[NSMutableArray alloc] init];
    
    /* Re-enable dashboard and widgets*/
    [scriptsToCall addObject:@"do shell script \"defaults write com.apple.dashboard mcx-disabled -boolean NO\""];
    
    /*Re-enable Notification Center*/
    [scriptsToCall addObject:@"do shell script \"launchctl load -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist\""];
    
    
    /* Re-enable 3d dock*/
    [scriptsToCall addObject:@"do shell script \"defaults write com.apple.dock no-glass -boolean no\""];

    /*Re-enable transparency*/
    [scriptsToCall addObject:@"do shell script \"defaults write NSGlobalDomain AppleEnableMenuBarTransparency -bool true\""];
    
    /*Reset the dock*/
    [scriptsToCall addObject:@"do shell script \"killall Dock\""];
    
    [self runScriptsInArray:scriptsToCall withProgressBar:self.GameBooster_Progress];
}




#pragma mark MEMORY
- (IBAction)Memory_Purge:(NSButton *)sender {
    if (self.moneyPurgeActive)
        return;
    
    self.moneyPurgeActive = YES;
    NSMutableArray *scriptsToCall = [[NSMutableArray alloc] init];
    [scriptsToCall addObject:@"do shell script \"purge\""];
    if ([self runScriptsInArray:scriptsToCall withProgressBar:NULL])
    {
        self.Purge_Button.title = @"Memory Purged";
        [self performSelector:@selector(changeTitleMemoryButton) withObject:NULL afterDelay:5];
    }
}
- (void) changeTitleMemoryButton
{
    self.moneyPurgeActive = NO;
    self.Purge_Button.title = @"Purge Memory";
}



#pragma mark RunScripts
- (BOOL) runScriptsInArray:(NSArray *) scripts withProgressBar:(NSProgressIndicator *)progress
{
    NSInteger progressValue = 0;
    for (NSString *command in scripts)
    {
        if ([command isEqualToString:@"Terminate"])
        {
            [[NSApplication sharedApplication] terminate:NULL];
        }
        NSAppleScript *script;
        script = [[NSAppleScript alloc] initWithSource:command];
        if ([script  executeAndReturnError:NULL])
        {
            progressValue++;
            if (progress)
                [progress setDoubleValue:100*progressValue/[scripts count]];
        }
        else
        {
            NSLog(@"Failed script \n%@",command);
        }
        
    }
    return true;
}




#pragma mark Initializations
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.Script = [[NSAppleScript alloc] initWithSource:@"do shell script \"say I am  done\""];

}





@end
