import Foundation
import RichJSONParser

internal struct KeyedEC<Key> : KeyedEncodingContainerProtocol where Key : CodingKey {
    let encoder: _Encoder
    
    init(encoder: _Encoder) {
        self.encoder = encoder
        
        value = JSONDictionary()
        valueDidSet()
    }
    
    var value: JSONDictionary<BoxedJSON> {
        didSet {
            valueDidSet()
        }
    }
    
    private func valueDidSet() {
        encoder.box.value = .object(value)
    }
    
    var codingPath: [CodingKey] {
        return encoder.codingPath
    }
    
    mutating func encodeNil(forKey key: Key) throws {
        try encodeElement(key: key) { (e) in
            var c = e.singleValueContainer()
            try c.encodeNil()
        }
    }

    mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        try encodeElement(key: key) { (e) in
            var c = e.singleValueContainer()
            try c.encode(value)
        }
    }

    private mutating func _encodeIfPresentGeneric<T>(_ value: T?, forKey key: Key) throws
        where T : Encodable
    {
        switch encoder.options.optionalEncodingStrategy {
        case .keyAbsence:
            guard let value = value else {
                return
            }
            try encode(value, forKey: key)
        case .explicitNull:
            if let value = value {
                try encode(value, forKey: key)
            } else {
                try encodeNil(forKey: key)
            }
        }
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key)
        -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey
    {
        return encodeElement(key: key) { (e) in
            return e.container(keyedBy: keyType)
        }
    }
    
    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        return encodeElement(key: key) { (e) in
            return e.unkeyedContainer()
        }
    }
    
    mutating func superEncoder() -> Encoder {
        return _superEncoder(forKey: JSONObject.Key.super)
    }
    
    mutating func superEncoder(forKey key: Key) -> Encoder {
        return _superEncoder(forKey: key)
    }
    
    mutating func _superEncoder(forKey key: CodingKey) -> Encoder {
        return encodeElement(key: key)
        { (e) in
            return e
        }
    }
    
    private mutating func encodeElement<R>(key: CodingKey,
                                           encode: (_Encoder) throws -> R) rethrows -> R
    {
        let codingPath = self.codingPath + [key]
        
        let originalKey = key.stringValue
        let jsonKey = self.jsonKey(for: originalKey)
        
        let elementBox = BoxedJSON(.null)
        
        if let ano = encoder.keyAnnotations?[originalKey],
            ano.isSourceLocationKey {
            // skip
        } else {
            self.value[jsonKey] = elementBox
        }
        
        let elementEncoder = _Encoder(codingPath: codingPath,
                                      options: self.encoder.options,
                                      box: elementBox,
                                      encodingType: nil)
        return try encode(elementEncoder)
    }
    
    private func jsonKey(for originalKey: String) -> String {
        if let ano = encoder.keyAnnotations?[originalKey],
            let jsonKey = ano.jsonKey
        {
            return jsonKey
        }
        
        return originalKey
    }
}

extension KeyedEC {
    mutating func encodeIfPresent(_ value: Bool?, forKey key: Key) throws {
        try _encodeIfPresentGeneric(value, forKey: key)
    }
    mutating func encodeIfPresent(_ value: Int?, forKey key: Key) throws {
        try _encodeIfPresentGeneric(value, forKey: key)
    }
    mutating func encodeIfPresent(_ value: Int8?, forKey key: Key) throws {
        try _encodeIfPresentGeneric(value, forKey: key)
    }
    mutating func encodeIfPresent(_ value: Int16?, forKey key: Key) throws {
        try _encodeIfPresentGeneric(value, forKey: key)
    }
    mutating func encodeIfPresent(_ value: Int32?, forKey key: Key) throws {
        try _encodeIfPresentGeneric(value, forKey: key)
    }
    mutating func encodeIfPresent(_ value: Int64?, forKey key: Key) throws {
        try _encodeIfPresentGeneric(value, forKey: key)
    }
    mutating func encodeIfPresent(_ value: UInt?, forKey key: Key) throws {
        try _encodeIfPresentGeneric(value, forKey: key)
    }
    mutating func encodeIfPresent(_ value: UInt8?, forKey key: Key) throws {
        try _encodeIfPresentGeneric(value, forKey: key)
    }
    mutating func encodeIfPresent(_ value: UInt16?, forKey key: Key) throws {
        try _encodeIfPresentGeneric(value, forKey: key)
    }
    mutating func encodeIfPresent(_ value: UInt32?, forKey key: Key) throws {
        try _encodeIfPresentGeneric(value, forKey: key)
    }
    mutating func encodeIfPresent(_ value: UInt64?, forKey key: Key) throws {
        try _encodeIfPresentGeneric(value, forKey: key)
    }
    mutating func encodeIfPresent(_ value: Float?, forKey key: Key) throws {
        try _encodeIfPresentGeneric(value, forKey: key)
    }
    mutating func encodeIfPresent(_ value: Double?, forKey key: Key) throws {
        try _encodeIfPresentGeneric(value, forKey: key)
    }
    mutating func encodeIfPresent(_ value: String?, forKey key: Key) throws {
        try _encodeIfPresentGeneric(value, forKey: key)
    }
    mutating func encodeIfPresent<T>(_ value: T?, forKey key: Key) throws where T : Encodable {
        return try _encodeIfPresentGeneric(value, forKey: key)
    }
}
