/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "NSLabel.h"

@implementation NSLabel

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    self.bezeled = NO;
    self.editable = NO;
    self.selectable = NO;
    self.drawsBackground = NO;
  }

  return self;
}

- (NSView *)hitTest:(__unused NSPoint)point
{
  return nil;
}

@end
