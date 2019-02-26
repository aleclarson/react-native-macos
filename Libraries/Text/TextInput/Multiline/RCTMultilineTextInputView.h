/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "RCTBaseTextInputView.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCTTextScrollView : NSScrollView
@property (nonatomic, copy) RCTDirectEventBlock onScroll;
@end

#pragma mark -

@interface RCTMultilineTextInputView : RCTBaseTextInputView
@property (nonatomic, strong) RCTTextScrollView *scrollView;
@end

NS_ASSUME_NONNULL_END
