import Foundation
import RichJSONParser

public class WeakTypingPrimitiveJSONDecoder : CodablePrimitiveJSONDecoder {
    private func decodeNSNumber(from json: ParsedJSON) -> NSNumber? {
        switch json.value {
        case .boolean(let b):
            return NSNumber(value: b)
        case .number(let num):
            return decodeNSNumber(string: num)
        case .string(let str):
            return decodeNSNumber(string: str)
        default:
            return nil
        }
    }
    
    private func decodeNSNumber(string: String) -> NSNumber? {
        let f = NumberFormatter()
        return f.number(from: string)
    }
    
    public func decode(_ type: Bool.Type, from json: ParsedJSON) -> Bool? {
        return decodeNSNumber(from: json)?.boolValue
    }
    
    public func decode(_ type: Int.Type, from json: ParsedJSON) -> Int? {
        return decodeNSNumber(from: json)?.intValue
    }
    
    public func decode(_ type: Int8.Type, from json: ParsedJSON) -> Int8? {
        return decodeNSNumber(from: json)?.int8Value
    }
    
    public func decode(_ type: Int16.Type, from json: ParsedJSON) -> Int16? {
        return decodeNSNumber(from: json)?.int16Value
    }
    
    public func decode(_ type: Int32.Type, from json: ParsedJSON) -> Int32? {
        return decodeNSNumber(from: json)?.int32Value
    }
    
    public func decode(_ type: Int64.Type, from json: ParsedJSON) -> Int64? {
        return decodeNSNumber(from: json)?.int64Value
    }
    
    public func decode(_ type: UInt.Type, from json: ParsedJSON) -> UInt? {
        return decodeNSNumber(from: json)?.uintValue
    }
    
    public func decode(_ type: UInt8.Type, from json: ParsedJSON) -> UInt8? {
        return decodeNSNumber(from: json)?.uint8Value
    }
    
    public func decode(_ type: UInt16.Type, from json: ParsedJSON) -> UInt16? {
        return decodeNSNumber(from: json)?.uint16Value
    }
    
    public func decode(_ type: UInt32.Type, from json: ParsedJSON) -> UInt32? {
        return decodeNSNumber(from: json)?.uint32Value
    }
    
    public func decode(_ type: UInt64.Type, from json: ParsedJSON) -> UInt64? {
        return decodeNSNumber(from: json)?.uint64Value
    }
    
    public func decode(_ type: Float.Type, from json: ParsedJSON) -> Float? {
        return decodeNSNumber(from: json)?.floatValue
    }
    
    public func decode(_ type: Double.Type, from json: ParsedJSON) -> Double? {
        return decodeNSNumber(from: json)?.doubleValue
    }
    
    public func decode(_ type: String.Type, from json: ParsedJSON) -> String? {
        switch json.value {
        case .number(let num):
            return num
        case .string(let str):
            return str
        default:
            return nil
        }
    }
    
}


