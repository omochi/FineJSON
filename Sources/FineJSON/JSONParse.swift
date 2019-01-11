import Foundation
import yajl
import OrderedDictionary

public struct JSONParseError : Error, CustomStringConvertible {
    public var message: String

    public init(message: String) {
        self.message = message
    }
    
    public var description: String {
        return message
    }
}

extension JSON {
    public static func parse(data: Data) throws -> JSON {
        var data = data
        data.append(0)
        var errorData = Data(count: 1024)
        let errorDataCount = errorData.count
        
        let pyj = data.withUnsafeMutableBytes { (dataPtr) in
            errorData.withUnsafeMutableBytes { (errorPtr) in
                yajl_tree_parse(dataPtr, errorPtr, errorDataCount)
            }
        }
        
        guard let yj = pyj else {
            let error = String(data: errorData, encoding: .utf8)!
            throw JSONParseError(message: error)
        }
        
        defer {
            yajl_tree_free(yj)
        }

        return JSON(yajl: yj)
    }
    
    private init(yajl: yajl_val) {
        switch yajl.pointee.type {
        case yajl_t_string:
            let str = String(utf8String: yajl.pointee.u.string)!
            self = .string(str)
        case yajl_t_number:
            let str = String(utf8String: yajl.pointee.u.number.r)!
            self = .number(JSONNumber(str))
        case yajl_t_object:
            var dict = OrderedDictionary<String, JSON>()
            let yo = yajl.pointee.u.object
            if var kp = yo.keys,
                var vp = yo.values
            {
                for _ in 0..<yo.len {
                    let key = String(utf8String: kp.pointee!)!
                    let value = JSON(yajl: vp.pointee!)
                    
                    dict[key] = value
                    
                    kp = kp.advanced(by: 1)
                    vp = vp.advanced(by: 1)
                }
            }
            self = .object(JSONObject(dict))
        case yajl_t_array:
            var array = Array<JSON>()
            let yo = yajl.pointee.u.array
            
            if var vp = yo.values {
                for _ in 0..<yo.len {
                    let value = JSON(yajl: vp.pointee!)
                    
                    array.append(value)
                    
                    vp = vp.advanced(by: 1)
                }
            }
            self = .array(JSONArray(array))
        case yajl_t_true:
            self = .boolean(true)
        case yajl_t_false:
            self = .boolean(false)
        case yajl_t_null:
            self = .null
        default:
            preconditionFailure("invalid yajl type")
        }
    }
}

