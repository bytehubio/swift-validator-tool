import Foundation
import ArgumentParser
import TonClientSwift
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
}

protocol ValidatorToolOptionsPrtcl {
    var options: ValidatorToolOptions { get }
    func makeConfig(options: ValidatorToolOptions) throws -> TSDKClientConfig
    func setClient(options: ValidatorToolOptions) throws
}

struct ValidatorToolOptionsPrtclStore {
    static var client: TSDKClientModule!
}
extension ValidatorToolOptionsPrtcl {


    func setClient(options: ValidatorToolOptions) throws {
        ValidatorTool._client = TSDKClientModule(config: try makeConfig(options: options))
    }

    func makeConfig(options: ValidatorToolOptions) throws -> TSDKClientConfig {
        guard let configPath: String = ProcessInfo.processInfo.environment[envVariableName]
        else { fatalError("Please set \(envVariableName) env variable with full path to config.json to your .profile etc") }
        let configJSON: String = try FileUtils.readFile(URL(fileURLWithPath: configPath))
        guard let data: Data = configJSON.data(using: .utf8)
        else { fatalError("Bad json. Please check \(configPath) json file with configuration.") }
        guard let json: [String : Any] = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
        else { fatalError("Bad json. Please check \(configPath) json file with configuration.") }

        guard let endpointsMap: [String: [String]] = json["endpoints_map"] as? [String: [String]],
              let endpoints: [String] = endpointsMap[options.url]
        else { fatalError("Bad config json. endpoints_map not defined or \(options.url) endpoints array not found") }

        guard let workChain: Int32 = json["workChain"] as? Int32
        else { fatalError("Bad config json. workChain not found") }

        let networkConfig: TSDKNetworkConfig = .init(endpoints: endpoints)
        let abiConfig: TSDKAbiConfig = .init(workchain: options.workChain ?? workChain,
                                             message_expiration_timeout: nil,
                                             message_expiration_timeout_grow_factor: nil)
        return TSDKClientConfig(network: networkConfig, crypto: nil, abi: abiConfig, boc: nil)
    }
}

struct ValidatorTool: ParsableCommand {

    static var _client: TSDKClientModule?

    static var client: TSDKClientModule {
        if _client == nil { fatalError("_client is nil. Client is not defined") }
        return _client!
    }

    static var configuration = CommandConfiguration(
        abstract: "A utility",
        version: "1.0.0",
        subcommands: [SendMessage.self, Run.self],
        defaultSubcommand: nil
    )
}

ValidatorTool.main()
