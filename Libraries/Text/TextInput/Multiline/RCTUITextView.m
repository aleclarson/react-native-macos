/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "RCTUITextView.h"

#import <React/RCTUtils.h>
#import <React/NSView+React.h>

#import "RCTBackedTextInputDelegateAdapter.h"
#import "NSLabel.h"

@implementation RCTUITextView
{
  NSLabel *_placeholderView;

  RCTBackedTextViewDelegateAdapter *_textInputDelegateAdapter;
}

static NSFont *defaultPlaceholderFont()
{
  return [NSFont systemFontOfSize:17];
}

static NSColor *defaultPlaceholderColor()
{
  // Default placeholder color from UITextField.
  return [NSColor colorWithRed:0 green:0 blue:0.0980392 alpha:0.22];
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange)
                                                 name:NSControlTextDidChangeNotification
                                               object:self];

    _placeholderView = [[NSLabel alloc] initWithFrame:self.bounds];
//    _placeholderView.isAccessibilityElement = NO;
    _placeholderView.textColor = defaultPlaceholderColor();
    [self addSubview:_placeholderView];

    _textInputDelegateAdapter = [[RCTBackedTextViewDelegateAdapter alloc] initWithTextView:self];
  }

  return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)accessibilityLabel
{
  NSMutableString *accessibilityLabel = [NSMutableString new];
  
  NSString *superAccessibilityLabel = [super accessibilityLabel];
  if (superAccessibilityLabel.length > 0) {
    [accessibilityLabel appendString:superAccessibilityLabel];
  }
  
  if (self.placeholder.length > 0 && self.attributedText.string.length == 0) {
    if (accessibilityLabel.length > 0) {
      [accessibilityLabel appendString:@" "];
    }
    [accessibilityLabel appendString:self.placeholder];
  }
  
  return accessibilityLabel;
}

#pragma mark - Properties

- (void)setPlaceholder:(NSString *)placeholder
{
  _placeholder = placeholder;
  _placeholderView.stringValue = _placeholder;
}

- (void)setPlaceholderColor:(NSColor *)placeholderColor
{
  _placeholderColor = placeholderColor;
  _placeholderView.textColor = _placeholderColor ?: defaultPlaceholderColor();
}

- (void)textDidChange
{
  _textWasPasted = NO;
  [self invalidatePlaceholderVisibility];
  [self invalidateIntrinsicContentSize];
}

#pragma mark - Overrides

- (void)setFont:(NSFont *)font
{
  [super setFont:font];
  _placeholderView.font = font ?: defaultPlaceholderFont();
}

- (NSTextAlignment)textAlignment
{
  return self.alignment;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
  [self setAlignment:textAlignment];
  _placeholderView.alignment = textAlignment;
}

- (NSString *)text
{
  return self.string;
}

- (void)setText:(NSString *)text
{
  [self setString:text];
  [self textDidChange];
}

- (NSAttributedString *)attributedText
{
  return self.textStorage;
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
  [self.textStorage setAttributedString:attributedText];
  [self textDidChange];
}

#pragma mark - Overrides

- (NSRange)selectedTextRange
{
  return self.selectedRange;
}

- (void)setSelectedTextRange:(NSRange)selectedTextRange notifyDelegate:(BOOL)notifyDelegate
{
  if (!notifyDelegate) {
    // We have to notify an adapter that following selection change was initiated programmatically,
    // so the adapter must not generate a notification for it.
    [_textInputDelegateAdapter skipNextTextInputDidChangeSelectionEventWithTextRange:selectedTextRange];
  }
  [super setSelectedRange:selectedTextRange];
}

- (void)paste:(id)sender
{
  [super paste:sender];
  _textWasPasted = YES;
}

//- (void)setContentOffset:(CGPoint)contentOffset animated:(__unused BOOL)animated
//{
//  // Turning off scroll animation.
//  // This fixes the problem also known as "flaky scrolling".
//  [super setContentOffset:contentOffset animated:NO];
//}

#pragma mark - Layout

- (CGFloat)preferredMaxLayoutWidth
{
  // Returning size DOES contain `textContainerInset` (aka `padding`).
  return _preferredMaxLayoutWidth ?: self.placeholderSize.width;
}

- (CGSize)placeholderSize
{
  NSEdgeInsets padding = _paddingInsets;
  NSString *placeholder = self.placeholder ?: @"";
  CGSize placeholderSize = [placeholder sizeWithAttributes:@{NSFontAttributeName: self.font ?: defaultPlaceholderFont()}];
  placeholderSize = CGSizeMake(RCTCeilPixelValue(placeholderSize.width), RCTCeilPixelValue(placeholderSize.height));
  placeholderSize.width += padding.left + padding.right;
  placeholderSize.height += padding.top + padding.bottom;
  // Returning size DOES contain `textContainerInset` (aka `padding`; as `sizeThatFits:` does).
  return placeholderSize;
}

- (CGSize)contentSize
{
  CGSize contentSize = self.intrinsicContentSize;
  CGSize placeholderSize = self.placeholderSize;
  // When a text input is empty, it actually displays a placehoder.
  // So, we have to consider `placeholderSize` as a minimum `contentSize`.
  // Returning size DOES contain `textContainerInset` (aka `padding`).
  return CGSizeMake(
    MAX(contentSize.width, placeholderSize.width),
    MAX(contentSize.height, placeholderSize.height));
}

//- (void)layoutSubviews
//{
//  [super layoutSubviews];
//
//  CGRect textFrame = NSEdgeInsetsInsetRect(self.bounds, self.textContainerInset);
//  CGFloat placeholderHeight = [_placeholderView sizeThatFits:textFrame.size].height;
//  textFrame.size.height = MIN(placeholderHeight, textFrame.size.height);
//  _placeholderView.frame = textFrame;
//}

- (CGSize)intrinsicContentSize
{
  // Returning size DOES contain `textContainerInset` (aka `padding`).
  return [self sizeThatFits:CGSizeMake(self.preferredMaxLayoutWidth, CGFLOAT_MAX)];
}

- (CGSize)sizeThatFits:(CGSize)size
{
  // Returned fitting size depends on text size and placeholder size.
  [self.layoutManager ensureLayoutForTextContainer:self.textContainer];
  CGSize textSize = [self.layoutManager usedRectForTextContainer:self.textContainer].size;
  CGSize placeholderSize = self.placeholderSize;
  // Returning size DOES contain `textContainerInset` (aka `padding`).
  return CGSizeMake(MAX(textSize.width, placeholderSize.width), MAX(textSize.height, placeholderSize.height));
}


























#pragma mark - Placeholder

- (void)invalidatePlaceholderVisibility
{
  BOOL isVisible = _placeholder.length != 0 && self.attributedText.length == 0;
  _placeholderView.hidden = !isVisible;
}

#pragma mark - Padding

- (void)setPaddingInsets:(NSEdgeInsets)paddingInsets
{
  _paddingInsets = paddingInsets;
  self.textContainerInset = (NSSize){paddingInsets.right, paddingInsets.bottom};
}

- (NSPoint)textContainerOrigin
{
  return (NSPoint){
    _paddingInsets.left - _paddingInsets.right,
    _paddingInsets.top - _paddingInsets.bottom
  };
}

@end

@implementation NSTextView (EditingControl)

- (BOOL)endEditing:(BOOL)force
{
  if (self != self.window.firstResponder) {
    return YES;
  }
  if (force || [self.delegate textShouldEndEditing:self]) {
    [self.window makeFirstResponder:nil];
    return YES;
  }
  return NO;
}

@end
