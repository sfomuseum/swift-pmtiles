# swift-pmtiles

Swift package for reading data from a PMTiles database.

## Important

This is work in progress and may still change.

## Documentation

Documentation is incomplete at this time.

## Example

### PMTilesReader

Currently this package only exports a single `PMTilesReader` struct which is designed to read a range of bytes (like HTTP range headers). This code was originally written for use with the [sfomuseum/swifter-protomaps](https://github.com/sfomuseum/swifter-protomaps) package and has been made in to a standalone package so that it can be used with other HTTP server implementations.

By default it operates on PMTiles database files using the `Foundation.FileHandle` class. While suitable for most situations, if you are working with very large databases (like the [120GB global database](https://maps.protomaps.com/builds/)) in an iOS context this will trigger "Cannot allocate memory" errors. To account for this it is possible to signal that the `PMTilesReader` instance should use a `System.FileDescriptor` instance for working with PMTiles database files.

```
import PMTiles
import Logging

guard let db_url = URL(string: "/path/to/db.pmtiles") else {
	throw SomeErrorHere
}

var logger = Logger("label": "example")
logger.logLevel = .debug

var reader_opts = PMTilesReaderOptions(db_url, use_file_descriptor: true)
reader_opts.Logger = logger

var reader: PMTilesReader

do {
	reader = try PMTilesReader(reader_opts)
} catch {
	throw error
}

if case .failure(let error) = reader.Read(from: 0, to: 1024) {
	throw error
}
   
if case .failure(let error) = reader.Size() {
	throw error
}
        
if case .failure(let error) = reader.Close() {
	throw error
}
```

## See also

* https://docs.protomaps.com/
* https://maps.protomaps.com/builds/