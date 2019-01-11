import Foundation

internal struct SingleDC : SingleValueDecodingContainer {
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
    
    func decode<X>(_ type: X.Type) throws -> X where X : CodablePrimitive {
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
        if type == JSON.self {
            return value as! T
        }
        if type == JSONObject.self,
            case .object(let object) = value
        {
            return object as! T
        }
        if type == JSONArray.self,
            case .array(let array) = value
        {
            return array as! T
        }
        if type == JSONNumber.self,
            case .number(let number) = value
        {
            return number as! T
        }
        
        let decoder = _Decoder(json: self.value,
                               codingPath: self.codingPath,
                               options: self.decoder.options,
                               decodingType: type)
        
        return try type.init(from: decoder)
    }
}
