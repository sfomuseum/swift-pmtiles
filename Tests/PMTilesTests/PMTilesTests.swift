import XCTest
import Foundation
@testable import PMTiles

enum PMTilesTestsError: Error {
    case unknown
}

final class PMTilesTests: XCTestCase {
    func testExample() throws {

        guard let db_url = Bundle.module.url(forResource: "sfo", withExtension: "pmtiles") else {
            throw PMTilesTestsError.unknown
        }

        var r = try PMTilesReader(db: db_url, use_file_descriptor: true)
        
        if case .failure(let error) = r.Read(from: 0, to: 1024) {
            throw error
        }
   
        if case .failure(let error) = r.Size() {
            throw error
        }
        
        if case .failure(let error) = r.Close() {
            throw error
        }
    }
}
