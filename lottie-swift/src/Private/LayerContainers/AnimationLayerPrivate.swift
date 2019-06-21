//
//  AnimationLayerPrivate.swift
//  Lottie_iOS
//
//  Created by lvpengwei on 2019/6/21.
//  Copyright © 2019 YurtvilleProds. All rights reserved.
//

import Foundation
import QuartzCore

private var AnimationKey = "AnimationKey"
extension AnimationContainer {
    var animation: Animation? {
        get {
            return objc_getAssociatedObject(self, &AnimationKey) as? Animation
        }
        set {
            objc_setAssociatedObject(self, &AnimationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    static func layer(animation: Animation, imageProvider: AnimationImageProvider? = nil) -> AnimationContainer {
        let layer = AnimationContainer(animation: animation, imageProvider: imageProvider ?? BundleImageProvider(bundle: Bundle.main, searchPath: nil))
        layer.animation = animation
        
        let fromStartFrame = animation.startFrame
        let toEndFrame = animation.endFrame
        let duration = Double(abs(toEndFrame - fromStartFrame)) / animation.framerate
        let anim = CABasicAnimation(keyPath: "currentFrame")
        anim.speed = 1
        anim.fromValue = fromStartFrame
        anim.toValue = toEndFrame
        anim.duration = duration
        anim.fillMode = CAMediaTimingFillMode.both
        anim.repeatCount = 1
        anim.autoreverses = false
        anim.isRemovedOnCompletion = false
        layer.add(anim, forKey: "anim")
        layer.shouldRasterize = false
        return layer
    }
    public override func compSize() -> CGSize {
        guard let animation = animation else { return .zero }
        return animation.size
    }
    public override func display(with procress: CGFloat) {
        guard let animation = animation else { return }
        currentFrame = animation.frameTime(forProgress: procress)
        forceDisplayUpdate()
    }
}
