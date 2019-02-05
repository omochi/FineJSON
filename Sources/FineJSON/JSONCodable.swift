import RichJSONParser

extension JSONNumber : Decodable {
    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        
        do {
            let str = try c.decode(String.self)
            if let _ = Float(str) {
                // is numeric string
                self.init(str)
                return
            }
        } catch {}
        
        do {
            let float = try c.decode(Double.self)
            self.init(String(format: "%f", float))
            return
        } catch {}
        
        do {
            let int = try c.decode(Int64.self)
            self.init("\(int)")
            return
        } catch {}
        
        throw DecodingError.typeMismatch(JSONNumber.self,
                                         message: "value is not number",
                                         codingPath: decoder.codingPath,
                                         location: decoder.sourceLocation)
    }
}

extension JSONNumber : Encodable {
    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        
        if let int = Int64(value) {
            try c.encode(int)
            return
        }
        
        if let float = Double(value) {
            try c.encode(float)
            return
        }
        
        let dd = "value can not convert to number"
        let ctx = EncodingError.Context(codingPath: encoder.codingPath,
                                        debugDescription: dd)
        throw EncodingError.invalidValue(self, ctx)
    }
}

extension JSONArray : Decodable {
    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        let value = try c.decode([JSON].self)
        self.init(value)
    }
}

extension JSONArray : Encodable {
    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(value)
    }
}

extension JSONObject : Decodable {
    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        let value = try c.decode(JSONDictionary<JSON>.self)
        self.init(value)
    }
}

extension JSONObject : Encodable {
    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(value)
    }
}

extension JSON : Decodable {
    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        
        do {
            let object = try c.decode(JSONObject.self)
            self = .object(object.value)
            return
        } catch {}
        
        do {
            let array = try c.decode(JSONArray.self)
            self = .array(array.value)
            return
        } catch {}
        
        do {
            let string = try c.decode(String.self)
            self = .string(string)
            return
        } catch {}
        
        do {
            let number = try c.decode(JSONNumber.self)
            self = .number(number.value)
            return
        } catch {}
        
        do {
            let bool = try c.decode(Bool.self)
            self = .boolean(bool)
            return
        } catch {}
        
        if c.decodeNil() {
            self = .null
            return
        }
        
        throw DecodingError.typeMismatch(JSON.self,
                                         message: "any json type can not be decoded",
                                         codingPath: decoder.codingPath,
                                         location: decoder.sourceLocation)
    }
}

extension JSON : Encodable {
    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        
        switch self {
        case .object(let object): try c.encode(object)
        case .array(let array): try c.encode(array)
        case .string(let string): try c.encode(string)
        case .number(let number): try c.encode(number)
        case .boolean(let bool): try c.encode(bool)
        case .null: try c.encodeNil()
        }
    }
}

