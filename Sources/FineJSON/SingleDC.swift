import Foundation
import RichJSONParser

internal struct SingleDC : SingleValueDecodingContainer {
    let decoder: _Decoder
    
    var json: ParsedJSON {
        return decoder.json
    }
    
    init(decoder: _Decoder, json: ParsedJSON) {
        self.decoder = decoder
    }
    
    var codingPath: [CodingKey] {
        return decoder.codingPath
    }
    
    func decodeNil() -> Bool {
        switch json.value {
        case .null: return true
        default: return false
        }
    }
    
    func decode<X>(_ type: X.Type) throws -> X where X : CodablePrimitive {
        let pd = decoder.options.primitiveDecoder
        guard let x = pd.decodePrimitive(type, from: json) else {
            let m = "decode primitive \(type) from json \(json.value.kind) failed"
            throw DecodingError.typeMismatch(type,
                                             message: m,
                                             codingPath: codingPath,
                                             location: decoder.sourceLocation)
        }
        return x
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        if type == ParsedJSON.self {
            return json as! T
        } else if type == JSON.self {
            return json.toJSON() as! T
        } else if type == JSONObject.self,
            case .object(let object) = json.value
        {
            return JSONObject(object.mapValues { $0.toJSON() }) as! T
        } else if type == JSONArray.self,
            case .array(let array) = json.value
        {
            return JSONArray(array.map { $0.toJSON() }) as! T
        } else if type == JSONNumber.self,
            case .number(let number) = json.value
        {
            return JSONNumber(number) as! T
        } else {
            let decoder = _Decoder(json: json,
                                   codingPath: self.codingPath,
                                   options: self.decoder.options,
                                   decodingType: type)
            
            return try type.init(from: decoder)
        }
    }
}
