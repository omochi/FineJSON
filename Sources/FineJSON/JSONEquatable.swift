import RichJSONParser

extension JSONNumber : Equatable {
    public static func == (a: JSONNumber, b: JSONNumber) -> Bool {
        return a.value == b.value
    }
}

extension JSONNumber : Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}

extension JSONArray : Equatable {
    public static func == (a: JSONArray, b: JSONArray) -> Bool {
        return a.value == b.value
    }
}

extension JSONArray : Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}

extension JSONObject : Equatable {
    public static func == (a: JSONObject, b: JSONObject) -> Bool {
        return a.value == b.value
    }
}

extension JSONObject : Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}
