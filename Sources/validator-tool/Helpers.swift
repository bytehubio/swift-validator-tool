//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 25.08.2021.
//

import Foundation
import TonClientSwift

var pathToRootDirectory: String {
    /// Please, set custom working directory to project folder for your xcode scheme. This is necessary for the relative path "./" to the project folders to work.
    /// You may change it with the xcode edit scheme menu.
    /// Or inside file path_to_ton_sdk/.swiftpm/xcode/xcshareddata/xcschemes/TonSDK.xcscheme
    /// set to tag "LaunchAction" absolute path to this library with options:
    /// useCustomWorkingDirectory = "YES"
    /// customWorkingDirectory = "/path_to_ton_sdk"
    let workingDirectory: String = "./"
    if !FileManager.default.fileExists(atPath: workingDirectory) {
        fatalError("\(workingDirectory) directory is not exist")
    }
    return workingDirectory
}

func readAbi(_ relativeFilePath: String) -> AnyValue {
    var abiJSON: String = pathToRootDirectory + "/\(relativeFilePath)"
    if relativeFilePath[#"^\/"#] {
        abiJSON = relativeFilePath
    } else {
        abiJSON = pathToRootDirectory + "/\(relativeFilePath)"
    }
    var abiText: String = .init()
    DOFileReader.readFile(abiJSON) { (line) in
        abiText.append(line)
    }
    guard let any = abiText.toAnyValue() else { fatalError("AbiJSON Not Parsed From File") }

    return any
}

func readTvc(_ relativeFilePath: String) -> Data {
    let tvc: String = pathToRootDirectory + "/\(relativeFilePath)"
    guard let data = FileManager.default.contents(atPath: tvc) else { fatalError("tvc not read") }

    return data
}

func sdk(endpoints: [String]? = nil) -> TSDKClientModule {
    let defaultEndpoints: [String] = [
        "https://rustnet1.ton.dev",
        "https://rustnet2.ton.dev"
    ]
    var config: TSDKClientConfig = .init()
    config.network = TSDKNetworkConfig(endpoints: endpoints ?? defaultEndpoints)
    return TSDKClientModule(config: config)
}
