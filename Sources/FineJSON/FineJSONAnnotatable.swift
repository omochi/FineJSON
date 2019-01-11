public protocol FineJSONAnnotatable {
    static var keyAnnotations: [String: FineJSONKeyAnnotation] { get }
}

extension FineJSONAnnotatable {
    public static var keyAnnotations: [String: FineJSONKeyAnnotation] {
        return [:]
    }
}

public struct FineJSONKeyAnnotation {
    public var jsonKey: String?
    
    public init(jsonKey: String?) {
        self.jsonKey = jsonKey
    }
}
