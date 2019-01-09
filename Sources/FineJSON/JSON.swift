import OrderedDictionary

public enum JSON {
    case null
    case boolean(Bool)
    case number(String)
    case string(String)
    case array([JSON])
    case object(OrderedDictionary<String, JSON>)
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
