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
    struct SendMessage: ParsableCommand, ValidatorToolOptionsPrtcl {

        @OptionGroup var options: ValidatorToolOptions

        @Option(help: "depoolAddr")
        var depoolAddr: String

        public func run() throws {

        }
    }
}
