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

public struct GetDepoolParticipantInfo: ParsableCommand {

    @Option(help: "depoolAddr")
    var depoolAddr: String

    @Option(help: "participantAddr")
    var participantAddr: String

    @Option(help: "depoolAbiPath")
    var depoolAbiPath: String

    public init() {}

    public func run() throws {

        print(pathToRootDirectory)
        print(try FileUtils.absolutePath(pathToRootDirectory))
//        print(FileUtils.makeRelativePath(from: <#T##String#>, to: <#T##String#>))

        print(ProcessInfo.processInfo.environment)
        print(Bundle.main.bundlePath)
        print(Bundle.main.executablePath)
        print(try! Bundle.main.bundleURL.resourceValues(forKeys: [.volumeURLKey]).volume)
        let group: DispatchGroup = .init()
//        let paramsOfEncodeMessage: TSDKParamsOfEncodeMessage = .init(
//            abi: .init(type: .Serialized, value: readAbi(depoolAbiPath)),
//            address: depoolAddr,
//            deploy_set: nil,
//            call_set: .init(
//                function_name: "getParticipantInfo",
//                header: nil,
//                input: [
//                    "addr": participantAddr
//                ].toAnyValue()
//            ),
//            signer: .init(type: .None),
//            processing_try_index: nil
//        )

        let paramsOfEncodeMessage: TSDKParamsOfEncodeMessage = .init(
            abi: .init(type: .Serialized, value: readAbi(depoolAbiPath)),
            address: depoolAddr,
            deploy_set: nil,
            call_set: .init(
                function_name: "getParticipants",
                header: nil,
                input: nil
            ),
            signer: .init(type: .None),
            processing_try_index: nil
        )
        let paramsOfProcessMessage: TSDKParamsOfProcessMessage = .init(message_encode_params: paramsOfEncodeMessage, send_events: false)

        let defaultEndpoints: [String] = [
            "https://rustnet1.ton.dev",
            "https://rustnet2.ton.dev"
        ]
        var config: TSDKClientConfig = .init()
        config.network = TSDKNetworkConfig(endpoints: defaultEndpoints)
        let client = TSDKClientModule(config: config)
//        let client = sdk()

        group.enter()
        let paramsOfWaitForCollection: TSDKParamsOfWaitForCollection = .init(collection: "accounts",
                                                                             filter: [
                                                                                "id": [
                                                                                    "eq": depoolAddr
                                                                                ]
                                                                             ].toAnyValue(),
                                                                             result: "boc",
                                                                             timeout: nil)
        client.net.wait_for_collection(paramsOfWaitForCollection) { result in
            if result.finished {
                if let anyResult = result.result?.result.toAny() {
                    
                }
                group.leave()
            }
        }


//        client.processing.process_message(paramsOfProcessMessage) { result in
//            if result.finished {
//                print(result.result?.transaction)
//                group.leave()
//            }
//        }
        group.wait()
//        sdk().abi.encode_message(paramsOfEncodeMessage) { <#TSDKBindingResponse<TSDKResultOfEncodeMessage, TSDKClientError, TSDKDefault>#> in
//            <#code#>
//        }
    }
}
