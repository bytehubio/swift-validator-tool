//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 25.08.2021.
//

import Foundation
import ArgumentParser
import EverscaleClientSwift
import FileUtils
import SwiftExtensionsPack

extension ValidatorTool {
    struct SendMessage: ParsableCommand, ValidatorToolOptionsPrtcl {

        @OptionGroup var options: ValidatorToolOptions

        @Option(name: [.long, .customShort("a")], help: "Account address")
        var addr: String

        @Option(name: [.long, .customShort("m")], help: "Calling method")
        var method: String

        @Option(name: [.long, .customShort("p")], help: "Params")
        var paramsJSON: String = "{}"

        @Option(name: [.long, .customShort("b")], help: "Path to abi file")
        var abiPath: String

        @Option(name: [.long, .customShort("k")], help: "Path to sign keys json file")
        var keysPath: String

        public func run() throws {
            try makeResult()
        }

        @discardableResult
        func makeResult() throws -> String {
            try setClient(options: options)
            var functionResult: String = ""
            let group: DispatchGroup = .init()
            group.enter()

            var params: AnyValue!
            do {
                params = try paramsJsonToDictionary(paramsJSON).toAnyValue()
            } catch {
                fatalError( error.localizedDescription )
            }
            var keys: TSDKKeyPair!
            do {
                keys = try keysJsonToKeyPair(keysPath)
            } catch {
                fatalError( error.localizedDescription )
            }
            let abi: TSDKAbi = .init(type: .Serialized, value: readAbi(abiPath))
            let callSet: TSDKCallSet = .init(function_name: method, input: params)
            let signer: TSDKSigner = .init(type: .Keys, keys: keys)
            let paramsOfEncodeMessage: TSDKParamsOfEncodeMessage = .init(abi: abi,
                                                                         address: addr,
                                                                         deploy_set: nil,
                                                                         call_set: callSet,
                                                                         signer: signer,
                                                                         processing_try_index: nil)
            let paramsOfProcessMessage: TSDKParamsOfProcessMessage = .init(message_encode_params: paramsOfEncodeMessage, send_events: false)
            try client.processing.process_message(paramsOfProcessMessage)
            { (response: TSDKBindingResponse<TSDKResultOfProcessMessage, TSDKClientError>) in
                if let error = response.error {
                    fatalError( error.localizedDescription )
                }
                if response.finished {
//                    response.result!.decoded?.output?.toJSON()
//                    response.result!.decoded?.output?.toJSON()
//                    let boc: String = response.result!
//                    functionResult = boc
                    functionResult = response.result!.decoded?.output?.toJson() ?? ""
//                    dump(response.result!)

                    group.leave()
                }
            }
            group.wait()

            let stdout: FileHandle = FileHandle.standardOutput
            stdout.write(functionResult.trimmingCharacters(in: .whitespacesAndNewlines).data(using: .utf8) ?? Data())
            return functionResult
        }

        private func keysJsonToKeyPair(_ path: String) throws -> TSDKKeyPair {
            let json = try FileUtils.readFile(URL(fileURLWithPath: path))
            guard let data: Data = json.data(using: .utf8)
            else { fatalError("Bad params json, it must be valid json") }
            let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            guard let secret: String = dict?["secret"] as? String,
                  let `public`: String = dict?["public"] as? String
            else { fatalError("Bad keys file. Public or Secret not found.") }

            return .init(public: `public`, secret: secret)
        }
    }
}
