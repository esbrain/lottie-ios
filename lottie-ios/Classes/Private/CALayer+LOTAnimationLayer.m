//
//  LOTAnimationLayer.m
//  Lottie
//
//  Created by lvpengwei on 2/18/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import "CALayer+LOTAnimationLayer.h"
#import "LOTPlatformCompat.h"
#import "LOTModels.h"
#import "LOTHelpers.h"
#import "LOTAnimationCache.h"
#import "LOTCompositionContainer.h"
#import <objc/runtime.h>

static NSString *sceneModelKey = @"sceneModelKey";
@interface LOTCompositionContainer (LOTAnimationLayer) <LOTAnimationLayer>
@property (nonatomic, strong, nullable) LOTComposition *sceneModel;
@end
@implementation LOTCompositionContainer (LOTAnimationLayer)
- (void)setSceneModel:(LOTComposition *)sceneModel {
    objc_setAssociatedObject(self, &sceneModelKey, sceneModel, OBJC_ASSOCIATION_RETAIN);
}
- (LOTComposition *)sceneModel {
    return objc_getAssociatedObject(self, &sceneModelKey);
}
- (CGSize)compSize {
    return self.sceneModel.compBounds.size;
}
- (instancetype)initWithModel:(LOTComposition *)model inBundle:(NSBundle *)bundle loop:(BOOL)loop {
    self = [self initWithModel:nil inLayerGroup:nil withLayerGroup:model.layerGroup withAssestGroup:model.assetGroup];
    if (self) {
        [self _setupWithSceneModel:model loop:loop];
    }
    return self;
}
- (void)displayWithProgress:(CGFloat)progress {
    [self displayWithFrame:[self _frameForProgress:progress]];
}
- (NSNumber *)_frameForProgress:(CGFloat)progress {
    if (!self.sceneModel) {
        return @0;
    }
    return @(((self.sceneModel.endFrame.floatValue - self.sceneModel.startFrame.floatValue) * progress) + self.sceneModel.startFrame.floatValue);
}
- (void)_setupWithSceneModel:(LOTComposition *)model loop:(BOOL)loop {
    if (self.sceneModel) {
        [self removeFromSuperlayer];
    }
    
    self.sceneModel = model;
    self.bounds = self.sceneModel.compBounds;
    self.viewportBounds = self.sceneModel.compBounds;
    
    NSNumber *fromStartFrame = self.sceneModel.startFrame;
    NSNumber *toEndFrame = self.sceneModel.endFrame;
    NSTimeInterval duration = (ABS(toEndFrame.floatValue - fromStartFrame.floatValue) / self.sceneModel.framerate.floatValue);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"currentFrame"];
    animation.speed = 1;
    animation.fromValue = fromStartFrame;
    animation.toValue = toEndFrame;
    animation.duration = duration;
    animation.fillMode = kCAFillModeBoth;
    animation.repeatCount = loop ? HUGE_VALF : 1;
    animation.autoreverses = NO;
    animation.removedOnCompletion = NO;
    [self addAnimation:animation forKey:@"anim"];
    self.shouldRasterize = NO;
}
@end

@implementation CALayer (LOTAnimationLayer)
+ (nonnull instancetype)animationFromJSON:(nonnull NSDictionary *)animationJSON {
    return [self animationFromJSON:animationJSON inBundle:[NSBundle mainBundle] loop:NO];
}
+ (nonnull instancetype)animationFromJSON:(NSDictionary *)animationJSON loop:(BOOL)loop {
    return [self animationFromJSON:animationJSON inBundle:[NSBundle mainBundle] loop:loop];
}
+ (nonnull instancetype)animationFromJSON:(nullable NSDictionary *)animationJSON inBundle:(nullable NSBundle *)bundle loop:(BOOL)loop {
    LOTComposition *comp = [LOTComposition animationFromJSON:animationJSON inBundle:bundle];
    return [[LOTCompositionContainer alloc] initWithModel:comp inBundle:bundle loop:loop];
}
@end
