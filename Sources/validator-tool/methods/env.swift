//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 20.09.2021.
//

import Foundation
import ArgumentParser
import TonClientSwift
import FileUtils

extension ValidatorTool {
    struct Env: ParsableCommand, ValidatorToolOptionsPrtcl {
        @OptionGroup var options: ValidatorToolOptions

        public func run() throws {
            try makeResult()
        }

        @discardableResult
        func makeResult() throws -> String {
            guard let configPath: String = ProcessInfo.processInfo.environment[envVariableName]
            else { fatalError("Please set \(envVariableName) env variable with full path to config.json to your .profile etc") }
            let configJSON: String = try FileUtils.readFile(URL(fileURLWithPath: configPath))
            guard let data: Data = configJSON.data(using: .utf8)
            else { fatalError("Bad json. Please check \(configPath) json file with configuration.") }
            guard let json: [String : Any] = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            else { fatalError("Bad json. Please check \(configPath) json file with configuration.") }
            print("\(json)")

            return "\(json)"
        }
    }
}
