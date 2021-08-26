//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 25.08.2021.
//

import Foundation
import ArgumentParser
import TonClientSwift

public struct GetKeys: ParsableCommand {

    @Option(help: "depoolAddr")
    var phrase: String

    public init() {}

    public func run() throws {
        
        if phrase.isEmpty {

        } else {

        }
    }

//    private func getKeysBy(_ phrase: String,
//                           path: String = "m/44'/396'/0'/0/0",
//                           dictionary: TSDKMnemonicDictionary? = .ENGLISH,
//                           _ handler: @escaping (Result<TSDKKeyPair, TSDKClientError>) -> Void
//    ) {
//        let wordCount: UInt8 = UInt8(phrase.split(separator: " ").count)
//        let params: TSDKParamsOfMnemonicDeriveSignKeys = .init(phrase: phrase, path: path, dictionary: dictionary, word_count: wordCount)
//        client.crypto.mnemonic_derive_sign_keys(params) { (response: TSDKBindingResponse<TSDKKeyPair, TSDKClientError, TSDKDefault>) in
//            if response.finished {
//                if let error = response.error {
//                    handler(.failure(error))
//                } else if let `public` = response.result?.public, let secret = response.result?.secret {
//                    let keys: TSDKKeyPair = .init(public: `public`, secret: secret)
//                    handler(.success(keys))
//                }
//            }
//        }
//    }
//
//    private func getKeysByRandomPhrase(wordCount: UInt8? = 12,
//                                       dictionary: TSDKMnemonicDictionary? = .ENGLISH,
//                                       _ handler: @escaping (Result<TSDKKeyPair, TSDKClientError>) -> Void
//    ) {
//        let params: TSDKParamsOfMnemonicFromRandom = .init(dictionary: dictionary, word_count: wordCount)
//        client.crypto.mnemonic_from_random(params
//        ) { (response: TSDKBindingResponse<TSDKResultOfMnemonicFromRandom, TSDKClientError, TSDKDefault>) in
//            if response.finished {
//                if let error = response.error {
//                    handler(.failure(error))
//                } else if let phrase = response.result?.phrase {
//                    self.getKeysBy(phrase) { result in
//                        switch result {
//                        case let .success(keys):
//                            handler(.success(keys))
//                        case let .failure(error):
//                            handler(.failure(error))
//                        }
//                    }
//                }
//            }
//        }
//    }

}
