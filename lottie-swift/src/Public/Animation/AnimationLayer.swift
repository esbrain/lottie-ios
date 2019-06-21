//
//  AnimationLayer.swift
//  Lottie_iOS
//
//  Created by lvpengwei on 2019/6/21.
//  Copyright © 2019 YurtvilleProds. All rights reserved.
//

import Foundation
import QuartzCore

public protocol AnimationLayer {
    func compSize() -> CGSize
    func display(with procress: CGFloat)
}
extension CALayer: AnimationLayer {
    public static func animation(withName name: String) -> CALayer {
        return AnimationContainer.layer(animation: Animation.named(name)!, imageProvider: nil)
    }
    public static func animation(withPath path: String) -> CALayer {
        return AnimationContainer.layer(animation: Animation.filepath(path)!, imageProvider: nil)
    }
    @objc public func compSize() -> CGSize {
        return .zero
    }
    @objc public func display(with procress: CGFloat) { }
}
