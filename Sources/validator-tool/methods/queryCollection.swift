//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 20.09.2021.
//

import Foundation
import ArgumentParser
import EverscaleClientSwift
import FileUtils
import SwiftExtensionsPack

extension ValidatorTool {
    struct QueryCollection: ParsableCommand, ValidatorToolOptionsPrtcl {

        @OptionGroup var options: ValidatorToolOptions

        @Option(name: [.customLong("coll", withSingleDash: false)], help: "Collection name")
        var collection: String

        @Option(name: [.customLong("fil", withSingleDash: false)], help: "Collection filter. JSON")
        var filter: String = "{}"

        @Option(name: [.customLong("res", withSingleDash: false)], help: "Result data. Example: id boc ...")
        var result: String = ""

        @Option(name: [.customLong("ord", withSingleDash: false)], help: "Order. Example: [{\"path\": \"id\", \"direction\": \"ASC\"}]")
        var order: String = "[]"

        @Option(name: [.customLong("lim", withSingleDash: false)], help: "Limit per request. Max: 50")
        var limit: UInt32 = 50

        public func run() throws {
            try makeResult()
        }

        @discardableResult
        func makeResult() throws -> String {
            try setClient(options: options)
            var functionResult: String = ""
            let group: DispatchGroup = .init()
            group.enter()

            let paramsOfQueryCollection: TSDKParamsOfQueryCollection = .init(collection: collection,
                                                                             filter: try paramsJsonToDictionary(filter).toAnyValue(),
                                                                             result: result,
                                                                             order: inputOrderToModel(order)?.order,
                                                                             limit: limit)
            try client.net.query_collection(paramsOfQueryCollection) { response in
                if let error = response.error {
                    fatalError( error.localizedDescription )
                }
                if response.finished {
                    functionResult = response.result!.result.toJson() ?? "[]"
                    group.leave()
                }
            }
            group.wait()

            let stdout: FileHandle = FileHandle.standardOutput
            stdout.write(functionResult.trimmingCharacters(in: .whitespacesAndNewlines).data(using: .utf8) ?? Data())
            return functionResult
        }
    }
}


extension ValidatorTool.QueryCollection {
    private struct OrderModel: Codable {
        var order: [TSDKOrderBy] = []
    }

    private func inputOrderToModel(_ json: String) -> OrderModel? {
        let json = #""order": \(json)"#
        return json.toModel(OrderModel.self)
    }
}

