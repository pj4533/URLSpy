//
//  Created by Michael Dippery on 1/12/2011.
//  Copyright 2011 Michael Dippery. All rights reserved.
//

#import "FileTailer.h"

@implementation FileTailer

- (id)initWithPath:(NSString *)path refreshPeriod:(NSTimeInterval)aRefresh
{
    FILE *fh = fopen([path UTF8String], "r");
    if (!fh) {
        NSLog(@"Could not open file: %@", path);
        return nil;
    }
    return [self initWithStream:fh refreshPeriod:aRefresh];
}

- (id)initWithStream:(FILE *)fh refreshPeriod:(NSTimeInterval)aRefresh
{
    if ((self = [super init])) {
        in = fh;
        refresh = aRefresh;
    }
    return self;
}

- (void)dealloc
{
    fclose(in);
}

- (void)readIndefinitely:(void (^)(int ch))action
{
    fseek(in, 0, SEEK_END);
    long pos = ftell(in);
    int ch = 0;
    
    while (1) {
        fseek(in, pos, SEEK_SET);
        ch = fgetc(in);
        pos = ftell(in);
        if (ch != EOF) {
            action(ch);
        } else {
            [NSThread sleepForTimeInterval:refresh];
        }
    }
}

@end