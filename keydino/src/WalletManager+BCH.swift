//
//  WalletManager+BCH.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-08-04.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import Foundation
import BRCore

let bCHForkBlockHeight: UInt32 = E.isTestnet ? 1203998 : 478559 //Testnet is just a guess
private let minFeePerKb: UInt64 = 1000 //((1000*1000 + 190)/191)

class BadListener : BRWalletListener {
    func balanceChanged(_ balance: UInt64) {}
    func txAdded(_ tx: BRTxRef) {}
    func txUpdated(_ txHashes: [UInt256], blockHeight: UInt32, timestamp: UInt32) {}
    func txDeleted(_ txHash: UInt256, notifyUser: Bool, recommendRescan: Bool) {}
}

extension WalletManager {

    var bCHBalance: UInt64 {
        return bCHWallet?.maxOutputAmount ?? 0
    }

    func sweepBCH(toAddress: String, pin: String, callback: @escaping (String?) -> Void) {
        return autoreleasepool {
            let genericError = S.BCH.genericError
            guard let bCHWallet = bCHWallet else { return callback(genericError) }
            bCHWallet.feePerKb = minFeePerKb
            let maxOutputAmount = bCHWallet.maxOutputAmount
            guard let tx = bCHWallet.createTransaction(forAmount: maxOutputAmount, toAddress: toAddress) else { return callback(genericError)}
            defer { BRTransactionFree(tx) }
            guard signTransaction(tx, forkId: 0x40, pin: pin) else { return callback(genericError) }
            let txHash = tx.txHash.description
            guard var bytes = tx.bytes else { return callback(genericError)}
            apiClient?.publishBCHTransaction(Data(bytes: &bytes, count: bytes.count), callback: { errorMessage in
                if errorMessage == nil {
                    UserDefaults.standard.set(txHash, forKey: "bCHTxHashKey")
                }
                callback(errorMessage)
            })
        }
    }

}
