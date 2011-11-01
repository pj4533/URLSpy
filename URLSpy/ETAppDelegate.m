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


- (void) addStringToTextView:(NSMutableAttributedString*) string {
    NSTextStorage *storage = [textView textStorage];
    
    [storage beginEditing];
    [storage appendAttributedString:string];
    [storage endEditing];
}

- (void) tailFileWithPath:(NSDictionary*) dict {
    @autoreleasepool {
        FileTailer *tail = [[FileTailer alloc] initWithPath:[dict objectForKey:@"path"] refreshPeriod:1.0];
        __block NSString* lineStr = [[NSString alloc] init];

        [tail readIndefinitely:^ void (int ch) { 
            
            lineStr = [lineStr stringByAppendingFormat:@"%c", ch];
            
            if (ch == '\n') {
                Boolean nextStr = NO;
                for (NSString* thisStr in [lineStr componentsSeparatedByString:@" "]) {
                    if (nextStr) {
                        NSString* server = [dict objectForKey:@"server"];
                        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[server stringByAppendingFormat:@"%@\n", thisStr]];
                        
                        NSRange range = NSMakeRange(0, [string length]);
                        
                        [string beginEditing];
                        [string addAttribute:NSLinkAttributeName value:string range:range];
                        
                        // make the text appear in blue
                        [string addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:range];
                        
                        // next make the text appear with an underline
                        [string addAttribute:
                         NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:range];
                        
                        [string endEditing];
                        
                        [self performSelectorOnMainThread:@selector(addStringToTextView:) withObject:string waitUntilDone:YES];
                        
                        break;
                    } else {
                        NSRange textRange;
                        textRange =[thisStr rangeOfString:@"GET"];
                        
                        if(textRange.location != NSNotFound)
                            nextStr = YES;
                    }
                }
                lineStr = [[NSString alloc] init];
            }
        }];    
    }
}

- (void) startWatchingFileWithPath:(NSString*) path withServer:(NSString*) server {
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:path, @"path",
                          server, @"server",
                          nil];
    
    NSThread* newThread = [[NSThread alloc] initWithTarget:self selector:@selector(tailFileWithPath:) object:dict];
    [newThread start];
    [watcherThreads addObject:newThread];
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    watcherThreads = [[NSMutableArray alloc] init];
    
    [self startWatchingFileWithPath:@"/Users/pgray/EverTrue/dev/mobile/logs/access_log" withServer:@"http://mobile.pj.evertrue.com"];
    [self startWatchingFileWithPath:@"/Users/pgray/EverTrue/dev/api/logs/access_log" withServer:@"http://api.pj.evertrue.com"];
    [self startWatchingFileWithPath:@"/Users/pgray/EverTrue/dev/www/logs/access_log" withServer:@"http://www.pj.evertrue.com"];
    [self startWatchingFileWithPath:@"/Users/pgray/EverTrue/dev/admin/logs/access_log" withServer:@"http://admin.pj.evertrue.com"];
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
