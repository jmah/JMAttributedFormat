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
@property (nonatomic) id innerValue;
@end

@implementation JMCustomAttributedDescription
- (NSAttributedString *)attributedDescription
{
    if (!self.innerValue) {
        return nil;
    }
    return [[NSAttributedString alloc] initWithString:[self.innerValue description] attributes:@{@"JMCustomClass": [self class]}];
}
@end


@interface JMCustomAttributedDescriptionWithLocale : NSObject
@property (nonatomic) id innerValue;
@end

@implementation JMCustomAttributedDescriptionWithLocale
- (NSAttributedString *)attributedDescription
{ return [self attributedDescriptionWithLocale:nil]; }

- (NSAttributedString *)attributedDescriptionWithLocale:(NSLocale *)locale
{
    if (!self.innerValue) {
        return nil;
    }
    return [[NSAttributedString alloc] initWithString:[self.innerValue descriptionWithLocale:locale] attributes:@{@"JMCustomClass": [self class]}];
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
    custom.innerValue = @"custom";

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

- (void)testNilArguments
{
    NSAttributedString *oneNil = [NSAttributedString attributedStringWithFormat:@"A %@ B %@", @"one", nil];
    NSString *plainOneNil = [NSString stringWithFormat:@"A %@ B %@", @"one", nil];
    XCTAssertEqualObjects(oneNil.string, @"A one B (null)");
    XCTAssertEqualObjects(oneNil.string, plainOneNil);

    JMCustomAttributedDescription *emptyCustom = [JMCustomAttributedDescription new];
    NSAttributedString *customNil = [NSAttributedString attributedStringWithFormat:@"custom %@", emptyCustom];
    XCTAssertEqualObjects(customNil.string, @"custom (null)");
}

- (void)testLocalizedSubstitution
{
    NSNumber *number = @(1234.5);
    NSString *nonLocalizedString = @"suffix";

    NSLocale *enUS = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    NSLocale *frFR = [NSLocale localeWithLocaleIdentifier:@"fr_FR"];

    NSString *plainSystem = [[NSString alloc] initWithFormat:@"format %@ %@", number, nonLocalizedString];
    NSAttributedString *attrSystem = [[NSAttributedString alloc] initWithBaseAttributes:nil format:@"format %@ %@", number, nonLocalizedString];
    XCTAssertEqualObjects(plainSystem, @"format 1234.5 suffix"); // no comma
    XCTAssertEqualObjects(plainSystem, attrSystem.string);

    NSString *plainEnUS = [[NSString alloc] initWithFormat:@"format %@ %@" locale:enUS, number, nonLocalizedString];
    NSAttributedString *attrEnUS = [[NSAttributedString alloc] initWithBaseAttributes:nil format:@"format %@ %@" locale:enUS, number, nonLocalizedString];
    XCTAssertEqualObjects(plainEnUS, @"format 1,234.5 suffix");
    XCTAssertEqualObjects(plainEnUS, attrEnUS.string);

    NSString *plainFrFR = [[NSString alloc] initWithFormat:@"format %@ %@" locale:frFR, number, nonLocalizedString];
    NSAttributedString *attrFrFR = [[NSAttributedString alloc] initWithBaseAttributes:nil format:@"format %@ %@" locale:frFR, number, nonLocalizedString];
    XCTAssertEqualObjects(plainFrFR, @"format 1 234,5 suffix"); // nbsp as thousands separator
    XCTAssertEqualObjects(plainFrFR, attrFrFR.string);
}

- (void)testCustomLocalizedSubstitution
{
    NSDictionary *baseAttributes = @{@"BaseAttribute": @YES};
    NSNumber *number = @(1234.5);
    NSLocale *enUS = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    NSLocale *frFR = [NSLocale localeWithLocaleIdentifier:@"fr_FR"];

    JMCustomAttributedDescriptionWithLocale *custom = [JMCustomAttributedDescriptionWithLocale new];
    custom.innerValue = number;

    NSAttributedString *attrCustomSystem = [[NSAttributedString alloc] initWithBaseAttributes:baseAttributes format:@"format %@", custom];
    XCTAssertEqualObjects(attrCustomSystem.description,
                          @"format {\n    BaseAttribute = 1;\n}"
                          @"1234.5{\n    JMCustomClass = JMCustomAttributedDescriptionWithLocale;\n}");

    NSAttributedString *attrCustomEnUS = [[NSAttributedString alloc] initWithBaseAttributes:baseAttributes format:@"format %@" locale:enUS, custom];
    XCTAssertEqualObjects(attrCustomEnUS.description,
                          @"format {\n    BaseAttribute = 1;\n}"
                          @"1,234.5{\n    JMCustomClass = JMCustomAttributedDescriptionWithLocale;\n}");

    NSAttributedString *attrCustomFrFR = [[NSAttributedString alloc] initWithBaseAttributes:baseAttributes format:@"format %@" locale:frFR, custom];
    XCTAssertEqualObjects(attrCustomFrFR.description,
                          @"format {\n    BaseAttribute = 1;\n}"
                          @"1 234,5{\n    JMCustomClass = JMCustomAttributedDescriptionWithLocale;\n}");
}

- (void)testSubstitutingFormatSpecifiers
{
    NSString *fs1 = @"%@", *fs2 = @"%22$d", *fs3 = @"%";
    NSAttributedString *as = [NSAttributedString attributedStringWithFormat:@"1 %@ 2 %@ 3 %@", fs1, fs2, fs3];
    XCTAssertEqualObjects(as.string, @"1 %@ 2 %22$d 3 %");
}

- (void)testInvalidFormats
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat"
    XCTAssertThrowsSpecificNamed([NSAttributedString attributedStringWithBaseAttributes:nil format:@"trailing %"], NSException, NSInvalidArgumentException);

    XCTAssertThrowsSpecificNamed([NSAttributedString attributedStringWithBaseAttributes:nil format:@"raw % without anything"], NSException, NSInvalidArgumentException);

    XCTAssertThrowsSpecificNamed([NSAttributedString attributedStringWithBaseAttributes:nil format:@"mixing positional %1$@ and plain %@"], NSException, NSInvalidArgumentException);

    XCTAssertThrowsSpecificNamed([NSAttributedString attributedStringWithBaseAttributes:nil format:@"mixing plain %@ and positional %1$@"], NSException, NSInvalidArgumentException);

    XCTAssertThrowsSpecificNamed([NSAttributedString attributedStringWithBaseAttributes:nil format:@"illegal position %0$@"], NSException, NSInvalidArgumentException);

    XCTAssertThrowsSpecificNamed([NSAttributedString attributedStringWithBaseAttributes:nil format:@"illegal position %-1$@"], NSException, NSInvalidArgumentException);

    XCTAssertThrowsSpecificNamed([NSAttributedString attributedStringWithBaseAttributes:nil format:@"unsupported formats %d"], NSException, NSInvalidArgumentException);

    XCTAssertThrowsSpecificNamed([NSAttributedString attributedStringWithBaseAttributes:nil format:@"unsupported positional formats %1$d"], NSException, NSInvalidArgumentException);

    XCTAssertThrowsSpecificNamed([NSAttributedString attributedStringWithBaseAttributes:nil format:@"unsupported positional format %1$d"], NSException, NSInvalidArgumentException);
#pragma clang diagnostic pop
}

@end
