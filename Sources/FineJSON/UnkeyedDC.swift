import Foundation
import RichJSONParser

internal struct UnkeyedDC : UnkeyedDecodingContainer {
    let decoder: _Decoder
    
    let array: [ParsedJSON]
    
    init(decoder: _Decoder, json: ParsedJSON) throws {
        self.decoder = decoder
        
        self.currentIndex = 0
        
        switch json.value {
        case .array(let a):
            self.array = a
        default:
            let m = "expected array but \(json.value.kind)"
            throw DecodingError.typeMismatch(JSONArray.self,
                                             message: m,
                                             codingPath: decoder.codingPath,
                                             location: decoder.sourceLocation)
        }
    }
    
    var codingPath: [CodingKey] {
        return decoder.codingPath
    }
    
    var _count: Int { return array.count }
    
    var count: Int? { return _count }
    
    var isAtEnd: Bool { return currentIndex == _count }
    
    var currentIndex: Int
    
    mutating func decodeNil() throws -> Bool {
        return try decodeElement { (d) in
            return d.singleValueContainer().decodeNil()
        }
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        return try decodeElement { (d) in
            return try d.singleValueContainer().decode(type)
        }
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type)
        throws -> KeyedDecodingContainer<NestedKey>
        where NestedKey : CodingKey
    {
        return try decodeElement { (d) in
            return try d.container(keyedBy: type)
        }
    }
    
    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        return try decodeElement { (d) in
            return try d.unkeyedContainer()
        }
    }
    
    mutating func superDecoder() throws -> Decoder {
        return try decodeElement { (d) in
            return d
        }
    }
    
    private mutating func decodeElement<R>(decode: (_Decoder) throws -> R) throws -> R {
        let codingPath = self.codingPath + [JSONArray.Index(currentIndex)]
        
        guard !isAtEnd else {
            throw DecodingError.outOfRange(codingPath: codingPath,
                                           location: self.decoder.sourceLocation)
        }
        
        let elem = array[currentIndex]
        currentIndex += 1
        let decoder = _Decoder(json: elem,
                               codingPath: codingPath,
                               options: self.decoder.options,
                               decodingType: nil)
        return try decode(decoder)
    }
}
