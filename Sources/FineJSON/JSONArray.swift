import RichJSONParser

public struct JSONArray {
    public struct Index {
        public var value: Int
        
        public init(_ value: Int) {
            self.value = value
        }
    }
    
    public var value: [JSON]
    
    public init() {
        self.init([])
    }
    
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
