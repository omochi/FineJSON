import Foundation
import OrderedDictionary

internal struct KEContainer<Key> : KeyedEncodingContainerProtocol where Key : CodingKey {
    let encoder: _Encoder
    
    init(encoder: _Encoder) {
        self.encoder = encoder
        
        value = OrderedDictionary()
        valueDidSet()
    }
    
    var value: OrderedDictionary<String, BoxJSON> {
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
        
        let elementBox = BoxJSON(.null)
        
        let strKey = key.stringValue
        
        self.value[strKey] = elementBox
        
        let encoder = _Encoder(codingPath: codingPath,
                               options: self.encoder.options,
                               box: elementBox)
        return try encode(encoder)
    }
    
}
