/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RCTActivityIndicatorViewManager.h"

#import "RCTActivityIndicatorView.h"
#import "RCTConvert.h"

@implementation RCTConvert (NSProgressIndicator)

// NOTE: It's pointless to support UIActivityIndicatorViewStyleGray
// as we can set the color to any arbitrary value that we want to

//RCT_ENUM_CONVERTER(UIActivityIndicatorViewStyle, (@{
//  @"large": @(UIActivityIndicatorViewStyleWhiteLarge),
//  @"small": @(UIActivityIndicatorViewStyleWhite),
//}), UIActivityIndicatorViewStyleWhiteLarge, integerValue)

@end

@implementation RCTActivityIndicatorViewManager

RCT_EXPORT_MODULE()

- (NSView *)view
{
  RCTActivityIndicatorView* indicator = [[RCTActivityIndicatorView alloc] init];
  [indicator setControlSize:NSRegularControlSize];
  [indicator setStyle:NSProgressIndicatorStyleSpinning];
  [indicator setUsesThreadedAnimation:YES];
  [indicator setDisplayedWhenStopped:NO];
  [indicator setHidden:YES];
  indicator.controlTint = NSClearControlTint;
  indicator.wantsLayer = YES;
  
  return indicator;
}

//RCT_EXPORT_VIEW_PROPERTY(color, NSColor) // implement drawRect
RCT_REMAP_VIEW_PROPERTY(color, controlTint, NSColor)
//RCT_EXPORT_VIEW_PROPERTY(hidesWhenStopped, BOOL)

RCT_CUSTOM_VIEW_PROPERTY(animating, BOOL, __unused RCTActivityIndicatorView)
{
  //TODO: store animated property because NSProgressIndicator doesn't have a suitable method
  BOOL animating = json ? [RCTConvert BOOL:json] : YES;
  if (animating) {
    [view setHidden:NO];
    [view startAnimation:self];
  } else {
    [view stopAnimation:self];
    [view setHidden:YES];
  }
}

@end
