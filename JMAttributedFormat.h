//
//  JMAttributedFormat.h
//  JMAttributedFormat
//
//  Created by Jonathon Mah on 2015-04-11.
//  This file is licensed under the MIT License. See LICENSE.txt for full details.
//

#import <Foundation/Foundation.h>


@interface NSObject (JMAttributedFormat_Optional)
- (NSAttributedString *)attributedDescription;
@end


@interface NSAttributedString (JMAttributedFormat)

+ (instancetype)attributedStringWithBaseAttributes:(NSDictionary *)baseAttributes format:(NSString *)formatString, ... NS_FORMAT_FUNCTION(2,3);
- (instancetype)initWithBaseAttributes:(NSDictionary *)baseAttributes format:(NSString *)formatString, ... NS_FORMAT_FUNCTION(2,3);
- (instancetype)initWithBaseAttributes:(NSDictionary *)baseAttributes format:(NSString *)formatString arguments:(va_list)argList NS_FORMAT_FUNCTION(2,0);

@end
