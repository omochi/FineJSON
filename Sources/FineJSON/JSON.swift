import Foundation
import OrderedDictionary

public enum JSON {
    case null
    case boolean(Bool)
    case number(JSONNumber)
    case string(String)
    case array(JSONArray)
    case object(JSONObject)
}

extension JSON {
    internal var typeName: String {
        switch self {
        case .null: return "null"
        case .boolean: return "boolean"
        case .number: return "number"
        case .string: return "string"
        case .array: return "array"
        case .object: return "object"
        }
    }
}

public struct JSONNumber {
    public var value: String
    
    public init(_ value: String) {
        self.value = value
    }
    
    public var nsNumber: NSNumber? {
        let f = NumberFormatter()
        return f.number(from: value)
    }
}

public struct JSONArray {
    public struct Index {
        public var value: Int
        
        public init(_ value: Int) {
            self.value = value
        }
    }
    
    public var value: [JSON]
    
    public init(_ value: [JSON]) {
        self.value = value
    }
}

extension JSONArray.Index : CodingKey {
    public var intValue: Int? {
        return value
    }
    
    public init(intValue: Int) {
        self.init(intValue)
    }
    
    public var stringValue: String {
        return "\(value)"
    }
    
    public init?(stringValue: String) {
        return nil
    }
}

public struct JSONObject {
    public struct Key {
        public var value: String
        
        public init(_ value: String) {
            self.value = value
        }
    }
    
    public var value: OrderedDictionary<String, JSON>
    
    public init(_ value: OrderedDictionary<String, JSON>) {
        self.value = value
    }
}

extension JSONObject.Key : CodingKey {
    public var stringValue: String {
        return value
    }
    
    public init?(stringValue: String) {
        self.init(stringValue)
    }
    
    public var intValue: Int? {
        return nil
    }

    public init?(intValue: Int) {
        return nil
    }
}

extension JSONNumber : Decodable {
    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        
        do {
            let str = try c.decode(String.self)
            if let _ = Float(str) {
                // is numeric string
                self.init(str)
                return
            }
        } catch {}
        
        do {
            let float = try c.decode(Double.self)
            self.init(String(format: "%f", float))
            return
        } catch {}
        
        do {
            let int = try c.decode(Int64.self)
            self.init("\(int)")
            return
        } catch {}
        
        let dd = "value is not number"
        let ctx = DecodingError.Context(codingPath: decoder.codingPath,
                                        debugDescription: dd)
        throw DecodingError.typeMismatch(JSONNumber.self, ctx)
    }
}

extension JSONNumber : Encodable {
    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        
        if let int = Int64(value) {
            try c.encode(int)
            return
        }
        
        if let float = Double(value) {
            try c.encode(float)
            return
        }
        
        let dd = "value can not convert to number"
        let ctx = EncodingError.Context(codingPath: encoder.codingPath,
                                        debugDescription: dd)
        throw EncodingError.invalidValue(self, ctx)
    }
}
