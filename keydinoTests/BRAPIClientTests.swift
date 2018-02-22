//
//  BRAPIClientTests.swift
//  breadwallet
//
//  Created by Samuel Sutch on 12/7/16.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

import XCTest
@testable import keydino
import BRCore

class FakeAuthenticator: WalletAuthenticator {
    let secret: UInt256
    let key: BRKey
    var userAccount: [AnyHashable: Any]? = nil
    
    init() {
        var keyData = Data(count: 32)
        let result = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, keyData.count, $0)
        }
        if result != errSecSuccess {
            fatalError("couldnt generate random data for key")
        }
        print("base58 encoded secret key data \(keyData.base58)")
        secret = keyData.uInt256
        key = withUnsafePointer(to: &secret, { (secPtr: UnsafePointer<UInt256>) in
            var k = BRKey()
            k.compressed = 1
            BRKeySetSecret(&k, secPtr, 0)
            return k
        })
    }
    
    var noWallet: Bool { return false }
    
    var apiAuthKey: String? {
        var k = key
        k.compressed = 1 
        let pkLen = BRKeyPrivKey(&k, nil, 0)
        var pkData = Data(count: pkLen)
        BRKeyPrivKey(&k, pkData.withUnsafeMutableBytes({ $0 }), pkLen)
        return String(data: pkData, encoding: .utf8)
    }
}

// This test will test against the live API at api.keydino.com
class BRAPIClientTests: XCTestCase {
    var authenticator: WalletAuthenticator!
    var client: BRAPIClient!
    
    override func setUp() {
        super.setUp()
        authenticator = FakeAuthenticator() // each test will get its own account
        client = BRAPIClient(authenticator: authenticator)
    }
    
    override func tearDown() {
        super.tearDown()
        authenticator = nil
        client = nil
    }
    
    func testPublicKeyEncoding() {
        let pubKey1 = client.authKey!.publicKey.base58
        let b = pubKey1.base58DecodedData()
        let b2 = b.base58
        XCTAssertEqual(pubKey1, b2) // sanity check on our base58 functions
        let key = client.authKey!.publicKey.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) -> BRKey in
            var k = BRKey()
            BRKeySetPubKey(&k, ptr, client.authKey!.publicKey.count)
            return k
        }
        XCTAssertEqual(pubKey1, key.publicKey.base58) // the key decoded from our encoded key is the same
    }
    
    func testCashAddrPublicKeyEncoding() {
        
        var base32Test = ["1BpEi6DfDAUFd7GtittLSdBeYJvcoaVggu", "1KXrWXciRDZUpQwQmuM1DbwsKDLYAYsVLR", "16w1D5WRVKJuZUsSRzdLp9w3YGcgoxDXb", "3CWFddi6m4ndiGyKqzYvsFYagqDLPVMTzC", "3LDsS579y7sruadqu11beEJoTjdFiFCdX4", "31nwvkZwyPdgzjBJZXfDmSWsC4ZLKpYyUw"]

        for i in 0..<6 {
            let pubAddrHex = base32Test[i].base58CheckDecodedData() //Computes double sha and compares checksum, returns data stripped of checksum but with prefix
            //var trimmedPubAddrHex = pubAddrHex.subdata(in: 1..<21)
            let encodedTest = pubAddrHex.base32
            print(base32Test[i], encodedTest)
            /*
 var versionByte = 0x00
            if (UInt8(bigEndian: pubAddrHex.withUnsafeBytes { $0.pointee }) == 0x05) {
                versionByte = 0x05
            }
            let checksumBytes = 0x00000000
            var modifiedPubAddrHex1 = Data(count: 26)
            modifiedPubAddrHex1.replaceSubrange(1..<20, with: trimmedPubAddrHex)
            let pubAddr32 = modifiedPubAddrHex1.base32
            print(base32Test[i], pubAddr32)
             */
        }
        
        //Legacy    CashAddr
        //1BpEi6DfDAUFd7GtittLSdBeYJvcoaVggu    bitcoincash:qpm2qsznhks23z7629mms6s4cwef74vcwvy22gdx6a
        //1KXrWXciRDZUpQwQmuM1DbwsKDLYAYsVLR    bitcoincash:qr95sy3j9xwd2ap32xkykttr4cvcu7as4y0qverfuy
        //16w1D5WRVKJuZUsSRzdLp9w3YGcgoxDXb     bitcoincash:qqq3728yw0y47sqn6l2na30mcw6zm78dzqre909m2r
        //3CWFddi6m4ndiGyKqzYvsFYagqDLPVMTzC    bitcoincash:ppm2qsznhks23z7629mms6s4cwef74vcwvn0h829pq
        //3LDsS579y7sruadqu11beEJoTjdFiFCdX4    bitcoincash:pr95sy3j9xwd2ap32xkykttr4cvcu7as4yc93ky28e
        //31nwvkZwyPdgzjBJZXfDmSWsC4ZLKpYyUw    bitcoincash:pqq3728yw0y47sqn6l2na30mcw6zm78dzq5ucqzc37
        
        //Returning
        //1BpEi6DfDAUFd7GtittLSdBeYJvcoaVggu qpm2qsznhks23z7629mms6s4cwef74vcwv//qqqqqq
        //1KXrWXciRDZUpQwQmuM1DbwsKDLYAYsVLR qr95sy3j9xwd2ap32xkykttr4cvcu7as4y//qqqqqq
        //16w1D5WRVKJuZUsSRzdLp9w3YGcgoxDXb  q3728yw0y47sqn6l2na30mcw6zm78dzqqqqqqq
        //3CWFddi6m4ndiGyKqzYvsFYagqDLPVMTzC 4m2qsznhks23z7629mms6s4cwef74vcwvqqqqqq
        //3LDsS579y7sruadqu11beEJoTjdFiFCdX4 h95sy3j9xwd2ap32xkykttr4cvcu7as4yqqqqqq
        //31nwvkZwyPdgzjBJZXfDmSWsC4ZLKpYyUw 5q3728yw0y47sqn6l2na30mcw6zm78dzqqqqqqq

    }
    
    
    func testHandshake() {
        // test that we can get a token and access /me
        let req = URLRequest(url: client.url("/me"))
        let exp = expectation(description: "auth")
        client.dataTaskWithRequest(req, authenticated: true, retryCount: 0) { (data, resp, err) in
            XCTAssertEqual(resp?.statusCode, 200)
            exp.fulfill()
        }.resume()
        waitForExpectations(timeout: 30, handler: nil)
    }
}
