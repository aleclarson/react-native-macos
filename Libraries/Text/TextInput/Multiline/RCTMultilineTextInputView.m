/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "RCTMultilineTextInputView.h"

#import <React/RCTUtils.h>
#import <React/NSView+React.h>

#import "RCTUITextView.h"

@implementation RCTMultilineTextInputView
{
  RCTUITextView *_backedTextInputView;
}

- (instancetype)initWithBridge:(RCTBridge *)bridge
{
  if (self = [super initWithBridge:bridge]) {
    // `blurOnSubmit` defaults to `false` for <TextInput multiline={true}> by design.
    self.blurOnSubmit = NO;

    _backedTextInputView = [[RCTUITextView alloc] initWithFrame:self.bounds];
    _backedTextInputView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    _backedTextInputView.backgroundColor = [NSColor clearColor];
    _backedTextInputView.textColor = [NSColor blackColor];
    // This line actually removes 5pt (default value) left and right padding in UITextView.
    _backedTextInputView.textContainer.lineFragmentPadding = 0;
    _backedTextInputView.textInputDelegate = self;

    _scrollView = [[RCTTextScrollView alloc] initWithFrame:NSZeroRect];
    _scrollView.documentView = _backedTextInputView;

    [self addSubview:_scrollView];
  }

  return self;
}

- (void)setFrame:(NSRect)frame
{
  [super setFrame:frame];
  _scrollView.frameSize = frame.size;
}

- (void)setReactBorderInsets:(NSEdgeInsets)reactBorderInsets
{
  [super setReactBorderInsets:reactBorderInsets];
  _scrollView.contentInsets = self.reactCompoundInsets;
}

- (void)setReactPaddingInsets:(NSEdgeInsets)reactPaddingInsets
{
  [super setReactPaddingInsets:reactPaddingInsets];
  _scrollView.contentInsets = self.reactCompoundInsets;
}

RCT_NOT_IMPLEMENTED(- (instancetype)initWithFrame:(CGRect)frame)
RCT_NOT_IMPLEMENTED(- (instancetype)initWithCoder:(NSCoder *)coder)

- (id<RCTBackedTextInputViewProtocol>)backedTextInputView
{
  return _backedTextInputView;
}

#pragma mark - NSScrollViewDelegate

@end

@implementation RCTTextScrollView

- (instancetype)initWithFrame:(NSRect)frame
{
  if (self = [super initWithFrame:frame]) {
    self.hasVerticalScroller = YES;
    self.automaticallyAdjustsContentInsets = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didScroll)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:self.contentView];
  }

  return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_didScroll
{
  if (self.onScroll) {
    NSSize size = self.bounds.size;
    NSRect contentRect = self.contentView.bounds;
    NSEdgeInsets contentInset = self.contentInsets;

    self.onScroll(@{
      @"contentOffset": @{
        @"x": @(contentRect.origin.x),
        @"y": @(contentRect.origin.y)
      },
      @"contentInset": @{
        @"top": @(contentInset.top),
        @"left": @(contentInset.left),
        @"bottom": @(contentInset.bottom),
        @"right": @(contentInset.right)
      },
      @"contentSize": @{
        @"width": @(contentRect.size.width),
        @"height": @(contentRect.size.height)
      },
      @"layoutMeasurement": @{
        @"width": @(size.width),
        @"height": @(size.height)
      },
      @"zoomScale": @(1),
    });
  }
}

@end
