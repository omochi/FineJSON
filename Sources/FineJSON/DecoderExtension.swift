import Foundation
import RichJSONParser

extension Decoder {
    public var sourceLocation: SourceLocation? {
        guard let d = self as? _Decoder else {
            return nil
        }
        return d._sourceLocation
    }
    
    public var json: ParsedJSON? {
        guard let d = self as? _Decoder else {
            return nil
        }
        return d._json
    }
}

extension SingleValueDecodingContainer {
    public func decodeFixedArray<T: Decodable>(_ elementType: T.Type, count: Int,
                                               sourceLocation: @autoclosure () -> SourceLocation? = nil)
        throws -> [T]
    {
        let array = try decode(Array<T>.self)
        guard array.count >= count else {
            throw DecodingError.outOfRange(codingPath: codingPath,
                                           location: sourceLocation())
        }
        return array
    }
}
