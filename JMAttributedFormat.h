//
//  JMAttributedFormat.h
//  JMAttributedFormat
//
//  Created by Jonathon Mah on 2015-04-11.
//  This file is licensed under the MIT License. See LICENSE.txt for full details.
//

#import <Foundation/Foundation.h>


@interface NSObject (JMAttributedFormat_Optional)
- (nullable NSAttributedString *)attributedDescription;
@end


@interface NSAttributedString (JMAttributedFormat)

+ (nullable instancetype)attributedStringWithFormat:(nonnull NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
+ (nullable instancetype)attributedStringWithBaseAttributes:(nullable NSDictionary *)baseAttributes format:(nonnull NSString *)format, ... NS_FORMAT_FUNCTION(2,3);
- (nullable instancetype)initWithBaseAttributes:(nullable NSDictionary *)baseAttributes format:(nonnull NSString *)format, ... NS_FORMAT_FUNCTION(2,3);
- (nullable instancetype)initWithBaseAttributes:(nullable NSDictionary *)baseAttributes format:(nonnull NSString *)format arguments:(va_list)argList NS_FORMAT_FUNCTION(2,0);

@end
