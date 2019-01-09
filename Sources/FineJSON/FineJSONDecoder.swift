import Foundation

public class FineJSONDecoder {
    public init() {
        self.primitiveTypeDecoder = WeakTypeDecoder()
        self.userInfo = [:]
    }
    
    public var primitiveTypeDecoder : PrimitiveTypeDecoder
    public var userInfo: [CodingUserInfoKey: Any]
    
    public func decode<T>(_ type: T.Type, from data: Data) throws -> T
        where T : Decodable
    {
        let json = try JSON.parse(data: data)
        return try decode(type, from: json)
    }
    
    public func decode<T>(_ type: T.Type, from json: JSON) throws -> T
        where T : Decodable
    {
        let opts =  _Decoder.Options(primitiveTypeDecoder: primitiveTypeDecoder,
                                     userInfo: userInfo)
        let decoder = _Decoder(json: json,
                               codingPath: [],
                               options: opts)
        return try type.init(from: decoder)
    }
}

internal class _Decoder : Decoder {
    public struct Options {
        public var primitiveTypeDecoder: PrimitiveTypeDecoder
        public var userInfo: [CodingUserInfoKey: Any]
    }
    
    public let codingPath: [CodingKey]
    public let value: JSON
    public let options: Options

    public init(json: JSON,
                codingPath: [CodingKey],
                options: Options)
    {
        self.value = json
        self.codingPath = codingPath
        self.options = options
    }
    
    public var userInfo: [CodingUserInfoKey : Any] {
         return options.userInfo
    }
    
    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key>
        where Key : CodingKey
    {
        let c = try KDContainer(decoder: self, value: value, keyType: type)
        return KeyedDecodingContainer<Key>(c)
    }
    
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return try UDContainer(decoder: self, value: value)
    }
    
    public func singleValueContainer() -> SingleValueDecodingContainer {
        return SDContainer(decoder: self, value: value)
    }
}



