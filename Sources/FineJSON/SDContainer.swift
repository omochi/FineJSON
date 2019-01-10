import Foundation

internal struct SDContainer : SingleValueDecodingContainer {
    let decoder: _Decoder
    
    var value: JSON {
        return decoder.value
    }
    
    init(decoder: _Decoder, value: JSON) {
        self.decoder = decoder
    }
    
    var codingPath: [CodingKey] {
        return decoder.codingPath
    }
    
    func decodeNil() -> Bool {
        switch value {
        case .null: return true
        default: return false
        }
    }
    
    func decode<X>(_ type: X.Type) throws -> X where X : CodablePrimitive, X : Decodable {
        let pd = decoder.options.primitiveDecoder
        guard let x = pd.decodePrimitive(type, from: value) else {
            let dd = "decode \(type) from json \(value.typeName) failed"
            let ctx = DecodingError.Context(codingPath: codingPath,
                                            debugDescription: dd)
            throw DecodingError.typeMismatch(type, ctx)
        }
        return x
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        return try type.init(from: decoder)
    }
}
