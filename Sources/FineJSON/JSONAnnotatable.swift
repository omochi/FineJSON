import RichJSONParser

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
    public var isSourceLocationKey: Bool
    
    public init(jsonKey: String? = nil,
                defaultValue: JSON? = nil,
                isSourceLocationKey: Bool = false)
    {
        self.jsonKey = jsonKey
        self.defaultValue = defaultValue
        self.isSourceLocationKey = isSourceLocationKey
    }
}
