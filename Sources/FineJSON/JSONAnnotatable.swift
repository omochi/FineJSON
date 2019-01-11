
public typealias JSONKeyAnnotations = [String: JSONKeyAnnotation]

public protocol JSONAnnotatable {
    static var keyAnnotations: JSONKeyAnnotations { get }
}

extension JSONAnnotatable {
    public static var keyAnnotations: JSONKeyAnnotations {
        return [:]
    }
}

public struct JSONKeyAnnotation {
    public var jsonKey: String?
    public var defaultValue: JSON?
    
    public init(jsonKey: String? = nil,
                defaultValue: JSON? = nil)
    {
        self.jsonKey = jsonKey
        self.defaultValue = defaultValue
    }
}
