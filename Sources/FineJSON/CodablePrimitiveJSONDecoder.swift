import RichJSONParser

public protocol CodablePrimitiveJSONDecoder {
    func decode(_ type: Bool.Type, from json: ParsedJSON) -> Bool?
    func decode(_ type: Int.Type, from json: ParsedJSON) -> Int?
    func decode(_ type: Int8.Type, from json: ParsedJSON) -> Int8?
    func decode(_ type: Int16.Type, from json: ParsedJSON) -> Int16?
    func decode(_ type: Int32.Type, from json: ParsedJSON) -> Int32?
    func decode(_ type: Int64.Type, from json: ParsedJSON) -> Int64?
    func decode(_ type: UInt.Type, from json: ParsedJSON) -> UInt?
    func decode(_ type: UInt8.Type, from json: ParsedJSON) -> UInt8?
    func decode(_ type: UInt16.Type, from json: ParsedJSON) -> UInt16?
    func decode(_ type: UInt32.Type, from json: ParsedJSON) -> UInt32?
    func decode(_ type: UInt64.Type, from json: ParsedJSON) -> UInt64?
    func decode(_ type: Float.Type, from json: ParsedJSON) -> Float?
    func decode(_ type: Double.Type, from json: ParsedJSON) -> Double?
    func decode(_ type: String.Type, from json: ParsedJSON) -> String?
}

extension CodablePrimitiveJSONDecoder {
    internal func decodePrimitive<X: CodablePrimitive>(_ type: X.Type, from json: ParsedJSON) -> X? {
        typealias R = X?
        
        switch type {
        case let type as Bool.Type: return decode(type, from: json) as! R
        case let type as Int.Type: return decode(type, from: json) as! R
        case let type as Int8.Type: return decode(type, from: json) as! R
        case let type as Int16.Type: return decode(type, from: json) as! R
        case let type as Int32.Type: return decode(type, from: json) as! R
        case let type as Int64.Type: return decode(type, from: json) as! R
        case let type as UInt.Type: return decode(type, from: json) as! R
        case let type as UInt8.Type: return decode(type, from: json) as! R
        case let type as UInt16.Type: return decode(type, from: json) as! R
        case let type as UInt32.Type: return decode(type, from: json) as! R
        case let type as UInt64.Type: return decode(type, from: json) as! R
        case let type as Float.Type: return decode(type, from: json) as! R
        case let type as Double.Type: return decode(type, from: json) as! R
        case let type as String.Type: return decode(type, from: json) as! R
        default:
            preconditionFailure("invalid type")
        }
    }
}
