import Foundation

public class FineJSONDecoder {
    public init() {
        self.primitiveDecoder = WeakTypingPrimitiveJSONDecoder()
        self.userInfo = [:]
    }
    
    public var primitiveDecoder : CodablePrimitiveJSONDecoder
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
        let opts =  _Decoder.Options(primitiveDecoder: primitiveDecoder,
                                     userInfo: userInfo)
        let decoder = _Decoder(json: json,
                               codingPath: [],
                               options: opts,
                               decodingType: nil)
        return try decoder.singleValueContainer().decode(type)
    }
}

internal class _Decoder : Decoder {
    public struct Options {
        public var primitiveDecoder: CodablePrimitiveJSONDecoder
        public var userInfo: [CodingUserInfoKey: Any]
    }
    
    public let codingPath: [CodingKey]
    public let value: JSON
    public let options: Options
    public let decodingType: Any.Type?

    public init(json: JSON,
                codingPath: [CodingKey],
                options: Options,
                decodingType: Any.Type?)
    {
        self.value = json
        self.codingPath = codingPath
        self.options = options
        self.decodingType = decodingType
    }
    
    public var userInfo: [CodingUserInfoKey : Any] {
         return options.userInfo
    }
    
    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key>
        where Key : CodingKey
    {
        let c = try KeyedDC(decoder: self, value: value, keyType: type)
        return KeyedDecodingContainer<Key>(c)
    }
    
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return try UnkeyedDC(decoder: self, value: value)
    }
    
    public func singleValueContainer() -> SingleValueDecodingContainer {
        return SingleDC(decoder: self, value: value)
    }
}



