/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RCTScrollViewManager.h"

#import "RCTBridge.h"
#import "RCTScrollView.h"
#import "RCTShadowView.h"
#import "RCTUIManager.h"

@interface RCTNativeScrollView (Private)

- (NSArray *)calculateChildFramesData;

@end


@implementation RCTConvert (NSScrollView)

//RCT_ENUM_CONVERTER(UIScrollViewKeyboardDismissMode, (@{
//  @"none": @(UIScrollViewKeyboardDismissModeNone),
//  @"on-drag": @(UIScrollViewKeyboardDismissModeOnDrag),
//  @"interactive": @(UIScrollViewKeyboardDismissModeInteractive),
//  // Backwards compatibility
//  @"onDrag": @(UIScrollViewKeyboardDismissModeOnDrag),
//}), UIScrollViewKeyboardDismissModeNone, integerValue)
//
//RCT_ENUM_CONVERTER(UIScrollViewIndicatorStyle, (@{
//  @"default": @(UIScrollViewIndicatorStyleDefault),
//  @"black": @(UIScrollViewIndicatorStyleBlack),
//  @"white": @(UIScrollViewIndicatorStyleWhite),
//}), UIScrollViewIndicatorStyleDefault, integerValue)

#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000 /* __IPHONE_11_0 */
RCT_ENUM_CONVERTER(UIScrollViewContentInsetAdjustmentBehavior, (@{
  @"automatic": @(UIScrollViewContentInsetAdjustmentAutomatic),
  @"scrollableAxes": @(UIScrollViewContentInsetAdjustmentScrollableAxes),
  @"never": @(UIScrollViewContentInsetAdjustmentNever),
  @"always": @(UIScrollViewContentInsetAdjustmentAlways),
}), UIScrollViewContentInsetAdjustmentNever, integerValue)
#endif

@end

@implementation RCTNativeScrollViewManager

RCT_EXPORT_MODULE()

- (NSView *)view
{
  return [[RCTNativeScrollView alloc] initWithEventDispatcher:self.bridge.eventDispatcher];
}

RCT_EXPORT_VIEW_PROPERTY(autoScrollToBottom, BOOL)
RCT_EXPORT_VIEW_PROPERTY(alwaysBounceHorizontal, BOOL)
RCT_EXPORT_VIEW_PROPERTY(alwaysBounceVertical, BOOL)
RCT_EXPORT_VIEW_PROPERTY(bounces, BOOL)
RCT_EXPORT_VIEW_PROPERTY(bouncesZoom, BOOL)
RCT_EXPORT_VIEW_PROPERTY(canCancelContentTouches, BOOL)
RCT_EXPORT_VIEW_PROPERTY(centerContent, BOOL)
RCT_EXPORT_VIEW_PROPERTY(automaticallyAdjustContentInsets, BOOL)
RCT_EXPORT_VIEW_PROPERTY(decelerationRate, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(directionalLockEnabled, BOOL)
// RCT_EXPORT_VIEW_PROPERTY(indicatorStyle, UIScrollViewIndicatorStyle)

RCT_EXPORT_VIEW_PROPERTY(maximumZoomScale, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(minimumZoomScale, CGFloat)
// RCT_EXPORT_VIEW_PROPERTY(scrollEnabled, BOOL)

#if !TARGET_OS_TV
RCT_EXPORT_VIEW_PROPERTY(pagingEnabled, BOOL)
RCT_REMAP_VIEW_PROPERTY(pinchGestureEnabled, scrollView.pinchGestureEnabled, BOOL)
// RCT_EXPORT_VIEW_PROPERTY(scrollsToTop, BOOL)
#endif

RCT_REMAP_VIEW_PROPERTY(showsHorizontalScrollIndicator, hasHorizontalScroller, BOOL)
RCT_REMAP_VIEW_PROPERTY(showsVerticalScrollIndicator, hasVerticalScroller, BOOL)
RCT_EXPORT_VIEW_PROPERTY(scrollEventThrottle, NSTimeInterval)
RCT_EXPORT_VIEW_PROPERTY(zoomScale, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(contentInset, UIEdgeInsets)
RCT_EXPORT_VIEW_PROPERTY(scrollIndicatorInsets, UIEdgeInsets)
RCT_EXPORT_VIEW_PROPERTY(snapToInterval, int)
RCT_EXPORT_VIEW_PROPERTY(snapToAlignment, NSString)
RCT_REMAP_VIEW_PROPERTY(contentOffset, scrollView.contentOffset, CGPoint)
// RCT_EXPORT_VIEW_PROPERTY(onScrollBeginDrag, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onScroll, RCTDirectEventBlock)

RCT_EXPORT_VIEW_PROPERTY(onScrollEndDrag, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onMomentumScrollBegin, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onMomentumScrollEnd, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(DEPRECATED_sendUpdatedChildFrames, BOOL)
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000 /* __IPHONE_11_0 */
RCT_EXPORT_VIEW_PROPERTY(contentInsetAdjustmentBehavior, UIScrollViewContentInsetAdjustmentBehavior)
#endif

// overflow is used both in css-layout as well as by react-native. In css-layout
// we always want to treat overflow as scroll but depending on what the overflow
// is set to from js we want to clip drawing or not. This piece of code ensures
// that css-layout is always treating the contents of a scroll container as
// overflow: 'scroll'.
RCT_CUSTOM_SHADOW_PROPERTY(overflow, YGOverflow, RCTShadowView) {
#pragma unused (json)
  view.overflow = YGOverflowScroll;
}

RCT_EXPORT_METHOD(getContentSize:(nonnull NSNumber *)reactTag
                  callback:(RCTResponseSenderBlock)callback)
{
  [self.bridge.uiManager addUIBlock:
   ^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RCTNativeScrollView *> *viewRegistry) {

     RCTNativeScrollView *view = viewRegistry[reactTag];
     if (!view) {
       RCTLogError(@"Cannot find RCTNativeScrollView with tag #%@", reactTag);
       return;
     }

     CGSize size = view.contentSize;
     callback(@[@{
                  @"width" : @(size.width),
                  @"height" : @(size.height)
                  }]);
   }];
}

RCT_EXPORT_METHOD(calculateChildFrames:(nonnull NSNumber *)reactTag
                  callback:(RCTResponseSenderBlock)callback)
{
  [self.bridge.uiManager addUIBlock:
   ^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RCTNativeScrollView *> *viewRegistry) {

     RCTNativeScrollView *view = viewRegistry[reactTag];
     if (!view || ![view isKindOfClass:[RCTNativeScrollView class]]) {
       RCTLogError(@"Cannot find RCTNativeScrollView with tag #%@", reactTag);
       return;
     }

     NSArray<NSDictionary *> *childFrames = [view calculateChildFramesData];
     if (childFrames) {
       callback(@[childFrames]);
     }
   }];
}

RCT_EXPORT_METHOD(scrollTo:(nonnull NSNumber *)reactTag
                  offsetX:(CGFloat)x
                  offsetY:(CGFloat)y
                  animated:(BOOL)animated)
{
  [self.bridge.uiManager addUIBlock:
   ^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RCTNativeScrollView *> *viewRegistry){
     RCTNativeScrollView *view = viewRegistry[reactTag];
       if ([view conformsToProtocol:@protocol(RCTScrollableProtocol)]) {
           [(id<RCTScrollableProtocol>)view scrollToOffset:(CGPoint){x, y} animated:animated];
       } else {
           RCTLogError(@"tried to scrollTo: on non-RCTScrollableProtocol view %@ "
                       "with tag #%@", view, reactTag);
       }
   }];
}


RCT_EXPORT_METHOD(flashScrollIndicators:(nonnull NSNumber *)reactTag)
{
  [self.bridge.uiManager addUIBlock:
   ^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RCTNativeScrollView *> *viewRegistry){

     RCTNativeScrollView *view = viewRegistry[reactTag];
     if (!view || ![view isKindOfClass:[RCTNativeScrollView class]]) {
       RCTLogError(@"Cannot find RCTScrollView with tag #%@", reactTag);
       return;
     }

    // [view.scrollView flashScrollIndicators];
   }];
}

@end
