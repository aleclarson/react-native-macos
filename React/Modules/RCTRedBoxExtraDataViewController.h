/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <AppKit/AppKit.h>

@protocol RCTRedBoxExtraDataActionDelegate <NSObject>
- (void)reload;
@end

@interface RCTRedBoxExtraDataViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, weak) id<RCTRedBoxExtraDataActionDelegate> actionDelegate;

- (void)addExtraData:(NSDictionary *)data forIdentifier:(NSString *)identifier;

@end
