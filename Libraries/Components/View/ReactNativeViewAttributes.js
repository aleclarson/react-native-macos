/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * @providesModule ReactNativeViewAttributes
 * @flow
 */
'use strict';

var ReactNativeStyleAttributes = require('ReactNativeStyleAttributes');

var ReactNativeViewAttributes = {};

ReactNativeViewAttributes.UIView = {
  pointerEvents: true,
  accessible: true,
  accessibilityActions: true,
  accessibilityLabel: true,
  accessibilityComponentType: true,
  accessibilityLiveRegion: true,
  accessibilityTraits: true,
  importantForAccessibility: true,
  nativeID: true,
  testID: true,
  testRole: true,
  renderToHardwareTextureAndroid: true,
  shouldRasterizeIOS: true,
  onLayout: true,
  onMouseMove: true,
  onMouseEnter: true,
  onMouseLeave: true,
  onMouseOver: true,
  onMouseOut: true,
  onContextMenu: true,
  onAccessibilityTap: true,
  onMagicTap: true,
  blendMode: true,
  collapsable: true,
  needsOffscreenAlphaCompositing: true,
  style: ReactNativeStyleAttributes,
  toolTip: true,
};

ReactNativeViewAttributes.RCTView = {
  ...ReactNativeViewAttributes.UIView,

  // This is a special performance property exposed by RCTView and useful for
  // scrolling content when there are many subviews, most of which are offscreen.
  // For this property to be effective, it must be applied to a view that contains
  // many subviews that extend outside its bound. The subviews must also have
  // overflow: hidden, as should the containing view (or one of its superviews).
  removeClippedSubviews: true,
};

module.exports = ReactNativeViewAttributes;
