import Foundation
import RichJSONParser

public enum DecodingError : LocalizedError {
    case typeMismatch(Any.Type,
        message: String,
        codingPath: [CodingKey],
        location: SourceLocation?)
    case keyNotFound(String,
        codingPath: [CodingKey],
        location: SourceLocation?)
    case outOfRange(
        codingPath: [CodingKey],
        location: SourceLocation?)
    case custom(
        message: String,
        codingPath: [CodingKey],
        location: SourceLocation?)

    public var errorDescription: String? {
        func codingKeyString(_ key: CodingKey) -> String {
            var d = "\(key.stringValue)"
            if let int = key.intValue {
                d += "(int=\(int))"
            }
            return d
        }
        
        func codingPathString(_ codingPath: [CodingKey]) -> String {
            let strs: [String] = codingPath.map { codingKeyString($0) }
            return "path=[\(strs.joined(separator: ", "))]"
        }
        
        func locationString(_ loc: SourceLocation?) -> String {
            guard let loc = loc else {
                return ""
            }
            return "at \(loc)"
        }
        
        switch self {
        case .typeMismatch(let type,
                           message: let m,
                           codingPath: let cp,
                           location: let loc):
            let parts = ["type=\(type)", m, codingPathString(cp), locationString(loc)]
            return "type mismatch: " + parts.joined(separator: ", ")
        case .keyNotFound(let key,
                          codingPath: let cp,
                          location: let loc):
            
            let parts = ["key=\(key)", codingPathString(cp), locationString(loc)]
            return "key not found: " + parts.joined(separator: ", ")
        case .outOfRange(codingPath: let cp,
                         location: let loc):
            let parts = [codingPathString(cp), locationString(loc)]
            return "out of range: "  + parts.joined(separator: ", ")
        case .custom(message: let m,
                     codingPath: let cp,
                     location: let loc):
            let parts = [m, codingPathString(cp), locationString(loc)]
            return "decoding error: " + parts.joined(separator: ", ")
        }
    }
}
