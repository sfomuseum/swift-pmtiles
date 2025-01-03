import Foundation
import Logging

public struct PMTilesReader {
    
    private var reader: reader
    public var Logger: Logger?
    // private var mu: DispatchSemaphore
    
    public init(db: URL, use_file_descriptor: Bool = false) throws {

        reader = PMTiles.reader(database: db, use_file_descriptor: use_file_descriptor)
        
        if case .failure(let error) = reader.open() {
            throw error
        }
        
        // mu = DispatchSemaphore(value: 1)
    }
    
    public func Size() -> Result<UInt64, Error> {
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
