import Foundation

public class WeakTypingPrimitiveJSONDecoder : CodablePrimitiveJSONDecoder {
    private func decodeNSNumber(from json: JSON) -> NSNumber? {
        switch json {
        case .boolean(let b):
            return NSNumber(value: b)
        case .number(let str),
             .string(let str):
            let f = NumberFormatter()
            return f.number(from: str)
        default:
            return nil
        }
    }
    
    public func decode(_ type: Bool.Type, from json: JSON) -> Bool? {
        return decodeNSNumber(from: json)?.boolValue
    }
    
    public func decode(_ type: Int.Type, from json: JSON) -> Int? {
        return decodeNSNumber(from: json)?.intValue
    }
    
    public func decode(_ type: Int8.Type, from json: JSON) -> Int8? {
        return decodeNSNumber(from: json)?.int8Value
    }
    
    public func decode(_ type: Int16.Type, from json: JSON) -> Int16? {
        return decodeNSNumber(from: json)?.int16Value
    }
    
    public func decode(_ type: Int32.Type, from json: JSON) -> Int32? {
        return decodeNSNumber(from: json)?.int32Value
    }
    
    public func decode(_ type: Int64.Type, from json: JSON) -> Int64? {
        return decodeNSNumber(from: json)?.int64Value
    }
    
    public func decode(_ type: UInt.Type, from json: JSON) -> UInt? {
        return decodeNSNumber(from: json)?.uintValue
    }
    
    public func decode(_ type: UInt8.Type, from json: JSON) -> UInt8? {
        return decodeNSNumber(from: json)?.uint8Value
    }
    
    public func decode(_ type: UInt16.Type, from json: JSON) -> UInt16? {
        return decodeNSNumber(from: json)?.uint16Value
    }
    
    public func decode(_ type: UInt32.Type, from json: JSON) -> UInt32? {
        return decodeNSNumber(from: json)?.uint32Value
    }
    
    public func decode(_ type: UInt64.Type, from json: JSON) -> UInt64? {
        return decodeNSNumber(from: json)?.uint64Value
    }
    
    public func decode(_ type: Float.Type, from json: JSON) -> Float? {
        return decodeNSNumber(from: json)?.floatValue
    }
    
    public func decode(_ type: Double.Type, from json: JSON) -> Double? {
        return decodeNSNumber(from: json)?.doubleValue
    }
    
    public func decode(_ type: String.Type, from json: JSON) -> String? {
        switch json {
        case .number(let str),
             .string(let str):
            return str
        default:
            return nil
        }
    }
    
}


