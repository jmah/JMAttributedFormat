//
//  JMAttributedFormat.m
//  JMAttributedFormat
//
//  Created by Jonathon Mah on 2015-04-11.
//  This file is licensed under the MIT License. See LICENSE.txt for full details.
//

#import "JMAttributedFormat.h"


@implementation NSAttributedString (JMAttributedFormat)

+ (instancetype)attributedStringWithBaseAttributes:(NSDictionary *)baseAttributes format:(NSString *)formatString, ...
{
    va_list args;
    va_start(args, formatString);
    NSAttributedString *as = [[self alloc] initWithBaseAttributes:baseAttributes format:formatString arguments:args];
    va_end(args);
    return as;
}

- (instancetype)initWithBaseAttributes:(NSDictionary *)baseAttributes format:(NSString *)formatString, ...
{
    va_list args;
    va_start(args, formatString);
    self = [self initWithBaseAttributes:baseAttributes format:formatString arguments:args];
    va_end(args);
    return self;
}

- (instancetype)initWithBaseAttributes:(NSDictionary *)baseAttributes format:(NSString *)formatString arguments:(va_list)argList
{
    return [self initWithString:formatString attributes:baseAttributes];
}

@end
