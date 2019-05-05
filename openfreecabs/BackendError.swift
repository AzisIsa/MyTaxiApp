

import Foundation

public enum BackendError: Error {
    case network(error: NSError)
    case dataSerialization(reason: String)
    case jsonSerialization(error: NSError)
    case objectSerialization(reason: String)
    case xmlSerialization(error: NSError)
}
