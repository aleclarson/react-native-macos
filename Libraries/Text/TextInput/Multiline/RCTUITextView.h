/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <AppKit/AppKit.h>

#import "RCTBackedTextInputViewProtocol.h"

#import "RCTBackedTextInputDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/*
 * Just regular NSTextView... but much better!
 */
@interface RCTUITextView : NSTextView <RCTBackedTextInputViewProtocol>

- (instancetype)initWithFrame:(CGRect)frame textContainer:(nullable NSTextContainer *)textContainer NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)decoder NS_UNAVAILABLE;

@property (nonatomic, weak) id<RCTBackedTextInputDelegate> textInputDelegate;

@property (nonatomic, assign, readonly) BOOL textWasPasted;
// @property (nonatomic, copy, nullable) NSString *placeholder;
// @property (nonatomic, strong, nullable) NSColor *placeholderColor;
@property (nonatomic, assign) NSEdgeInsets paddingInsets;
@property (nonatomic, assign) CGFloat preferredMaxLayoutWidth;
@property (nonatomic, assign) BOOL prefersFocus;

@end

NS_ASSUME_NONNULL_END
