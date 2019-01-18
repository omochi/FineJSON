import Foundation
import OrderedDictionary
import RichJSONParser

internal struct KeyedDC<Key> : KeyedDecodingContainerProtocol
    where Key : CodingKey
{
    let decoder: _Decoder
    
    let object: JSONObject
    
    init(decoder: _Decoder, value: JSON, keyType: Key.Type) throws {
        self.decoder = decoder
        
        switch value {
        case .object(let value):
            self.object = JSONObject(value)
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
        let origKey = key.stringValue
        let jsonKey = self.jsonKey(for: origKey)
        let jsonValue = self.jsonValue(for: origKey, jsonKey: jsonKey)
        return jsonValue != nil
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        return decodeElement(key: key,
                             noKeyHandler: noKeyIsNil)
        { (d) in
            return d.singleValueContainer().decodeNil()
        }
    }
    
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        return try decodeElement(key: key,
                                 noKeyHandler: throwNoKeyError)
        { (d) in
            return try d.singleValueContainer().decode(type)
        }
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key)
        throws -> KeyedDecodingContainer<NestedKey>
        where NestedKey : CodingKey
    {
        return try decodeElement(key: key,
                                 noKeyHandler: throwNoKeyError)
        { (d) in
            return try d.container(keyedBy: type)
        }
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        return try decodeElement(key: key,
                                 noKeyHandler: throwNoKeyError)
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
                                 noKeyHandler: throwNoKeyError)
        { (d) in
            return d
        }
    }
    
    private func decodeElement<R>(key: CodingKey,
                                  noKeyHandler: (String, [CodingKey]) throws -> R,
                                  decode: (_Decoder) throws -> R) rethrows -> R
    {
        let codingPath = self.codingPath + [key]

        let origKey = key.stringValue
        
        let jsonKey = self.jsonKey(for: origKey)
        
        guard let elem = jsonValue(for: origKey, jsonKey: jsonKey) else {
            return try noKeyHandler(jsonKey, codingPath)
        }
        
        let decoder = _Decoder(json: elem,
                               codingPath: codingPath,
                               options: self.decoder.options,
                               decodingType: nil)
        return try decode(decoder)
    }
    
    private func jsonKey(for originalKey: String) -> String {
        if let ano = keyAnnotations(originalKey: originalKey),
            let jsonKey = ano.jsonKey
        {
            return jsonKey
        }
        
        return originalKey
    }
    
    private func jsonValue(for originalKey: String, jsonKey: String) -> JSON? {
        if let elem = object.value[jsonKey] {
            return elem
        }
        
        if let ano = keyAnnotations(originalKey: originalKey),
            let def = ano.defaultValue
        {
            return def
        }
        
        return nil
    }
    
    private func keyAnnotations(originalKey: String) -> JSONKeyAnnotation? {
        guard let type = decoder.decodingType,
            let anoType = type as? JSONAnnotatable.Type,
            let ano = anoType.keyAnnotations[originalKey] else
        {
            return nil
        }
        return ano
    }
    
    private func noKeyIsNil(jsonKey: String, codingPath: [CodingKey]) -> Bool {
        return true
    }
    
    private func throwNoKeyError<R>(jsonKey: String, codingPath: [CodingKey]) throws -> R {
        let dd = "No value associated with key \(jsonKey)"
        let ctx = DecodingError.Context(codingPath: codingPath, debugDescription: dd)
        throw DecodingError.keyNotFound(JSONObject.Key(jsonKey), ctx)
    }
}
