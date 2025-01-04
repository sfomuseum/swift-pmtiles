import Foundation
import Logging

public struct PMTilesReader {
    
    private var reader: reader
    
    public init(db: URL, use_file_descriptor: Bool = false, logger: Logger? = nil) throws {

        reader = PMTiles.reader(
            database: db,
            use_file_descriptor: use_file_descriptor,
            logger: logger
        )
        
        if case .failure(let error) = reader.open() {
            throw error
        }
    }
    
    public mutating func Size() -> Result<UInt64, Error> {
        return self.reader.size()
    }
    
    public func Read(from: UInt64, to: UInt64) -> Result<Data, Error> {
        
        if case .failure(let error) = reader.seek(from:0, to:to) {
            return .failure(error)
        }
        
        return self.reader.readBytes(from: from, to: to)
    }
    
    public mutating func Close() -> Result<Void, Error> {
        return self.reader.close()
    }
}
