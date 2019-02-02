//
//  LOTAnimationLayer.h
//  Lottie
//
//  Created by lvpengwei on 2/18/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import "UIKit/UIKit.h"

@interface CALayer (LOTAnimationLayer)
+ (nonnull instancetype)animationFromJSON:(nonnull NSDictionary *)animationJSON;
+ (nonnull instancetype)animationFromJSON:(nonnull NSDictionary *)animationJSON loop:(BOOL)loop;
- (void)displayWithProgress:(CGFloat)progress;
@end
