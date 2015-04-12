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


@interface JMCustomAttributedDescription : NSObject
@property (nonatomic) NSString *stringValue;
@end

@implementation JMCustomAttributedDescription
- (NSAttributedString *)attributedDescription
{
    return [[NSAttributedString alloc] initWithString:self.stringValue attributes:@{@"JMCustomClass": [self class]}];
}
@end


@implementation JMAttributedFormatTests

- (void)testInstancetype
{
    for (Class c in @[[NSAttributedString class], [NSMutableAttributedString class], [NSTextStorage class]]) {
        NSAttributedString *as = [c attributedStringWithBaseAttributes:nil format:@"test"];
        XCTAssert([as isKindOfClass:c]);
    }
}

- (void)testLiteralPercents
{
    NSAttributedString *s1 = [NSAttributedString attributedStringWithBaseAttributes:nil format:@"100%% working"];
    XCTAssertEqualObjects(s1.string, @"100% working");

    NSAttributedString *s2 = [NSAttributedString attributedStringWithBaseAttributes:nil format:@"Double %%%%"];
    XCTAssertEqualObjects(s2.string, @"Double %%");
}

- (void)testAttributedStringInterpolation
{
    NSDictionary *baseAttributes = @{@"BaseAttribute": @YES};
    NSDictionary *innerAttributes = @{@"IsSubstitute": @YES};

    NSAttributedString *inner = [[NSAttributedString alloc] initWithString:@"inner" attributes:innerAttributes];
    NSAttributedString *as = [NSAttributedString attributedStringWithBaseAttributes:baseAttributes format:@"before %@ after", inner];
    XCTAssertEqualObjects(as.string, @"before inner after");

    __block NSInteger attributeCount = 0;
    [as enumerateAttributesInRange:NSMakeRange(0, as.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        attributeCount++;
        NSString *substring = [as.string substringWithRange:range];
        if ([attrs isEqual:baseAttributes]) {
            if (attributeCount == 1) {
                XCTAssertEqualObjects(substring, @"before ");
            } else if (attributeCount == 3) {
                XCTAssertEqualObjects(substring, @" after");
            } else {
                XCTFail(@"Unexpected attributes on substring “%@”", substring);
            }
        } else if ([attrs isEqual:innerAttributes]) {
            XCTAssertEqualObjects(substring, @"inner");
        } else {
            XCTFail(@"Unexpected attributes %@", attrs);
        }
    }];
    XCTAssertEqual(attributeCount, 3);
}

- (void)testMixedInterpolation
{
    NSDictionary *baseAttributes = @{@"BaseAttribute": @YES};
    NSDictionary *innerAttributes = @{@"IsSubstitute": @YES};

    NSString *plainInner = @"plain";
    NSAttributedString *attrInner = [[NSAttributedString alloc] initWithString:@"attributed" attributes:@{@"IsSubstitute": @YES}];

    NSAttributedString *as = [[NSAttributedString alloc] initWithBaseAttributes:baseAttributes format:@"base %@ %@", plainInner, attrInner];
    XCTAssertEqualObjects(as.string, @"base plain attributed");

    __block NSInteger attributeCount = 0;
    [as enumerateAttributesInRange:NSMakeRange(0, as.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        attributeCount++;
        NSString *substring = [as.string substringWithRange:range];
        if ([attrs isEqual:baseAttributes]) {
            XCTAssertEqualObjects(substring, @"base plain ");
        } else if ([attrs isEqual:innerAttributes]) {
            XCTAssertEqualObjects(substring, @"attributed");
        } else {
            XCTFail(@"Unexpected attributes %@", attrs);
        }
    }];
    XCTAssertEqual(attributeCount, 2);
}

- (void)testReordering
{
    NSString *one = @"one", *two = @"two";

    NSAttributedString *oneTwo = [NSAttributedString attributedStringWithFormat:@"A %1$@ B %2$@", one, two];
    XCTAssertEqualObjects(oneTwo.string, @"A one B two");

    NSAttributedString *twoOne = [NSAttributedString attributedStringWithFormat:@"A %2$@ B %1$@", one, two];
    XCTAssertEqualObjects(twoOne.string, @"A two B one");
}

- (void)testCustomAttributedDescription
{
    NSDictionary *baseAttributes = @{@"BaseAttribute": @YES};

    NSString *plain = @"plain";
    JMCustomAttributedDescription *custom = [JMCustomAttributedDescription new];
    custom.stringValue = @"custom";

    NSAttributedString *plainCustom = [NSAttributedString attributedStringWithBaseAttributes:baseAttributes format:@"A %1$@ B %2$@", plain, custom];
    XCTAssertEqualObjects(plainCustom.string, @"A plain B custom");
    XCTAssertEqualObjects(plainCustom.description,
                          @"A plain B {\n    BaseAttribute = 1;\n}"
                          @"custom{\n    JMCustomClass = JMCustomAttributedDescription;\n}");

    NSAttributedString *customPlain = [NSAttributedString attributedStringWithBaseAttributes:baseAttributes format:@"A %2$@ B %1$@", plain, custom];
    XCTAssertEqualObjects(customPlain.string, @"A custom B plain");
    XCTAssertEqualObjects(customPlain.description,
                          @"A {\n    BaseAttribute = 1;\n}"
                          @"custom{\n    JMCustomClass = JMCustomAttributedDescription;\n}"
                          @" B plain{\n    BaseAttribute = 1;\n}");
}

- (void)testInvalidFormats
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat"
    XCTAssertThrowsSpecificNamed([NSAttributedString attributedStringWithBaseAttributes:nil format:@"trailing %"], NSException, NSInvalidArgumentException);

    XCTAssertThrowsSpecificNamed([NSAttributedString attributedStringWithBaseAttributes:nil format:@"mixing positional %1$@ and plain %@"], NSException, NSInvalidArgumentException);

    XCTAssertThrowsSpecificNamed([NSAttributedString attributedStringWithBaseAttributes:nil format:@"mixing plain %@ and positional %1$@"], NSException, NSInvalidArgumentException);

    XCTAssertThrowsSpecificNamed([NSAttributedString attributedStringWithBaseAttributes:nil format:@"illegal position %0$@"], NSException, NSInvalidArgumentException);

    XCTAssertThrowsSpecificNamed([NSAttributedString attributedStringWithBaseAttributes:nil format:@"illegal position %-1$@"], NSException, NSInvalidArgumentException);

    XCTAssertThrowsSpecificNamed([NSAttributedString attributedStringWithBaseAttributes:nil format:@"unsupported formats %d"], NSException, NSInvalidArgumentException);

    XCTAssertThrowsSpecificNamed([NSAttributedString attributedStringWithBaseAttributes:nil format:@"unsupported positional format %1$d"], NSException, NSInvalidArgumentException);
#pragma clang diagnostic pop
}

@end
