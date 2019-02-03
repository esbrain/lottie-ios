//
//  LOTAnimationLayer.h
//  Lottie
//
//  Created by lvpengwei on 2/18/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import "UIKit/UIKit.h"

@protocol LOTAnimationLayer <NSObject>
- (CGSize)compSize;
- (void)displayWithProgress:(CGFloat)progress;
@end

@interface CALayer (LOTAnimationLayer)
+ (nonnull CALayer<LOTAnimationLayer> *)animationFromJSON:(nonnull NSDictionary *)animationJSON;
+ (nonnull CALayer<LOTAnimationLayer> *)animationFromJSON:(nonnull NSDictionary *)animationJSON loop:(BOOL)loop;
@end
