//
//  AccountHeaderView.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-11-16.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

import UIKit

private let largeFontSize: CGFloat = 26.0
private let mediumFontSize: CGFloat = 20.0
private let smallFontSize: CGFloat = 13.0
private let logoWidth: CGFloat = 0.22 //percentage of width

class AccountHeaderView : UIView, GradientDrawable, Subscriber {

    //MARK: - Public
    init(store: Store) {
        self.store = store
        self.isBchSwapped = store.state.isBchSwapped
        self.isBalanceHidden = store.state.isBalanceHidden
        self.isHideBalanceEnabled = store.state.isHideBalanceEnabled
        
        
        if self.isHideBalanceEnabled {
            if !self.isBalanceHidden {
                self.store.perform(action: BalanceHidden.toggle())
            }
        } else {
            if self.isBalanceHidden {
                self.store.perform(action: BalanceHidden.toggle())
            }
        }
        
        

        currencyTapView.isUserInteractionEnabled = true
        
        if let rate = store.state.currentRate {
            self.exchangeRate = rate
            let placeholderAmount = Amount(amount: 0, rate: rate, maxDigits: store.state.maxDigits)
            self.secondaryBalance = UpdatingLabel(formatter: placeholderAmount.localFormat)
            self.primaryBalance = UpdatingLabel(formatter: placeholderAmount.bchFormat)
        } else {
            self.secondaryBalance = UpdatingLabel(formatter: NumberFormatter())
            self.primaryBalance = UpdatingLabel(formatter: NumberFormatter())
        }
 
        super.init(frame: CGRect())
    }

    let search = UIButton(type: .system)

    //MARK: - Private
    private let name = UILabel(font: UIFont.boldSystemFont(ofSize: 17.0))
    private let manage = UIButton(type: .system)
    private let primaryBalance: UpdatingLabel
    private let secondaryBalance: UpdatingLabel
    private let currencyTapView = UILabel() //UIView()
    private let store: Store
    private let equals = UILabel(font: .customBody(size: smallFontSize), color: .whiteTint)
    private var regularConstraints: [NSLayoutConstraint] = []
    private var swappedConstraints: [NSLayoutConstraint] = []
    private var hasInitialized = false
    private let modeLabel: UILabel = {
        let label = UILabel()
        label.font = .customBody(size: 12.0)
        return label
    }()
    var hasSetup = false

    var isWatchOnly: Bool = false {
        didSet {
            if E.isTestnet || isWatchOnly {
                if E.isTestnet && isWatchOnly {
                    modeLabel.text = "(Testnet - Watch Only)"
                } else if E.isTestnet {
                    modeLabel.text = "(Testnet)"
                    //modeLabel.text = ""
                } else if isWatchOnly {
                    modeLabel.text = "(Watch Only)"
                }
                modeLabel.isHidden = false
            }
            if E.isScreenshots {
                modeLabel.isHidden = true
            }
        }
    }
    private var exchangeRate: Rate? {
        didSet { setBalances() }
    }
    private var logo: UIImageView = {
        let image = UIImageView(image: #imageLiteral(resourceName: "Logo"))
        image.contentMode = .scaleAspectFit
        return image
    }()
    private var balance: UInt64 = 0 {
        didSet { setBalances() }
    }
    private var isBchSwapped: Bool {
        didSet { setBalances() }
    }
    private var isHideBalanceEnabled: Bool {
        didSet {
            if self.isHideBalanceEnabled {
                if !self.isBalanceHidden {
                    self.store.perform(action: BalanceHidden.toggle())
                }
            } else {
                if self.isBalanceHidden {
                    self.store.perform(action: BalanceHidden.toggle())
                }
            }
        }
    }
    private var isBalanceHidden: Bool {
        didSet { balanceHiddenChangedAnimated() }
    }
    override func layoutSubviews() {
        guard !hasSetup else { return }
        setup()
        hasSetup = true
    }

    private func setup() {
        setData()
        addSubviews()
        addConstraints()
        addShadow()
        addSubscriptions()
    }

    private func setData() {
        name.textColor = .white

        manage.setTitle(S.AccountHeader.manageButtonName, for: .normal)
        manage.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
        manage.tintColor = .white
        manage.tap = {
            self.store.perform(action: RootModalActions.Present(modal: .manageWallet))
        }
        primaryBalance.textColor = .whiteTint
        primaryBalance.font = UIFont.customBody(size: largeFontSize)

        secondaryBalance.textColor = .whiteTint
        secondaryBalance.font = UIFont.customBody(size: largeFontSize)
        
        currencyTapView.textColor = .whiteTint
        currencyTapView.font = UIFont.customBody(size: mediumFontSize)

        search.setImage(#imageLiteral(resourceName: "SearchIcon"), for: .normal)
        search.tintColor = .white

        if E.isTestnet {
            name.textColor = .red
        }

        equals.text = S.AccountHeader.equals

        manage.isHidden = true
        name.isHidden = true
        modeLabel.isHidden = true
        
    }

    private func addSubviews() {
        addSubview(name)
        addSubview(manage)
        addSubview(primaryBalance)
        addSubview(secondaryBalance)
        addSubview(search)
        addSubview(equals)
        addSubview(currencyTapView)
        addSubview(logo)
        addSubview(modeLabel)
    }

    private func addConstraints() {
        name.constrain([
            name.constraint(.leading, toView: self, constant: C.padding[2]),
            name.constraint(.top, toView: self, constant: 30.0) ])
        if let manageTitleLabel = manage.titleLabel {
            manage.constrain([
                manage.constraint(.trailing, toView: self, constant: -C.padding[2]),
                manageTitleLabel.firstBaselineAnchor.constraint(equalTo: name.firstBaselineAnchor) ])
        }
        secondaryBalance.constrain([
            secondaryBalance.constraint(.firstBaseline, toView: primaryBalance, constant: 0.0) ])

        equals.translatesAutoresizingMaskIntoConstraints = false
        primaryBalance.translatesAutoresizingMaskIntoConstraints = false

        regularConstraints = [
            primaryBalance.firstBaselineAnchor.constraint(equalTo: bottomAnchor, constant: -C.padding[4]),
            primaryBalance.leadingAnchor.constraint(equalTo: leadingAnchor, constant: C.padding[2]),
            equals.firstBaselineAnchor.constraint(equalTo: primaryBalance.firstBaselineAnchor),
            equals.leadingAnchor.constraint(equalTo: primaryBalance.trailingAnchor, constant: C.padding[1]/2.0),
            secondaryBalance.leadingAnchor.constraint(equalTo: equals.trailingAnchor, constant: C.padding[1]/2.0)
        ]

        swappedConstraints = [
            secondaryBalance.firstBaselineAnchor.constraint(equalTo: bottomAnchor, constant: -C.padding[4]),
            secondaryBalance.leadingAnchor.constraint(equalTo: leadingAnchor, constant: C.padding[2]),
            equals.firstBaselineAnchor.constraint(equalTo: secondaryBalance.firstBaselineAnchor),
            equals.leadingAnchor.constraint(equalTo: secondaryBalance.trailingAnchor, constant: C.padding[1]/2.0),
            primaryBalance.leadingAnchor.constraint(equalTo: equals.trailingAnchor, constant: C.padding[1]/2.0)
        ]

        NSLayoutConstraint.activate(isBchSwapped ? self.swappedConstraints : self.regularConstraints)

        search.constrain([
            search.constraint(.trailing, toView: self, constant: -C.padding[2]),
            search.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -C.padding[4]),
            search.constraint(.width, constant: 44.0),
            search.constraint(.height, constant: 44.0) ])
        search.imageEdgeInsets = UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0)

        currencyTapView.constrain([
            currencyTapView.leadingAnchor.constraint(equalTo: name.leadingAnchor, constant: -C.padding[1]),
            currencyTapView.trailingAnchor.constraint(equalTo: manage.leadingAnchor, constant: C.padding[1]),
            currencyTapView.topAnchor.constraint(equalTo: primaryBalance.topAnchor, constant: -C.padding[1]),
            currencyTapView.bottomAnchor.constraint(equalTo: primaryBalance.bottomAnchor, constant: C.padding[1]) ])

        let gr = UITapGestureRecognizer(target: self, action: #selector(currencySwitchTapped))
        currencyTapView.addGestureRecognizer(gr)

        logo.constrain([
            logo.leadingAnchor.constraint(equalTo: leadingAnchor, constant: C.padding[2]),
            //logo.leftAnchor.constraint(equalTo: leftAnchor, constant: -10.0),
            logo.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -C.padding[10]),
            //logo.topAnchor.constraint(equalTo: topAnchor, constant: C.padding[2]),
            logo.heightAnchor.constraint(equalTo: logo.widthAnchor, multiplier: C.Sizes.logoAspectRatio),
            logo.widthAnchor.constraint(equalTo: widthAnchor, multiplier: logoWidth) ])
        modeLabel.constrain([
            modeLabel.leadingAnchor.constraint(equalTo: logo.trailingAnchor, constant: C.padding[1]/2.0),
            modeLabel.firstBaselineAnchor.constraint(equalTo: logo.bottomAnchor, constant: -2.0) ])
    }

    private func transform(forView: UIView) ->  CGAffineTransform {
        forView.transform = .identity //Must reset the view's transform before we calculate the next transform
        let scaleFactor: CGFloat = smallFontSize/largeFontSize
        let deltaX = forView.frame.width * (1-scaleFactor)
        let deltaY = forView.frame.height * (1-scaleFactor)
        let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        return scale.translatedBy(x: -deltaX, y: deltaY/2.0)
    }

    private func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 8.0
    }

    private func addSubscriptions() {
        store.lazySubscribe(self,
                        selector: { $0.isBchSwapped != $1.isBchSwapped },
                        callback: { self.isBchSwapped = $0.isBchSwapped })
        store.lazySubscribe(self,
                            selector: { $0.isHideBalanceEnabled != $1.isHideBalanceEnabled },
                            callback: { self.isHideBalanceEnabled = $0.isHideBalanceEnabled })
        store.lazySubscribe(self,
                            selector: { $0.isBalanceHidden != $1.isBalanceHidden },
                            callback: { self.isBalanceHidden = $0.isBalanceHidden })
        store.lazySubscribe(self,
                        selector: { $0.currentRate != $1.currentRate},
                        callback: {
                            if let rate = $0.currentRate {
                                let placeholderAmount = Amount(amount: 0, rate: rate, maxDigits: $0.maxDigits)
                                self.secondaryBalance.formatter = placeholderAmount.localFormat
                                self.primaryBalance.formatter = placeholderAmount.bchFormat
                            }
                            self.exchangeRate = $0.currentRate
                        })

        store.lazySubscribe(self,
                        selector: { $0.maxDigits != $1.maxDigits},
                        callback: {
                            if let rate = $0.currentRate {
                                let placeholderAmount = Amount(amount: 0, rate: rate, maxDigits: $0.maxDigits)
                                self.secondaryBalance.formatter = placeholderAmount.localFormat
                                self.primaryBalance.formatter = placeholderAmount.bchFormat
                                self.setBalances()
                            }
        })
        store.subscribe(self,
                        selector: { $0.walletState.name != $1.walletState.name },
                        callback: { self.name.text = $0.walletState.name })
        store.subscribe(self,
                        selector: {$0.walletState.balance != $1.walletState.balance },
                        callback: { state in
                            if let balance = state.walletState.balance {
                                self.balance = balance
                            } })
    }

    private func setBalances() {
        guard let rate = exchangeRate else { return }
        let amount = Amount(amount: balance, rate: rate, maxDigits: store.state.maxDigits)
        if !hasInitialized {
            let amount = Amount(amount: balance, rate: exchangeRate!, maxDigits: store.state.maxDigits)
            NSLayoutConstraint.deactivate(isBchSwapped ? self.regularConstraints : self.swappedConstraints)
            NSLayoutConstraint.activate(isBchSwapped ? self.swappedConstraints : self.regularConstraints)
            primaryBalance.setValue(amount.amountForBchFormat)
            secondaryBalance.setValue(amount.localAmount)
            if isBchSwapped {
                primaryBalance.transform = transform(forView: primaryBalance)
            } else {
                secondaryBalance.transform = transform(forView: secondaryBalance)
            }
            hasInitialized = true
            hideExtraViews()
        } else {
            if primaryBalance.isHidden {
                primaryBalance.isHidden = false
            }

            if secondaryBalance.isHidden {
                secondaryBalance.isHidden = false
            }

            primaryBalance.setValueAnimated(amount.amountForBchFormat, completion: { [weak self] in
                guard let myself = self else { return }
                if !myself.isBchSwapped {
                    myself.primaryBalance.transform = .identity
                } else {
                    myself.primaryBalance.transform = myself.transform(forView: myself.primaryBalance)
                }
                myself.hideExtraViews()
            })
            secondaryBalance.setValueAnimated(amount.localAmount, completion: { [weak self] in
                guard let myself = self else { return }
                if myself.isBchSwapped {
                    myself.secondaryBalance.transform = .identity
                } else {
                    myself.secondaryBalance.transform = myself.transform(forView: myself.secondaryBalance)
                }
                myself.hideExtraViews()
            })
        }
    }

    private func hideExtraViews() {
        var didHide = false
        if secondaryBalance.frame.maxX > search.frame.minX {
            secondaryBalance.isHidden = true
            didHide = true
        } else {
            secondaryBalance.isHidden = false
        }

        if primaryBalance.frame.maxX > search.frame.minX {
            primaryBalance.isHidden = true
            didHide = true
        } else {
            primaryBalance.isHidden = false
        }
        equals.isHidden = didHide
        
        //Now hide it all at the start if desired.
        balanceHiddenChanged()
    }

    override func draw(_ rect: CGRect) {
        drawGradient(rect)
    }
    
    private func balanceHiddenChangedAnimated() {
        if self.isBalanceHidden {
            UIView.animate(withDuration: 0.5, animations: {
                self.currencyTapView.text = S.AccountHeader.title
                self.primaryBalance.alpha = 0.0
                self.equals.alpha = 0.0
                self.secondaryBalance.alpha = 0.0
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.currencyTapView.text = ""
                self.primaryBalance.alpha = 1.0
                self.equals.alpha = 1.0
                self.secondaryBalance.alpha = 1.0
            })
        }
    }
    
    private func balanceHiddenChanged() {
        if self.isBalanceHidden {
            self.currencyTapView.text = S.AccountHeader.title
            self.primaryBalance.alpha = 0.0
            self.equals.alpha = 0.0
            self.secondaryBalance.alpha = 0.0
        } else {
            self.currencyTapView.text = ""
            self.primaryBalance.alpha = 1.0
            self.equals.alpha = 1.0
            self.secondaryBalance.alpha = 1.0
        }
    }

    @objc private func currencySwitchTapped() {
        layoutIfNeeded()
        
        //If balance not hidden
        if !self.isBalanceHidden {
            UIView.spring(0.7, animations: {
                self.primaryBalance.transform = self.primaryBalance.transform.isIdentity ? self.transform(forView: self.primaryBalance) : .identity
                self.secondaryBalance.transform = self.secondaryBalance.transform.isIdentity ? self.transform(forView: self.secondaryBalance) : .identity
                NSLayoutConstraint.deactivate(!self.isBchSwapped ? self.regularConstraints : self.swappedConstraints)
                NSLayoutConstraint.activate(!self.isBchSwapped ? self.swappedConstraints : self.regularConstraints)
                self.layoutIfNeeded()
            }) { _ in }
            self.store.perform(action: CurrencyChange.toggle())
        } else {
            self.store.perform(action: BalanceHidden.toggle())
        }
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
