//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 20.09.2021.
//

import Foundation
import ArgumentParser
import EverscaleClientSwift

extension ValidatorTool {
    struct AggregateCollection: ParsableCommand, ValidatorToolOptionsPrtcl {

        @OptionGroup var options: ValidatorToolOptions

        @Option(name: [.customLong("coll", withSingleDash: false)], help: "Collection name")
        var collection: String

        @Option(name: [.customLong("fil", withSingleDash: false)], help: "Collection filter. JSON")
        var filter: String = "{}"

        @Option(name: [.customLong("fld", withSingleDash: false)], help: "Fitelds. JSON")
        var fields: String = "[]"


        public func run() throws {
            try makeResult()
        }

        @discardableResult
        func makeResult() throws -> String {
            try setClient(options: options)
            var functionResult: String = ""
            let group: DispatchGroup = .init()
            group.enter()

            let paramsOfAggregateCollection: TSDKParamsOfAggregateCollection = .init(collection: collection,
                                                                                     filter: try paramsJsonToDictionary(filter).toAnyValue(),
                                                                                     fields: inputFieldsToModel(fields)?.fields)

            client.net.aggregate_collection(paramsOfAggregateCollection) { response in
                if let error = response.error {
                    fatalError( error.localizedDescription )
                }
                if response.finished {
                    if let values: [String] = response.result!.values.toAny() as? [String] {
                        functionResult = values.last ?? "0"
                    } else {
                        functionResult = "0"
                    }
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


extension ValidatorTool.AggregateCollection {
    private struct FieldModel: Codable {
        var fields: [TSDKFieldAggregation] = []
    }

    private func inputFieldsToModel(_ json: String) -> FieldModel? {
        let json = #""fields": \(json)"#
        return json.toModel(FieldModel.self)
    }
}


