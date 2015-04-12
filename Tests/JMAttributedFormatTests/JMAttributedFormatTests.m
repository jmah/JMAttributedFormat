//
//  JMAttributedFormatTests.m
//  JMAttributedFormatTests
//
//  Created by Jonathon Mah on 2015-04-11.
//  This file is licensed under the MIT License. See LICENSE.txt for full details.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "JMAttributedFormat.h"


@interface JMAttributedFormatTests : XCTestCase
@end


@implementation JMAttributedFormatTests

- (void)testInstancetype
{
    for (Class c in @[[NSAttributedString class], [NSMutableAttributedString class], [NSTextStorage class]]) {
        NSAttributedString *as = [c attributedStringWithBaseAttributes:nil format:@"test"];
        XCTAssert([as isKindOfClass:c]);
    }
}

@end
