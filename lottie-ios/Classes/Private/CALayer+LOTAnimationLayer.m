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
@interface LOTCompositionContainer (LOTAnimationLayer)
@property (nonatomic, strong, nullable) LOTComposition *sceneModel;
@end
@implementation LOTCompositionContainer (LOTAnimationLayer)
- (void)setSceneModel:(LOTComposition *)sceneModel {
    objc_setAssociatedObject(self, &sceneModelKey, sceneModel, OBJC_ASSOCIATION_RETAIN);
}
- (LOTComposition *)sceneModel {
    return objc_getAssociatedObject(self, &sceneModelKey);
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
- (void)layoutSublayers {
    [super layoutSublayers];
    [self _layout];
}
- (void)_layout {
    CATransform3D xform;
    
    CGFloat compAspect = self.sceneModel.compBounds.size.width / self.sceneModel.compBounds.size.height;
    CGFloat viewAspect = self.superlayer.bounds.size.width / self.superlayer.bounds.size.height;
    BOOL scaleWidth = compAspect > viewAspect;
    CGFloat dominantDimension = scaleWidth ? self.superlayer.bounds.size.width : self.superlayer.bounds.size.height;
    CGFloat compDimension = scaleWidth ? self.sceneModel.compBounds.size.width : self.sceneModel.compBounds.size.height;
    CGFloat scale = dominantDimension / compDimension;
    xform = CATransform3DMakeScale(scale, scale, 1);
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.bounds = self.sceneModel.compBounds;
    self.transform = xform;
    self.viewportBounds = self.sceneModel.compBounds;
    [CATransaction commit];
}
@end

@implementation CALayer (LOTAnimationLayer)
+ (nonnull instancetype)animationFromJSON:(nonnull NSDictionary *)animationJSON {
    return [self animationFromJSON:animationJSON inBundle:[NSBundle mainBundle] loop:NO];
}
+ (instancetype)animationFromJSON:(NSDictionary *)animationJSON loop:(BOOL)loop {
    return [self animationFromJSON:animationJSON inBundle:[NSBundle mainBundle] loop:loop];
}
+ (nonnull instancetype)animationFromJSON:(nullable NSDictionary *)animationJSON inBundle:(nullable NSBundle *)bundle loop:(BOOL)loop {
    LOTComposition *comp = [LOTComposition animationFromJSON:animationJSON inBundle:bundle];
    return [[LOTCompositionContainer alloc] initWithModel:comp inBundle:bundle loop:loop];
}
- (void)displayWithProgress:(CGFloat)progress { }
@end
