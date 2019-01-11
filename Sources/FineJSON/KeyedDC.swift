import Foundation

internal struct KeyedDC<Key> : KeyedDecodingContainerProtocol
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
        return decodeElement(key: key,
                             noKey: noKeyIsNil)
        { (d) in
            return d.singleValueContainer().decodeNil()
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
        return try _superDecoder(forKey: JSONObject.Key.super)
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        return try _superDecoder(forKey: key)
    }
    
    func _superDecoder(forKey key: CodingKey) throws -> Decoder {
        return try decodeElement(key: key,
                                 noKey: throwNoKeyError)
        { (d) in
            return d
        }
    }
    
    private func decodeElement<R>(key: CodingKey,
                                  noKey: (CodingKey, [CodingKey]) throws -> R,
                                  decode: (_Decoder) throws -> R) rethrows -> R
    {
        let codingPath = self.codingPath + [key]

        let jsonKey = self.decoder.jsonKey(for: key)
        
        guard let elem = object.value[jsonKey] else {
            return try noKey(key, codingPath)
        }
        
        let decoder = _Decoder(json: elem,
                               codingPath: codingPath,
                               options: self.decoder.options,
                               decodingType: nil)
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
