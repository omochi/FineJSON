import Foundation
import OrderedDictionary
import RichJSONParser

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
