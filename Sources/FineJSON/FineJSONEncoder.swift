import Foundation

public class FineJSONEncoder {
    public init() {
        self.jsonSerializeOptions = JSONSerializeOptions()
        self.userInfo = [:]
    }
    
    public var jsonSerializeOptions: JSONSerializeOptions
    public var userInfo: [CodingUserInfoKey: Any]
    
    public func encode<T>(_ value: T) throws -> Data
        where T : Encodable
    {
        let json = try encodeToJSON(value)
        return try json.serialize(options: jsonSerializeOptions)
    }
    
    public func encodeToJSON<T>(_ value: T) throws -> JSON
        where T : Encodable
    {
        let box = BoxJSON(.null)
        let opts = _Encoder.Options(userInfo: userInfo)
        let encoder = _Encoder(codingPath: [],
                               options: opts,
                               box: box)
        var c = encoder.singleValueContainer()
        try c.encode(value)
        return box.unbox()
    }
}

internal class _Encoder : Swift.Encoder {
    public struct Options {
        public var userInfo: [CodingUserInfoKey: Any]
    }
    
    public let codingPath: [CodingKey]
    public let options: Options
    public let box: BoxJSON
    
    public init(codingPath: [CodingKey],
                options: Options,
                box: BoxJSON)
    {
        self.codingPath = codingPath
        self.options = options
        self.box = box
    }
    
    public var userInfo: [CodingUserInfoKey : Any] {
        return options.userInfo
    }
    
    public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key>
        where Key : CodingKey
    {
        let c = KEContainer<Key>(encoder: self)
        return KeyedEncodingContainer(c)
    }
    
    public func unkeyedContainer() -> UnkeyedEncodingContainer
    {
        return UEContainer(encoder: self)
    }
    
    public func singleValueContainer() -> SingleValueEncodingContainer {
        return SEContainer(encoder: self)
    }
}
