import OrderedDictionary
import RichJSONParser

extension SourceLocation {
    public func encodeToJSON() -> JSON {
        return JSON.object(OrderedDictionary([
            "offset": .number("\(offset)"),
            "line": .number("\(line)"),
            "columnInByte": .number("\(columnInByte)")
            ]))
    }
}
