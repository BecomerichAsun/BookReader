//
//  LoadingAnimationView.swift
//  GoodBookRead
//
//  Created by Asun on 2019/8/2.
//  Copyright © 2019 Asun. All rights reserved.
//

import Foundation
import NVActivityIndicatorView

let KeyWindow: UIWindow = UIApplication.shared.keyWindow ?? UIWindow()

struct LoadingAnimationView {
    
    static let animationView = NVActivityIndicatorView(frame: CGRect.zero, type: NVActivityIndicatorType.ballClipRotate, color: UIColor.hex(hexString: "0F0B12"), padding: nil)
    
    static func show() {
        
        for view in KeyWindow.subviews {
            if view.isKind(of: NVActivityIndicatorView.self) {
                view.removeFromSuperview()
                break
            }
        }
        
        KeyWindow.addSubview(animationView)
        animationView.snp.makeConstraints{
            $0.center.equalToSuperview()
            $0.size.equalTo(CGSize(width: 60, height: 60))
        }
        
        animationView.startAnimating()
    }
    
    static func dismiss() {
       animationView.stopAnimating()
       KeyWindow.removeFromSuperview()
    }
    
}
