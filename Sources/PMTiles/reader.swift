import Foundation
import System

internal enum readerError: Error {
    case notOpen
    case readError
    case unknown
}

internal struct reader {

    private var db_url: URL
    private var db_path: String
    
    private var use_fd: Bool
    private var fh: FileHandle?
    private var fd: FileDescriptor?
    private var mu: DispatchSemaphore
    private var is_open: Bool = false
    
    internal init(database: URL, use_file_descriptor: Bool) {
        db_url = database
        db_path = db_url.absoluteString
        use_fd = use_file_descriptor
        mu = DispatchSemaphore(value: 1)
    }
    
    internal mutating func open() -> Result<Void, Error> {

        self.mu.wait()
        
        defer {
            self.mu.signal()
        }
        
        if !is_open {
            
            do {
                
                if self.use_fd {
                    let fp = FilePath(self.db_url.absoluteString.replacingOccurrences(of: "file://", with: ""))
                    fd = try FileDescriptor.open(fp, .readOnly)
                } else {
                    fh = try FileHandle(forReadingFrom: self.db_url)
                }
                
            } catch {
                return .failure(error)
            }
            
            is_open = true
        }
        
        return .success(())
    }
    
    internal mutating func close() -> Result<Void, Error> {
        
        self.mu.wait()
        
        defer {
            self.mu.signal()
        }
        
        if !is_open {
            return .failure(readerError.notOpen)
        }
        
            do {
                
                if self.use_fd {
                    try fd!.close()
                } else {
                    try fh!.close()
                }
                
            } catch (let error) {
                return .failure(error)
            }
            
            is_open = false
        
        return .success(())
    }
    
    internal func size() -> Result<UInt64, Error> {
        
        self.mu.wait()
        
        defer {
            self.mu.signal()
        }
        
        if !is_open{
            return .failure(readerError.notOpen)
        }
        
        var size: UInt64 = 0
        
         do {
             if self.use_fd {
                let size_int64 = try fd!.seek(offset: 0, from: FileDescriptor.SeekOrigin.end)
                 size = UInt64(size_int64)
             } else {
                 size = try fh!.seekToEnd()
             }
         } catch (let error){
             return .failure(error)
         }
        
        return .success(size)
    }
    
    internal func readBytes(from: UInt64, to: UInt64) -> Result<Data, Error> {
        
        self.mu.wait()
        
        defer {
            self.mu.signal()
        }
        
        if !is_open{
            return .failure(readerError.notOpen)
        }
        
        let next = to + 1
        let body: Data!
                    
        if self.use_fd {
            
            let read_len = Int(UInt64(next) - from)
            
            guard let data = readData(from: fd!.rawValue, length: Int(read_len)) else {
                return .failure(readerError.readError)
            }
            
            body = data
            
        } else {
            
            do {
                body = try fh?.read(upToCount: Int(next))
            } catch (let error){
                return .failure(error)
            }
        }
        
        return .success(body)
    }
    
    internal func seek(from: UInt64, to: UInt64) -> Result<Void, Error> {
        
        self.mu.wait()
        
        defer {
            self.mu.signal()
        }
        
        if !is_open{
            return .failure(readerError.notOpen)
        }
        
        do {
                        
            if self.use_fd {
                try fd!.seek(offset: Int64(from), from: FileDescriptor.SeekOrigin.start)
            } else {
                fh!.seek(toFileOffset: from)
            }
            
        } catch {
            return .failure(error)
        }
        
        return .success(())
    }
    
    private func readData(from fileDescriptor: Int32, length: Int) -> Data? {
        // Create a Data buffer of the desired length
        var data = Data(count: length)
        
        // Read the data into the Data buffer
        let bytesRead = data.withUnsafeMutableBytes { buffer -> Int in
            guard let baseAddress = buffer.baseAddress else { return -1 }
            return read(fileDescriptor, baseAddress, length)
        }
        
        // Handle errors or end-of-file
        guard bytesRead > 0 else {
            return nil // Return nil if no bytes were read
        }
        
        // Resize the Data object to the actual number of bytes read
        data.removeSubrange(bytesRead..<data.count)
        return data
    }
}
