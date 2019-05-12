import Foundation
import RichJSONParser

extension ParsedJSON : Decodable {
    public init(from decoder: Decoder) throws {
        if let json = decoder.json {
            self = json
            return
        }
        
        let c = try decoder.singleValueContainer()
        let json = try c.decode(JSON.self)
        self = json.toParsedJSON(dummyLocation: SourceLocationLite())
    }
}

extension ParsedJSON : Encodable {
    public func encode(to encoder: Encoder) throws {
        let json = toJSON()
        var c = encoder.singleValueContainer()
        try c.encode(json)
    }
}
