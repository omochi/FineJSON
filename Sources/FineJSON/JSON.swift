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
