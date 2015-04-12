//
//  JMAttributedFormat.h
//  JMAttributedFormat
//
//  Created by Jonathon Mah on 2015-04-11.
//  This file is licensed under the MIT License. See LICENSE.txt for full details.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


@interface NSAttributedString (JMAttributedFormat)

#pragma mark Formatting

/** Returns an attributed string created by using the given format string as a template into which the remaining argument values are substituted.
 @param format The format string. Only \p %@ and \p %n$@ (e.g. \p %1$@ ) specifiers are supported
 @param ... A comma-separated list of arguments to substitute into \p format .
 */
+ (nullable instancetype)attributedStringWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

/** Returns an attributed string created by using the given format string as a template into which the remaining argument values are substituted.
 @param baseAttributes Attributes to apply to the literal parts of \p format , as well as argument values without an attributed description (e.g. plain \p NSString values)
 @param format The format string. Only \p %@ and \p %n$@ (e.g. \p %1$@ ) specifiers are supported
 @param ... A comma-separated list of arguments to substitute into \p format .
 */
+ (nullable instancetype)attributedStringWithBaseAttributes:(nullable NSDictionary *)baseAttributes format:(NSString *)format, ... NS_FORMAT_FUNCTION(2,3);

/** Returns an attributed string created by using the given format string as a template into which the remaining argument values are substituted.
 @param baseAttributes Attributes to apply to the literal parts of \p format , as well as argument values without an attributed description (e.g. plain \p NSString values)
 @param format The format string. Only \p %@ and \p %n$@ (e.g. \p %1$@ ) specifiers are supported
 @param ... A comma-separated list of arguments to substitute into \p format .
 */
- (nullable instancetype)initWithBaseAttributes:(nullable NSDictionary *)baseAttributes format:(NSString *)format, ... NS_FORMAT_FUNCTION(2,3);

/** Returns an attributed string created by using the given format string as a template into which the remaining argument values are substituted.
 @param baseAttributes Attributes to apply to the literal parts of \p format , as well as argument values without an attributed description (e.g. plain \p NSString values)
 @param format The format string. Only \p %@ and \p %n$@ (e.g. \p %1$@ ) specifiers are supported
 @param argList A list of arguments to substitute into \p format .
 */
- (nullable instancetype)initWithBaseAttributes:(nullable NSDictionary *)baseAttributes format:(NSString *)format arguments:(va_list)argList NS_FORMAT_FUNCTION(2,0);


#pragma mark Localized Formatting

/** Returns an attributed string created by using the given format string as a template into which the remaining argument values are substituted according to the current locale.
 @param format The format string. Only \p %@ and \p %n$@ (e.g. \p %1$@ ) specifiers are supported
 @param ... A comma-separated list of arguments to substitute into \p format .
 */
+ (nullable instancetype)localizedStringWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

/** Returns an attributed string created by using the given format string as a template into which the remaining argument values are substituted according to the current locale.
 @param baseAttributes Attributes to apply to the literal parts of \p format , as well as argument values without an attributed description (e.g. plain \p NSString values)
 @param format The format string. Only \p %@ and \p %n$@ (e.g. \p %1$@ ) specifiers are supported
 @param ... A comma-separated list of arguments to substitute into \p format .
 @discussion When arguments are substituted, \p -attributedDescriptionWithLocale: (or \p -descriptionWithLocale: ) is called instead of \p -attributedDescription (or \p -description ).
 */
+ (nullable instancetype)localizedStringWithBaseAttributes:(nullable NSDictionary *)baseAttributes format:(NSString *)format, ... NS_FORMAT_FUNCTION(2,3);

/** Returns an attributed string created by using the given format string as a template into which the remaining argument values are substituted.
 @param baseAttributes Attributes to apply to the literal parts of \p format , as well as argument values without an attributed description (e.g. plain \p NSString values)
 @param format The format string. Only \p %@ and \p %n$@ (e.g. \p %1$@ ) specifiers are supported
 @param locale An \p NSLocale object specifying the locale to use when substituting argument values. To use the current locale, pass \p [NSLocale currentLocale]. To use the system locale, pass nil.
 @param ... A comma-separated list of arguments to substitute into \p format .
 */
- (nullable instancetype)initWithBaseAttributes:(nullable NSDictionary *)baseAttributes format:(NSString *)format locale:(nullable NSLocale *)locale, ... NS_FORMAT_FUNCTION(2,4);

/** Returns an attributed string created by using the given format string as a template into which the remaining argument values are substituted.
 @param baseAttributes Attributes to apply to the literal parts of \p format , as well as argument values without an attributed description (e.g. plain \p NSString values)
 @param format The format string. Only \p %@ and \p %n$@ (e.g. \p %1$@ ) specifiers are supported
 @param locale An \p NSLocale object specifying the locale to use when substituting argument values. To use the current locale, pass \p [NSLocale currentLocale]. To use the system locale, pass nil.
 @param argList A list of arguments to substitute into \p format .
 */
- (nullable instancetype)initWithBaseAttributes:(nullable NSDictionary *)baseAttributes format:(NSString *)format locale:(nullable NSLocale *)locale arguments:(va_list)argList NS_FORMAT_FUNCTION(2,0);

@end


@interface NSObject (JMAttributedFormat_Optional)

#pragma mark Customizing Attributed Format String Substitution
/** Classes can optionally implement this to return a custom value when substituted into an attributed format string.
 If not implemented, the return value of \p -description will be used and given the base attributes. */
- (nullable NSAttributedString *)attributedDescription;

/** Classes can optionally implement this to return a custom localized value when substituted into an attributed format string.
 If not implemented, falls back first to \p -attributedDescription , then \p -descriptionWithLocale: , and finally \p -description. */
- (nullable NSAttributedString *)attributedDescriptionWithLocale:(nullable NSLocale *)locale;

@end


NS_ASSUME_NONNULL_END
