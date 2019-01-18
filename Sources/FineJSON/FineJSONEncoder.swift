import Foundation
import RichJSONParser

public class FineJSONEncoder {
    public enum OptionalEncodingStrategy {
        case keyAbsence
        case explicitNull
    }
    
    public init() {
        self.jsonSerializeOptions = JSONSerializeOptions()
        self.optionalEncodingStrategy = .keyAbsence
        self.userInfo = [:]
    }
    
    public var jsonSerializeOptions: JSONSerializeOptions
    public var optionalEncodingStrategy: OptionalEncodingStrategy
    public var userInfo: [CodingUserInfoKey: Any]
    
    public func encode<T>(_ value: T) throws -> Data
        where T : Encodable
    {
        let json = try encodeToJSON(value)
        let serializer = JSONSerializer()
        serializer.options = jsonSerializeOptions
        return serializer.serialize(json)
    }
    
    public func encodeToJSON<T>(_ value: T) throws -> JSON
        where T : Encodable
    {
        let box = BoxedJSON(.null)
        let opts = _Encoder.Options(
            optionalEncodingStrategy: optionalEncodingStrategy,
            userInfo: userInfo)
        let encoder = _Encoder(codingPath: [],
                               options: opts,
                               box: box,
                               encodingType: nil)
        var c = encoder.singleValueContainer()
        try c.encode(value)
        return box.unbox()
    }
}

internal class _Encoder : Swift.Encoder {
    public struct Options {
        public var optionalEncodingStrategy: FineJSONEncoder.OptionalEncodingStrategy
        public var userInfo: [CodingUserInfoKey: Any]
    }
    
    public let codingPath: [CodingKey]
    public let options: Options
    public let box: BoxedJSON
    public let encodingType: Any.Type?
    public let keyAnnotations: JSONKeyAnnotations?
    
    public init(codingPath: [CodingKey],
                options: Options,
                box: BoxedJSON,
                encodingType: Any.Type?)
    {
        self.codingPath = codingPath
        self.options = options
        self.box = box
        self.encodingType = encodingType
        self.keyAnnotations = (encodingType as? JSONAnnotatable.Type)?.keyAnnotations
    }
    
    public var userInfo: [CodingUserInfoKey : Any] {
        return options.userInfo
    }
    
    public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key>
        where Key : CodingKey
    {
        let c = KeyedEC<Key>(encoder: self)
        return KeyedEncodingContainer(c)
    }
    
    public func unkeyedContainer() -> UnkeyedEncodingContainer
    {
        return UnkeyedEC(encoder: self)
    }
    
    public func singleValueContainer() -> SingleValueEncodingContainer {
        return SingleEC(encoder: self)
    }

}
