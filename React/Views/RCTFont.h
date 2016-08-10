/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

#import "RCTConvert.h"

@interface RCTFont : NSObject

/**
 * Update a font with a given font-family, size, weight and style.
 * If parameters are not specified, they'll be kept as-is.
 * If font is nil, the default system font of size 14 will be used.
 */
+ (NSFont *)updateFont:(NSFont *)font
            withFamily:(NSString *)family
                  size:(NSNumber *)size
                weight:(NSString *)weight
                 style:(NSString *)style
       scaleMultiplier:(CGFloat)scaleMultiplier;

+ (NSFont *)updateFont:(NSFont *)font withFamily:(NSString *)family;
+ (NSFont *)updateFont:(NSFont *)font withSize:(NSNumber *)size;
+ (NSFont *)updateFont:(NSFont *)font withWeight:(NSString *)weight;
+ (NSFont *)updateFont:(NSFont *)font withStyle:(NSString *)style;

@end

@interface RCTConvert (RCTFont)

+ (NSFont *)NSFont:(id)json;

@end
