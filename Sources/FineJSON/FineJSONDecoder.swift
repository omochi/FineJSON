import Foundation
import RichJSONParser

public class FineJSONDecoder {
    public init() {
        self.primitiveDecoder = WeakTypingPrimitiveJSONDecoder()
        self.userInfo = [:]
    }
    
    public var primitiveDecoder : CodablePrimitiveJSONDecoder
    public var userInfo: [CodingUserInfoKey: Any]
    public var file: URL?
    
    public func decode<T>(_ type: T.Type, from data: Data) throws -> T
        where T : Decodable
    {
        let parser = FastJSONParser(data: data, file: file)
        let json = try parser.parse()
        return try decode(type, from: json)
    }
    
    public func decode<T>(_ type: T.Type, from json: ParsedJSON) throws -> T
        where T : Decodable
    {
        let opts =  _Decoder.Options(primitiveDecoder: primitiveDecoder,
                                     userInfo: userInfo)
        let decoder = _Decoder(json: json,
                               file: file,
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
    public let file: URL?
    public let options: Options
    public let decodingType: Any.Type?
    public let keyAnnotations: JSONKeyAnnotations?

    public init(json: ParsedJSON,
                file: URL?,
                codingPath: [CodingKey],
                options: Options,
                decodingType: Any.Type?)
    {
        self._json = json
        self.file = file
        self.codingPath = codingPath
        self.options = options
        self.decodingType = decodingType
        self.keyAnnotations = (decodingType as? JSONAnnotatable.Type)?.keyAnnotations
    }
    
    public var _sourceLocation: SourceLocation {
        return _json.location.with(file: file)
    }
    
    public let _json: ParsedJSON
    
    public var userInfo: [CodingUserInfoKey : Any] {
         return options.userInfo
    }
    
    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key>
        where Key : CodingKey
    {
        let c = try KeyedDC(decoder: self, json: _json, keyType: type)
        return KeyedDecodingContainer<Key>(c)
    }
    
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return try UnkeyedDC(decoder: self, json: _json)
    }
    
    public func singleValueContainer() -> SingleValueDecodingContainer {
        return SingleDC(decoder: self, json: _json)
    }
}



