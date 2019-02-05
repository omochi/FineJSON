import RichJSONParser

extension SourceLocation {
    public func encodeToJSON() -> JSON {
        return JSON.object(JSONDictionary([
            "offset": .number("\(offset)"),
            "line": .number("\(line)"),
            "columnInByte": .number("\(columnInByte)")
            ]))
    }
}
