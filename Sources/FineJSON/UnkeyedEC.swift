import Foundation

internal struct UnkeyedEC : UnkeyedEncodingContainer {
    let encoder : _Encoder
    
    init(encoder: _Encoder) {
        self.encoder = encoder
        
        if case .array(let value) = encoder.box.value {
            self.value = value
        } else {
            self.value = []
        }
        
        valueDidSet()
    }
    
    var value: [BoxedJSON] {
        didSet {
            valueDidSet()
        }
    }
    
    private func valueDidSet() {
        encoder.box.value = .array(value)
    }
    
    var codingPath: [CodingKey] {
        return encoder.codingPath
    }
    
    var count: Int {
        return value.count
    }

    mutating func encodeNil() throws {
        try encodeElement { (e) in
            var c = e.singleValueContainer()
            try c.encodeNil()
        }
    }
    
    mutating func encode<T>(_ value: T) throws where T : Encodable {
        try encodeElement { (e) in
            var c = e.singleValueContainer()
            try c.encode(value)
        }
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type)
        -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey
    {
        return encodeElement { (e) in
            return e.container(keyedBy: keyType)
        }
    }
    
    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        return encodeElement { (e) in
            return e.unkeyedContainer()
        }
    }
    
    mutating func superEncoder() -> Encoder {
        return encodeElement { (e) in
            return e
        }
    }
    
    private mutating func encodeElement<R>(encode: (_Encoder) throws -> R) rethrows -> R {
        let index = self.count
        
        let codingPath = self.codingPath + [JSONArray.Index(index)]
        
        let elementBox = BoxedJSON(.null)
        
        self.value.append(elementBox)
        
        let encoder = _Encoder(codingPath: codingPath,
                               options: self.encoder.options,
                               box: elementBox,
                               encodingType: nil)
        return try encode(encoder)
    }
}
