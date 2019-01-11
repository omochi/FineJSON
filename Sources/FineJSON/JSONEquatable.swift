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

extension JSON : Equatable {
    public static func == (a: JSON, b: JSON) -> Bool {
        switch a {
        case .object(let ao):
            if case .object(let bo) = b {
                return ao == bo
            }
        case .array(let aa):
            if case .array(let ba) = b {
                return aa == ba
            }
        case .string(let astr):
            if case .string(let bstr) = b {
                return astr == bstr
            }
        case .number(let an):
            if case .number(let bn) = b {
                return an == bn
            }
        case .boolean(let ab):
            if case .boolean(let bb) = b {
                return ab == bb
            }
        case .null:
            if case .null = b {
                return true
            }
        }
        return false
    }
}

extension JSON : Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .object(let o):
            hasher.combine(1)
            hasher.combine(o)
        case .array(let a):
            hasher.combine(2)
            hasher.combine(a)
        case .string(let s):
            hasher.combine(3)
            hasher.combine(s)
        case .number(let n):
            hasher.combine(4)
            hasher.combine(n)
        case .boolean(let b):
            hasher.combine(5)
            hasher.combine(b)
        case .null:
            hasher.combine(6)
        }
    }
}
