import Foundation

internal struct KDContainer<Key> : KeyedDecodingContainerProtocol
    where Key : CodingKey
{
    let decoder: _Decoder
    
    let object: JSONObject
    
    init(decoder: _Decoder, value: JSON, keyType: Key.Type) throws {
        self.decoder = decoder
        
        switch value {
        case .object(let value):
            self.object = value
        default:
            let dd = "expected object but \(value.typeName)"
            let ctx = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: dd)
            throw DecodingError.typeMismatch(JSONObject.self, ctx)
        }
    }
    
    var codingPath: [CodingKey] {
        return decoder.codingPath
    }
    
    var allKeys: [Key] {
        return object.value.keys.compactMap { Key(stringValue: $0) }
    }
    
    func contains(_ key: Key) -> Bool {
        return object.value[key.stringValue] != nil
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        return try decodeElement(key: key,
                                 noKey: noKeyIsNil)
        { (d) in
            return d.singleValueContainer().decodeNil()
        }
    }
    
    func decode<X>(_ type: X.Type, forKey key: Key) throws -> X where X : CodablePrimitive {
        return try decodeElement(key: key,
                                 noKey: throwNoKeyError)
        { (d) in
            return try d.singleValueContainer().decode(type)
        }
    }
    
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        return try decodeElement(key: key,
                                 noKey: throwNoKeyError)
        { (d) in
            return try d.singleValueContainer().decode(type)
        }
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key)
        throws -> KeyedDecodingContainer<NestedKey>
        where NestedKey : CodingKey
    {
        return try decodeElement(key: key,
                                 noKey: throwNoKeyError)
        { (d) in
            return try d.container(keyedBy: type)
        }
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        return try decodeElement(key: key,
                                 noKey: throwNoKeyError)
        { (d) in
            return try d.unkeyedContainer()
        }
    }
    
    func superDecoder() throws -> Decoder {
        return try _superDecoder(key: JSONObject.Key("super"))
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        return try _superDecoder(key: key)
    }
    
    private func _superDecoder(key: CodingKey) throws -> Decoder {
        return try decodeElement(key: key,
                                 noKey: throwNoKeyError)
        { (d) in
            return d
        }
    }
    
    private func decodeElement<R>(key: CodingKey,
                                  noKey: (CodingKey, [CodingKey]) throws -> R,
                                  decode: (_Decoder) throws -> R) throws -> R
    {
        let keyStr = key.stringValue
        
        let codingPath = self.codingPath + [key]
        
        guard let elem = object.value[keyStr] else {
            return try noKey(key, codingPath)
        }
        
        let decoder = _Decoder(json: elem, codingPath: codingPath, options: self.decoder.options)
        return try decode(decoder)
    }
    
    private func noKeyIsNil(key: CodingKey, codingPath: [CodingKey]) -> Bool {
        return true
    }
    
    private func throwNoKeyError<R>(key: CodingKey, codingPath: [CodingKey]) throws -> R {
        let dd = "No value associated with key \(key.stringValue)"
        let ctx = DecodingError.Context(codingPath: codingPath, debugDescription: dd)
        throw DecodingError.keyNotFound(key, ctx)
    }
}
