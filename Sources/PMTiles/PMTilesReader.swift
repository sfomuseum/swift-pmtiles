import Foundation
import Logging

public struct PMTilesReaderOptions {
    internal var database: URL
    internal var use_fd: Bool = false
    public var Logger: Logger? = nil
    
    public init(_ db: URL, use_file_descriptor: Bool = false) {
        database = db
        use_fd = use_file_descriptor
    }
}

public struct PMTilesReader {
    
    private var reader: reader
    
    public init(_ opts: PMTilesReaderOptions) throws {

        reader = PMTiles.reader(
            database: opts.database,
            use_file_descriptor: opts.use_fd,
            logger: opts.Logger
        )
        
        if case .failure(let error) = reader.open() {
            throw error
        }
    }
    
    public mutating func Size() -> Result<UInt64, Error> {
        return self.reader.size()
    }
    
    public func Read(from: UInt64, to: UInt64) -> Result<Data, Error> {
        
        if case .failure(let error) = reader.seekTo(to: from) {
            return .failure(error)
        }
        
        return self.reader.readBytes(from: from, to: to)
    }
    
    public mutating func Close() -> Result<Void, Error> {
        return self.reader.close()
    }
}
