import Foundation
import ArgumentParser
import EverscaleClientSwift
import FileUtils


struct ValidatorToolOptions: ParsableArguments {
//    @Flag(name: [.long, .customShort("x")], help: "Use hexadecimal notation for the result.")
//    var hexadecimalOutput = false
//
//    @Argument(help: "A group of integers to operate on.")
//    var values: String

    @Option(name: [.long, .customShort("u")], help: "Endpoints group name")
    var url: String = "default"

    @Option(name: [.long, .customShort("w")], help: "Workchain id that is used by default in DeploySet")
    var workChain: Int32?

    @Option(name: [.long, .customShort("r")], help: "Maximum time for sequential reconnections. Must be specified in milliseconds. Default is 120000 (2 min).")
    var maxReconnectTimeout: UInt32?

    @Option(name: [.long, .customShort("q")], help: "Default timeout for http requests. Is is used when no timeout specified for the request to limit the answer waiting time. If no answer received during the timeout requests ends witherror. Must be specified in milliseconds. Default is 60000 (1 min).")
    var queryTimeout: UInt32?

    @Option(name: [.long, .customShort("f")], help: "Maximum timeout that is used for query response. Must be specified in milliseconds. Default is 40000 (40 sec).")
    var waitForTimeout: UInt32?

    @Option(name: [.long, .customShort("s")], help: "Timeout that is used to process message delivery for the contracts which ABI does not include \"expire\" header. If the message is not delivered within the specified timeout the appropriate error occurs. Must be specified in milliseconds. Default is 40000 (40 sec).")
    var messageProcessingTimeout: UInt32?

    @Option(name: [.long, .customShort("c")], help: "The number of automatic message processing retries that SDK performs in case of `Message Expired (507)` error - but only for those messages which local emulation was successful or failed with replay protection error. Default is 5.")
    var messageRetriesCount: Int8?

    @Option(name: [.long, .customLong("enp")],
            help: "Array of endpoints",
            transform: { (parametr: String) throws -> [String]? in
                let params: Any? = try paramsJsonToDictionary(parametr)
                return params as? [String]
            }
    )
    var endpoints: [String]? = nil
}

protocol ValidatorToolOptionsPrtcl {
    var options: ValidatorToolOptions { get }
    func makeConfig(options: ValidatorToolOptions) throws -> TSDKClientConfig
    func setClient(options: ValidatorToolOptions) throws
}

extension ValidatorToolOptionsPrtcl {


    func setClient(options: ValidatorToolOptions) throws {
        ValidatorTool._client = try TSDKClientModule(config: try makeConfig(options: options))
    }

    func makeConfig(options: ValidatorToolOptions) throws -> TSDKClientConfig {
        var endpoints: [String]? = nil
        let envJson: [String: Any] = try readEnvVariables()
        let config: [String: Any]? = envJson["config"] as? [String: Any]
        if options.endpoints == nil {
            if let defaultEndpoints: [String] = config?["endpoints"] as? [String] {
                endpoints = defaultEndpoints
            } else if let url: String = config?["url"] as? String {
                endpoints = [url]
            } else if let mapEndpoints: [String] = (envJson["endpoints_map"] as? [String: [String]])?[options.url] {
                endpoints = mapEndpoints
            } else {
                fatalError("Bad config json. endpoints_map not defined or \(options.url) endpoints array not found")
            }
        } else if !options.endpoints!.isEmpty {
            endpoints = options.endpoints
        }
        guard let workChain: Int32 = config?["wc"] as? Int32
        else { fatalError("Bad config json. workChain not found") }
        
        let networkConfig: TSDKNetworkConfig = .init(server_address: nil,
                                                     endpoints: endpoints,
                                                     max_reconnect_timeout: options.maxReconnectTimeout,
                                                     message_retries_count: options.messageRetriesCount,
                                                     message_processing_timeout: options.messageProcessingTimeout,
                                                     wait_for_timeout: options.waitForTimeout,
                                                     out_of_sync_threshold: nil,
                                                     sending_endpoint_count: nil,
                                                     latency_detection_interval: nil,
                                                     max_latency: nil,
                                                     query_timeout: options.queryTimeout,
                                                     access_key: nil)
        let abiConfig: TSDKAbiConfig = .init(workchain: options.workChain ?? workChain,
                                             message_expiration_timeout: nil,
                                             message_expiration_timeout_grow_factor: nil)
        return TSDKClientConfig(network: networkConfig, crypto: nil, abi: abiConfig, boc: nil)
    }

    private func readEnvVariables() throws -> [String : Any] {
        if let configPath: String = ProcessInfo.processInfo.environment[envVariableName] ?? ProcessInfo.processInfo.environment[envTonosVariableName]
        {
            let configJSON: String = try FileUtils.readFile(URL(fileURLWithPath: configPath))
            guard let data: Data = configJSON.data(using: .utf8)
            else { fatalError("Bad json. Please check \(configPath) json file with configuration.") }
            guard let json: [String : Any] = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            else { fatalError("Bad json. Please check \(configPath) json file with configuration.") }

            return json
        } else {
            fatalError("Please set \(envVariableName) or \(envTonosVariableName) env variable with full path to config.json to your .profile etc")
        }
    }
}

struct ValidatorTool: ParsableCommand, @unchecked Sendable {

    nonisolated(unsafe) static var _client: TSDKClientModule?

    static var client: TSDKClientModule {
        if _client == nil { fatalError("_client is nil. Client is not defined") }
        return _client!
    }

    nonisolated(unsafe) static var configuration = CommandConfiguration(
        abstract: "A utility",
        version: "1.0.0",
        subcommands: [
            Message.self,
            SendMessage.self,
            Run.self,
            Env.self,
            QueryCollection.self,
            AggregateCollection.self,
        ],
        defaultSubcommand: nil
    )
}


@main
public struct validator_tool {
    
    public static func main() {
        ValidatorTool.main()
    }
}
