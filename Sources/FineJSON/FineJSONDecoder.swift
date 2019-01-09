import Foundation

public class FineJSONDecoder {
    public init() {
        self.primitiveTypeDecoder = WeakTypeDecoder()
    }
    
    public var primitiveTypeDecoder : PrimitiveTypeDecoder
    
    public func decode<T>(_ type: T.Type, from data: Data) throws -> T
        where T : Decodable
    {
        let json = try JSON.parse(data: data)
        return try decode(type, from: json)
    }
    
    public func decode<T>(_ type: T.Type, from json: JSON) throws -> T
        where T : Decodable
    {
        let decoder = _Decoder(json: json,
                               ptd: primitiveTypeDecoder)
        return try type.init(from: decoder)
    }
}

internal class _Decoder : Decoder {
    public var codingPath: [CodingKey]
    
    public var userInfo: [CodingUserInfoKey : Any]

    public let root: JSON
    public var current: JSON
    public let ptd: PrimitiveTypeDecoder

    public init(json: JSON,
                ptd: PrimitiveTypeDecoder)
    {
        self.root = json
        self.current = json
        self.ptd = ptd
        self.codingPath = []
    }
    
    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key>
        where Key : CodingKey
    {
        <#code#>
    }
    
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        <#code#>
    }
    
    public func singleValueContainer() -> SingleValueDecodingContainer {
        return self
    }
}

extension _Decoder : SingleValueDecodingContainer {
    func decodeNil() -> Bool {
        switch current {
        case .null: return true
        default: return false
        }
    }

    func decode<X>(_ type: X.Type) throws -> X where X : PrimitiveValue, X : Decodable {
        guard let x = ptd.decodePrimitive(type, from: current) else {
            let dd = "decode \(type) from json \(current.typeName) failed"
            let ctx = DecodingError.Context(codingPath: codingPath,
                                            debugDescription: dd)
            throw DecodingError.typeMismatch(type, ctx)
        }
        return x
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        return try type.init(from: self)
    }
    
}
