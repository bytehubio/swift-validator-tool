import XCTest
//@testable import validator_tool
//import validator_tool
import class Foundation.Bundle

final class validator_toolTests: XCTestCase {

    func testInfo() {
//        var object = GetDepoolParticipantInfo.init()
//        object.depoolAbiPath = "/Users/nerzh/mydata/crypto_projects/ton/ton-labs-contracts/solidity/depool/DePool.abi.json"
//        object.depoolAddr = "0:80a981036dbed0961af8262cf849cd0113e00a7c7be435404290c5fa218836e3"
//        object.participantAddr = "0:c6e09cf2464b1d9f7d9a992bb10bc77aa4496e39f4494c18fbbbd0633931ad27"
//        try! object.run()
    }


    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct
//        // results.
//
//        // Some of the APIs that we use below are available in macOS 10.13 and above.
//        guard #available(macOS 10.13, *) else {
//            return
//        }
//
//        // Mac Catalyst won't have `Process`, but it is supported for executables.
//        #if !targetEnvironment(macCatalyst)
//
//        let fooBinary = productsDirectory.appendingPathComponent("validator-tool")
//
//        let process = Process()
//        process.executableURL = fooBinary
//
//        let pipe = Pipe()
//        process.standardOutput = pipe
//
//        try process.run()
//        process.waitUntilExit()
//
//        let data = pipe.fileHandleForReading.readDataToEndOfFile()
//        let output = String(data: data, encoding: .utf8)
//
//        XCTAssertEqual(output, "Hello, world!\n")
//        #endif
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }
}
