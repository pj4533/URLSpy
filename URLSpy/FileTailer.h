//
//  Created by Michael Dippery on 1/12/2011.
//  Copyright 2011 Michael Dippery. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdio.h>

@interface FileTailer : NSObject
{
    FILE *in;
    NSTimeInterval refresh;
}

- (id)initWithPath:(NSString *)path refreshPeriod:(NSTimeInterval)aRefresh;
- (id)initWithStream:(FILE *)fh refreshPeriod:(NSTimeInterval)aRefresh;
- (void)readIndefinitely:(void (^)(int ch))action;

@end