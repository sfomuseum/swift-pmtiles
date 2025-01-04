import XCTest
import Foundation
import Logging
@testable import PMTiles

enum PMTilesTestsError: Error {
    case unknown
}

final class PMTilesTests: XCTestCase {
    func testExample() throws {

        guard let db_url = Bundle.module.url(forResource: "sfo", withExtension: "pmtiles") else {
            throw PMTilesTestsError.unknown
        }

        var logger = Logger(label: "org.sfomuseum.swift-pmtiles.tests")
        logger.logLevel = .debug
        
        var reader_opts = PMTilesReaderOptions(db_url, use_file_descriptor: true)
        reader_opts.Logger = logger
        
        var reader = try PMTilesReader(reader_opts)
        
        if case .failure(let error) = reader.Read(from: 0, to: 1024) {
            throw error
        }
   
        if case .failure(let error) = reader.Size() {
            throw error
        }
        
        if case .failure(let error) = reader.Close() {
            throw error
        }
    }
}
