//
//  AppController.m
//  OpenTheDamnDoor
//
//  Created by Lukas Rieder on 22.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"


@implementation AppController

- (void)awakeFromNib
{
    // Add app to login items    
    LSSharedFileListRef loginItemsListRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    NSURL *bundleURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    
    NSDictionary *properties = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                             forKey:@"com.apple.loginitem.HideOnLaunch"];
    
    LSSharedFileListItemRef itemRef = LSSharedFileListInsertItemURL(loginItemsListRef,
                                            kLSSharedFileListItemLast,
                                            NULL,
                                            NULL,
                                            (CFURLRef)bundleURL,
                                            (CFDictionaryRef)properties,
                                            NULL);
    if (itemRef) {
        CFRelease(itemRef);
    }
    if (loginItemsListRef) {
        CFRelease(loginItemsListRef);
    }
    
	// Create the NSStatusBar and set its length
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
	
	// Setup the statusItem
	[statusItem setTitle:[NSString stringWithFormat:@"🔑"]];
	[statusItem setToolTip:@"Mach mal einer die Tür auf"];
	[statusItem setAction:@selector(openDoor:)];
	[statusItem setTarget:self];
	[statusItem setHighlightMode:YES];
}

- (void)dealloc
{
  [statusItem release];
	[super dealloc];
}

- (IBAction)openDoor:(id)sender
{
	NSLog(@"Trying to open the Door");
	
	// Setup a request
  // TODO investigate and use local domain name again, http://door/...
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://10.0.0.64/letmein.html"] 
                                                         cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                                     timeoutInterval:5.0];
	[request setHTTPMethod:@"GET"];
	
	// Open the connection
  connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
}

// Everything is fine
- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
	[connection release];
  connection = nil;
	NSLog(@"Door opened.");
}

// Something went wrong
- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
  [connection release];
  connection = nil;
	NSLog(@"Doorduino failed!");
    //NSLog(@"Connection Error - %@ %@",
    //      [error localizedDescription]);
	
	NSBeginAlertSheet(@"Verbindungsproblem:\nEntweder bist du offline - oder die Tür.", @"OK", nil, nil, nil, self, nil, nil, nil, @"");
}

@end
