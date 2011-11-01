//
//  ETAppDelegate.h
//  URLSpy
//
//  Created by PJ Gray on 10/31/11.
//  Copyright (c) 2011 EverTrue. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ETAppDelegate : NSObject <NSApplicationDelegate, NSTextViewDelegate> {
    NSString* lineStr;
    NSString* serverPrefix;
}

@property (assign) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSTextView *textView;


@end
