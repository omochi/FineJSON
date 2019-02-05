import RichJSONParser

public struct JSONObject {
    public struct Key {
        public var value: String
        
        public init(_ value: String) {
            self.value = value
        }
        
        public static let `super`: Key = Key("super")
    }
    
    public var value: JSONDictionary<JSON>
    
    public init() {
        self.init(JSONDictionary())
    }
    
    public init(_ value: JSONDictionary<JSON>) {
        self.value = value
    }
    
    public init(_ keyAndValues: KeyValuePairs<String, JSON>) {
        self.init(JSONDictionary(keyAndValues))
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
