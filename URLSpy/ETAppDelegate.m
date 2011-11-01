//
//  ETAppDelegate.m
//  URLSpy
//
//  Created by PJ Gray on 10/31/11.
//  Copyright (c) 2011 EverTrue. All rights reserved.
//

#import "ETAppDelegate.h"
#import "FileTailer.h"

@implementation ETAppDelegate

@synthesize window = _window;
@synthesize textView;

- (void) tailFile {
    FileTailer *tail = [[FileTailer alloc] initWithPath:@"/Users/pgray/EverTrue/dev/mobile/logs/access_log" refreshPeriod:1.0];
    [tail readIndefinitely:^ void (int ch) { 
        
        lineStr = [lineStr stringByAppendingFormat:@"%c", ch];
        
        if (ch == '\n') {
            Boolean nextStr = NO;
            for (NSString* thisStr in [lineStr componentsSeparatedByString:@" "]) {
                if (nextStr) {
                    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[serverPrefix stringByAppendingFormat:@"%@\n", thisStr]];
                    
                    NSRange range = NSMakeRange(0, [string length]);
                    
                    [string beginEditing];
                    [string addAttribute:NSLinkAttributeName value:string range:range];
                    
                    // make the text appear in blue
                    [string addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:range];
                    
                    // next make the text appear with an underline
                    [string addAttribute:
                     NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:range];
                    
                    [string endEditing];
                    
                    
                    NSTextStorage *storage = [textView textStorage];
                    
                    [storage beginEditing];
                    [storage appendAttributedString:string];
                    [storage endEditing];
                    
                    break;
                } else if ([thisStr isEqualToString:@"Request(GET"])
                    nextStr = YES;
            }
            lineStr = [[NSString alloc] init];
        }
    }];    
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    serverPrefix = @"http://mobile.pj.evertrue.com";
    lineStr = [[NSString alloc] init];

    [self performSelectorInBackground:@selector(tailFile) withObject:nil];
}

- (BOOL)textView:(NSTextView*)textView clickedOnLink:(id)link atIndex:(NSUInteger)charIndex {
    BOOL success = NO;
    
    if ([link isKindOfClass: [NSMutableAttributedString class]])
    {
        NSString *trimmedString = [[link mutableString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        success = [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:trimmedString]];
    }

    
    
    return success;
}

@end
