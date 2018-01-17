//
//  UserDefaults+Additions.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-04-04.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import Foundation

private let defaults = UserDefaults.standard
private let isTouchIdEnabledKey = "istouchidenabled"
private let isTestnetEnabledKey = "istestnetenabled"
private let defaultCurrencyCodeKey = "defaultcurrency"
private let hasAquiredShareDataPermissionKey = "has_acquired_permission"
private let legacyWalletNeedsBackupKey = "WALLET_NEEDS_BACKUP"
private let writePaperPhraseDateKey = "writepaperphrasedatekey"
private let hasPromptedTouchIdKey = "haspromptedtouched"
private let isBchSwappedKey = "isBchSwappedKey"
private let maxDigitsKey = "SETTINGS_MAX_DIGITS"
private let pushTokenKey = "pushTokenKey"
private let currentRateKey = "currentRateKey"
private let customNodeIPKey = "customNodeIPKey"
private let customNodePortKey = "customNodePortKey"
private let hasPromptedShareDataKey = "hasPromptedShareDataKey"
private let hasShownWelcomeKey = "hasShownWelcomeKey"

extension UserDefaults {

    static var isTouchIdEnabled: Bool {
        get {
            guard defaults.object(forKey: isTouchIdEnabledKey) != nil else {
                return false
            }
            return defaults.bool(forKey: isTouchIdEnabledKey)
        }
        set { defaults.set(newValue, forKey: isTouchIdEnabledKey) }
    }
    
    static var isTestnetEnabled: Bool {
        get {
            guard defaults.object(forKey: isTestnetEnabledKey) != nil else {
                return false
            }
            return defaults.bool(forKey: isTestnetEnabledKey)
        }
        set { defaults.set(newValue, forKey: isTestnetEnabledKey) }
    }

    static var defaultCurrencyCode: String {
        get {
            guard defaults.object(forKey: defaultCurrencyCodeKey) != nil else {
                return Locale.current.currencyCode ?? "USD"
            }
            return defaults.string(forKey: defaultCurrencyCodeKey)!
        }
        set { defaults.set(newValue, forKey: defaultCurrencyCodeKey) }
    }

    static var hasAquiredShareDataPermission: Bool {
        get { return defaults.bool(forKey: hasAquiredShareDataPermissionKey) }
        set { defaults.set(newValue, forKey: hasAquiredShareDataPermissionKey) }
    }

    static var isBchSwapped: Bool {
        get {
            //Default to $.  Re-evaluate in a few decades maybe...
            guard defaults.object(forKey: isBchSwappedKey) != nil else {
                return true
            }
            return defaults.bool(forKey: isBchSwappedKey)
        }
        set { defaults.set(newValue, forKey: isBchSwappedKey) }
    }

    //
    // 2 - bits
    // 5 - mBCH
    // 8 - BCH
    //
    static var maxDigits: Int {
        get {
            guard defaults.object(forKey: maxDigitsKey) != nil else {
                return 2
            }
            let maxDigits = defaults.integer(forKey: maxDigitsKey)
            if maxDigits == 5 {
                return 8 //Convert mBCH to BCH
            } else {
                return maxDigits
            }
        }
        set { defaults.set(newValue, forKey: maxDigitsKey) }
    }

    static var pushToken: Data? {
        get {
            guard defaults.object(forKey: pushTokenKey) != nil else {
                return nil
            }
            return defaults.data(forKey: pushTokenKey)
        }
        set { defaults.set(newValue, forKey: pushTokenKey) }
    }

    static var currentRate: Rate? {
        get {
            guard let data = defaults.object(forKey: currentRateKey) as? [String: Any] else {
                return nil
            }
            return Rate(data: data)
        }
    }

    static var currentRateData: [String: Any]? {
        get {
            guard let data = defaults.object(forKey: currentRateKey) as? [String: Any] else {
                return nil
            }
            return data
        }
        set { defaults.set(newValue, forKey: currentRateKey) }
    }

    static var customNodeIP: Int? {
        get {
            guard defaults.object(forKey: customNodeIPKey) != nil else { return nil }
            return defaults.integer(forKey: customNodeIPKey)
        }
        set { defaults.set(newValue, forKey: customNodeIPKey) }
    }

    static var customNodePort: Int? {
        get {
            guard defaults.object(forKey: customNodePortKey) != nil else { return nil }
            return defaults.integer(forKey: customNodePortKey)
        }
        set { defaults.set(newValue, forKey: customNodePortKey) }
    }

    static var hasPromptedShareData: Bool {
        get { return defaults.bool(forKey: hasPromptedTouchIdKey) }
        set { defaults.set(newValue, forKey: hasPromptedTouchIdKey) }
    }

    static var hasShownWelcome: Bool {
        get { return defaults.bool(forKey: hasShownWelcomeKey) }
        set { defaults.set(newValue, forKey: hasShownWelcomeKey) }
    }
}

//MARK: - Wallet Requires Backup
extension UserDefaults {
    static var legacyWalletNeedsBackup: Bool? {
        guard defaults.object(forKey: legacyWalletNeedsBackupKey) != nil else {
            return nil
        }
        return defaults.bool(forKey: legacyWalletNeedsBackupKey)
    }

    static func removeLegacyWalletNeedsBackupKey() {
        defaults.removeObject(forKey: legacyWalletNeedsBackupKey)
    }

    static var writePaperPhraseDate: Date? {
        get { return defaults.object(forKey: writePaperPhraseDateKey) as! Date? }
        set { defaults.set(newValue, forKey: writePaperPhraseDateKey) }
    }

    static var walletRequiresBackup: Bool {
        if UserDefaults.writePaperPhraseDate != nil {
            return false
        }
        if let legacyWalletNeedsBackup = UserDefaults.legacyWalletNeedsBackup, legacyWalletNeedsBackup == true {
            return true
        }
        if UserDefaults.writePaperPhraseDate == nil {
            return true
        }
        return false
    }
}

//MARK: - Prompts
extension UserDefaults {
    static var hasPromptedTouchId: Bool {
        get { return defaults.bool(forKey: hasPromptedTouchIdKey) }
        set { defaults.set(newValue, forKey: hasPromptedTouchIdKey) }
    }
}
