//
//  JMAttributedFormat.m
//  JMAttributedFormat
//
//  Created by Jonathon Mah on 2015-04-11.
//  This file is licensed under the MIT License. See LICENSE.txt for full details.
//

#import "JMAttributedFormat.h"


@implementation NSAttributedString (JMAttributedFormat)

+ (instancetype)attributedStringWithFormat:(NSString *)formatString, ...
{
    va_list args;
    va_start(args, formatString);
    NSAttributedString *as = [[self alloc] initWithBaseAttributes:nil format:formatString arguments:args];
    va_end(args);
    return as;
}

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
    NSParameterAssert(formatString);

    /* Strategy:
     * 1. Scan: Scan format for specifiers (%@ or %n$@), building an array of each specifier's range and position.
     * 2. Read varargs into array, now we know how many there are.
     * 3. Substitute args into the string, from right-to-left so future ranges remain valid.
     */

    BOOL usingExplicitPositions = NO;
    NSMutableArray *formatRanges = [NSMutableArray new];
    NSMutableArray *argumentPositions = [NSMutableArray new]; // 1-based (like printf).
    NSInteger maxArgumentPosition = 0;

    // Step 1: Scan the format string for format specifiers (while validating it).
    NSScanner *scanner = [NSScanner scannerWithString:formatString];
    scanner.charactersToBeSkipped = nil;
    while (!scanner.isAtEnd) {
        [scanner scanUpToString:@"%" intoString:NULL];
        if (scanner.isAtEnd) {
            break;
        }

        NSUInteger percentStart = scanner.scanLocation;
        [scanner scanString:@"%" intoString:NULL];

        NSInteger argumentPosition = 0; // 0 is invalid, must be >= 1
        BOOL argumentPositionExplicit = [scanner scanInteger:&argumentPosition];
        if (argumentPositionExplicit) {
            if (![scanner scanString:@"$@" intoString:NULL]) {
                [NSException raise:NSInvalidArgumentException format:@"Illegal format string: “%@” (character %lu, only “%%%%”, “%%@”, and “%%1$@” are supported)", formatString, (unsigned long)percentStart];
                return nil;
            }

            if (argumentPosition < 1) {
                [NSException raise:NSInvalidArgumentException format:@"Illegal format string: “%@” (invalid argument position %ld)", formatString, (long)argumentPosition];
                return nil;
            }

        } else if ([scanner scanString:@"@" intoString:NULL]) {
            argumentPosition = argumentPositions.count + 1;

        } else if ([scanner scanString:@"%" intoString:NULL]) { // literal percent
            argumentPosition = 0;

        } else {
            [NSException raise:NSInvalidArgumentException format:@"Illegal format string: “%@” (character %lu, only “%%%%”, “%%@”, and “%%1$@” are supported)", formatString, (unsigned long)percentStart];
            return nil;
        }

        if (maxArgumentPosition > 0) {
            if (argumentPositionExplicit != usingExplicitPositions) {
                [NSException raise:NSInvalidArgumentException format:@"Illegal format string: “%@” (cannot mix explicit and implicit argument positions)", formatString];
                return nil;
            }
        } else {
            usingExplicitPositions = argumentPositionExplicit;
        }

        maxArgumentPosition = MAX(maxArgumentPosition, argumentPosition);
        [argumentPositions addObject:@(argumentPosition)];
        [formatRanges addObject:[NSValue valueWithRange:NSMakeRange(percentStart, scanner.scanLocation - percentStart)]];
    }
    NSAssert(formatRanges.count == argumentPositions.count, nil);


    // Step 2: Read arguments into array of NSAttributedString
    NSMutableArray *attributedStringArguments = [NSMutableArray new]; // 0-based
    // Add literal percent at index 0
    [attributedStringArguments addObject:[[NSAttributedString alloc] initWithString:@"%" attributes:baseAttributes]];
    for (NSInteger i = 0; i < maxArgumentPosition; i++) {
        id arg = va_arg(argList, id);
        if ([arg respondsToSelector:@selector(attributedDescription)]) {
            [attributedStringArguments addObject:[arg attributedDescription]];
        } else {
            NSString *string = [arg description] ? : @"(null)";
            [attributedStringArguments addObject:[[NSAttributedString alloc] initWithString:string attributes:baseAttributes]];
        }
    }


    // Step 3. Substitute arguments into string
    NSMutableAttributedString *mutableInstance;
    // Respect the `instancetype` interface: Return a subclass of `self`; to do the substitution this must also be mutable.
    if ([self isKindOfClass:[NSMutableAttributedString class]]) {
        mutableInstance = (id)self;
    } else {
        mutableInstance = [NSMutableAttributedString alloc];
    }
    mutableInstance = [mutableInstance initWithString:formatString attributes:baseAttributes];

    [mutableInstance beginEditing];
    [formatRanges enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSValue *range, NSUInteger index, BOOL *stop) {
        NSInteger argumentPosition = ((NSNumber *)argumentPositions[index]).integerValue;
        NSAttributedString *substituteAttributedString = attributedStringArguments[argumentPosition];
        [mutableInstance replaceCharactersInRange:range.rangeValue withAttributedString:substituteAttributedString];
    }];
    [mutableInstance endEditing];
    
    return mutableInstance;
}

- (NSAttributedString *)attributedDescription
{
    return self;
}

@end
