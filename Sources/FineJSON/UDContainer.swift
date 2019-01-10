import Foundation

internal struct UDContainer : UnkeyedDecodingContainer {
    let decoder: _Decoder
    
    let array: JSONArray
    
    init(decoder: _Decoder, value: JSON) throws {
        self.decoder = decoder
        
        self.currentIndex = 0
        
        switch value {
        case .array(let value):
            self.array = value
        default:
            let dd = "expected array but \(value.typeName)"
            let ctx = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: dd)
            throw DecodingError.typeMismatch(JSONArray.self, ctx)
        }
    }
    
    var codingPath: [CodingKey] {
        return decoder.codingPath
    }
    
    var _count: Int { return array.value.count }
    
    var count: Int? { return _count }
    
    var isAtEnd: Bool { return currentIndex == _count }
    
    var currentIndex: Int
    
    mutating func decodeNil() throws -> Bool {
        return try decodeElement { (d) in
            return d.singleValueContainer().decodeNil()
        }
    }
    
    mutating func decode<X>(_ type: X.Type) throws -> X where X : CodablePrimitive, X : Decodable {
        return try decodeElement { (d) in
            return try d.singleValueContainer().decode(type)
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
            let dd = "unkeyed container is at end"
            let ctx = DecodingError.Context(codingPath: codingPath, debugDescription: dd)
            throw DecodingError.valueNotFound(JSONNull.self, ctx)
        }
        
        let elem = array.value[currentIndex]
        currentIndex += 1
        let decoder = _Decoder(json: elem, codingPath: codingPath, options: self.decoder.options)
        return try decode(decoder)
    }
}
