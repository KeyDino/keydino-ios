//
//  MenuViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-11-24.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

// File Description:
// - ViewController for menu

import UIKit

class MenuViewController : UIViewController, Trackable {

    //MARK: - Public
    var didTapSecurity: (() -> Void)?
    var didTapSupport: (() -> Void)?
    var didTapSettings: (() -> Void)?
    var didTapConvert: (() -> Void)?
    var didTapLock: (() -> Void)?
    var didTapBuy: (() -> Void)?
    var didTapDonate: (() -> Void)?

    //MARK: - Private
    fileprivate let buttonHeight: CGFloat = 72.0
    fileprivate let buttons: [MenuButton] = {
        let types: [MenuButtonType] = [.security, .support, .settings, .convert, .lock]//Temproarily removing buy and donate [.security, .support, .settings, .convert, .lock, .buy, .donate]
        return types.flatMap {
            //if $0 == .buy && !BRAPIClient.featureEnabled(.buyBitcoin) {
            //    return nil
            //}
            return MenuButton(type: $0)
        }
    }()
    fileprivate let bottomPadding: CGFloat = 32.0

    override func viewDidLoad() {

        var previousButton: UIView?
        buttons.forEach { button in
            button.addTarget(self, action: #selector(MenuViewController.didTapButton(button:)), for: .touchUpInside)
            view.addSubview(button)
            var topConstraint: NSLayoutConstraint?
            if let viewAbove = previousButton {
                topConstraint = button.constraint(toBottom: viewAbove, constant: 0.0)
            } else {
                topConstraint = button.constraint(.top, toView: view, constant: 0.0)
            }
            button.constrain([
                topConstraint,
                button.constraint(.leading, toView: view, constant: 0.0),
                button.constraint(.trailing, toView: view, constant: 0.0),
                button.constraint(.height, constant: buttonHeight) ])
            previousButton = button
        }

        previousButton?.constrain([
            previousButton?.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -C.padding[2]) ])

        view.backgroundColor = .white

        //if BRAPIClient.featureEnabled(.buyBitcoin) {
            saveEvent("menu.buyBitcoinCashIsVisible")
        //}
    }

    @objc private func didTapButton(button: MenuButton) {
        switch button.type {
        case .security:
            didTapSecurity?()
        case .support:
            didTapSupport?()
        case .settings:
            didTapSettings?()
        case .convert:
            didTapConvert?()
        case .lock:
            didTapLock?()
        case .buy:
            saveEvent("menu.didTapBuyBitcoinCash")
            didTapBuy?()
        case .donate:
            didTapDonate?()
        }
    }
}

extension MenuViewController : ModalDisplayable {
    var faqArticleId: String? {
        return nil
    }

    var modalTitle: String {
        return S.MenuViewController.modalTitle
    }
}
