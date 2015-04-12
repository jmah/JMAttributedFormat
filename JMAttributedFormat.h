//
//  JMAttributedFormat.h
//  JMAttributedFormat
//
//  Created by Jonathon Mah on 2015-04-11.
//  This file is licensed under the MIT License. See LICENSE.txt for full details.
//

#import <Foundation/Foundation.h>


@interface NSObject (JMAttributedFormat_Optional)
/** Classes can optionally implement this to return a custom value when substituted into an attributed format string.
 If not implemented, the object's \p description will be used and given the base attributes. */
- (nullable NSAttributedString *)attributedDescription;
@end


@interface NSAttributedString (JMAttributedFormat)

/** Returns an attributed string created by using the given format string as a template into which the remaining argument values are substituted. */
+ (nullable instancetype)attributedStringWithFormat:(nonnull NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

/** Returns an attributed string created by using the given format string as a template into which the remaining argument values are substituted.
 @param baseAttributes Attributes to apply to the literal parts of \p format , as well as argument values without an attributed description (e.g. plain \p NSString values)
 @param format The format string. Only \p %@ and \p %n$@ (e.g. \p %1$@ ) specifiers are supported
 @param ... A comma-separated list of arguments to substitute into \p format .
 */
+ (nullable instancetype)attributedStringWithBaseAttributes:(nullable NSDictionary *)baseAttributes format:(nonnull NSString *)format, ... NS_FORMAT_FUNCTION(2,3);

/** Returns an attributed string created by using the given format string as a template into which the remaining argument values are substituted.
 @param baseAttributes Attributes to apply to the literal parts of \p format , as well as argument values without an attributed description (e.g. plain \p NSString values)
 @param format The format string. Only \p %@ and \p %n$@ (e.g. \p %1$@ ) specifiers are supported
 @param ... A comma-separated list of arguments to substitute into \p format .
 */
- (nullable instancetype)initWithBaseAttributes:(nullable NSDictionary *)baseAttributes format:(nonnull NSString *)format, ... NS_FORMAT_FUNCTION(2,3);

/** Returns an attributed string created by using the given format string as a template into which the remaining argument values are substituted.
 @param baseAttributes Attributes to apply to the literal parts of \p format , as well as argument values without an attributed description (e.g. plain \p NSString values)
 @param format The format string. Only \p %@ and \p %n$@ (e.g. \p %1$@ ) specifiers are supported
 @param ... A list of arguments to substitute into \p format .
 */
- (nullable instancetype)initWithBaseAttributes:(nullable NSDictionary *)baseAttributes format:(nonnull NSString *)format arguments:(va_list)argList NS_FORMAT_FUNCTION(2,0);

@end
