//
//  File.swift
//
//
//  Created by Oleh Hudeichuk on 25.08.2021.
//

import Foundation
import ArgumentParser
import TonClientSwift
import FileUtils

extension ValidatorTool {
    public struct Run: ParsableCommand, ValidatorToolOptionsPrtcl {

        @OptionGroup var options: ValidatorToolOptions

        @Option(name: [.long, .customShort("a")], help: "Account address")
        var addr: String

        @Option(name: [.long, .customShort("m")], help: "Calling method")
        var method: String

        @Option(name: [.long, .customShort("p")], help: "Params")
        var paramsJSON: String = "{}"

        @Option(name: [.long, .customShort("b")], help: "Path to abi file")
        var abiPath: String

        public func run() throws {
            try setClient(options: options)
            let group: DispatchGroup = .init()
            group.enter()
            defer { group.wait() }

            let paramsOfWaitForCollection: TSDKParamsOfWaitForCollection = .init(collection: "accounts",
                                                                                 filter: [
                                                                                    "id": [
                                                                                        "eq": addr
                                                                                    ]
                                                                                 ].toAnyValue(),
                                                                                 result: "boc",
                                                                                 timeout: nil)
            client.net.wait_for_collection(paramsOfWaitForCollection) { result in
                if let error = result.error {
                    fatalError( error.localizedDescription )
                }
                if result.finished {
                    var params: AnyValue!
                    do {
                        params = try paramsJsonToDictionary(paramsJSON).toAnyValue()
                    } catch {
                        fatalError( error.localizedDescription )
                    }
                    if let anyResult = result.result?.result.toAny() as? [String: Any] {
                        guard let boc: String = anyResult["boc"] as? String
                        else { fatalError("Receive result, but Boc not found") }

                        let abi: AnyValue = readAbi(abiPath)
                        let paramsOfEncodeMessage: TSDKParamsOfEncodeMessage = .init(
                            abi: .init(type: .Serialized, value: abi),
                            address: addr,
                            deploy_set: nil,
                            call_set: .init(
                                function_name: method,
                                header: nil,
                                input: params
                            ),
                            signer: .init(type: .None),
                            processing_try_index: nil
                        )

                        client.abi.encode_message(paramsOfEncodeMessage) { result in
                            if let error = result.error {
                                fatalError( error.localizedDescription )
                            }
                            if result.finished {
                                let message: String = result.result!.message
                                let paramsOfRunTvm: TSDKParamsOfRunTvm = .init(message: message,
                                                                               account: boc,
                                                                               execution_options: nil,
                                                                               abi: TSDKAbi(type: .Serialized, value: abi),
                                                                               boc_cache: nil,
                                                                               return_updated_account: nil)
                                client.tvm.run_tvm(paramsOfRunTvm) { result in
                                    if let error = result.error {
                                        fatalError( error.localizedDescription )
                                    }
                                    if result.finished {
                                        let tvmResult: TSDKResultOfRunTvm = result.result!
                                        guard let output: String = tvmResult.decoded?.output?.toJSON()
                                        else { fatalError( "output not defined" ) }
                                        print(output)
                                        group.leave()
                                    }
                                }
                            }
                        }
                    } else {
                        fatalError( "Boc not found" )
                    }
                }
            }
        }

        private func paramsJsonToDictionary(_ params: String) throws -> [String: Any] {
            guard let data: Data = params.data(using: .utf8)
            else { fatalError("Bad params json, it must be valid json") }
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]

            return json ?? [:]
        }
    }
}
