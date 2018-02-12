//
//  MenuButtonType.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-11-30.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

import UIKit

enum MenuButtonType {
    case security
    case support
    case settings
    case convert
    case lock
    case buy
    case donate

    var title: String {
        switch self {
        case .security:
            return S.MenuButton.security
        case .support:
            return S.MenuButton.support
        case .settings:
            return S.MenuButton.settings
        case .convert:
            return S.MenuButton.convert
        case .lock:
            return S.MenuButton.lock
        case .buy:
            return S.MenuButton.buy
        case .donate:
            return S.MenuButton.donate
        }
    }

    var image: UIImage {
        switch self {
        case .security:
            return #imageLiteral(resourceName: "Shield")
        case .support:
            return #imageLiteral(resourceName: "FaqFill")
        case .settings:
            return #imageLiteral(resourceName: "Settings")
        case .convert:
            return #imageLiteral(resourceName: "Convert")
        case .lock:
            return #imageLiteral(resourceName: "Lock")
        case .buy:
            return #imageLiteral(resourceName: "BuyBitcoin")
        case .donate:
            return #imageLiteral(resourceName: "Donate")
        }
    }
}
