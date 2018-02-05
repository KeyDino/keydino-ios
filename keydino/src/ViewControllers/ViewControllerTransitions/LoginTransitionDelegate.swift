//
//  LoginTransitionDelegate.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-02-07.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

// File Description:
// - Handles animation of modal transition of login

import UIKit

class LoginTransitionDelegate : NSObject, UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissLoginAnimator()
    }
}
