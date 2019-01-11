import Foundation
import yajl

public struct JSONSerializeError : Error {
    public var message: String
    
    public init(message: String) {
        self.message = message
    }
}

extension yajl_gen_status {
    internal var description: String {
        switch self {
        case yajl_gen_status_ok:
            return "no error"
        case yajl_gen_keys_must_be_strings:
            return "at a point where a map key is generated, " +
            "a function other than yajl_gen_string was called"
        case yajl_max_depth_exceeded:
            return "YAJL's maximum generation depth was exceeded."
        case yajl_gen_in_error_state:
            return "A generator function (yajl_gen_XXX) was called while in an error state"
        case yajl_gen_generation_complete:
            return "A complete JSON document has been generated"
        case yajl_gen_invalid_number:
            return "yajl_gen_double was passed an invalid floating point value (infinity or NaN)."
        case yajl_gen_no_buf:
            return "A print callback was passed in, so there is no internal buffer to get from"
        case yajl_gen_invalid_string:
            return "an invalid was passed by client code"
        default:
            fatalError("invalid yajl_gen_status")
        }
    }
    
    internal func check() throws {
        switch self {
        case yajl_gen_status_ok,
             yajl_gen_generation_complete:
            return
        default:
            throw JSONSerializeError(message: self.description)
        }
    }
}

extension JSON {
    public struct SerializeOptions {
        public var isPrettyPrint: Bool
        public var indentString: String
        
        public init(isPrettyPrint: Bool = true,
                    indentString: String = "  ")
        {
            self.isPrettyPrint = isPrettyPrint
            self.indentString = indentString
        }
    }
}

extension JSON {
    public func serialize(options: SerializeOptions) throws -> Data {
        let yg = yajl_gen_alloc(nil)!
        defer {
            yajl_gen_free(yg)
        }
        
        let y_beautify: CInt = options.isPrettyPrint ? 1 : 0
        _ = withVaList([y_beautify]) { (ap) in
            yajl_gen_config_v(yg, yajl_gen_beautify, ap)
        }
        
        var indentString = options.indentString.utf8CString
        
        try indentString.withUnsafeBufferPointer { (indentString) in
            _ = withVaList([indentString.baseAddress!]) { (ap) in
                yajl_gen_config_v(yg, yajl_gen_indent_string, ap)
            }

            try serialize(yajl_gen: yg)
        }
        
        let result: Data

        do {
            var buf: UnsafePointer<UInt8>? = nil
            var len: Int = 0
            try yajl_gen_get_buf(yg, &buf, &len).check()
            defer {
                yajl_gen_clear(yg)
            }
            result = Data(bytes: buf!, count: len)
        }
        
        return result
    }

    private func serialize(yajl_gen yg: yajl_gen) throws {
        switch self {
        case .null:
            try yajl_gen_null(yg).check()
        case .boolean(let b):
            try yajl_gen_bool(yg, b ? 1 : 0).check()
        case .number(let num):
            try num.value.utf8CString.withUnsafeBufferPointer { (str) in
                yajl_gen_number(yg, str.baseAddress, str.count - 1)
                }.check()
        case .string(let str):
            try str.serialize(yajl_gen: yg)
        case .array(let array):
            try yajl_gen_array_open(yg).check()
            for elem in array.value {
                try elem.serialize(yajl_gen: yg)
            }
            try yajl_gen_array_close(yg).check()
        case .object(let object):
            try yajl_gen_map_open(yg).check()
            for (k, v) in object.value {
                try k.serialize(yajl_gen: yg)
                try v.serialize(yajl_gen: yg)
            }
            try yajl_gen_map_close(yg).check()
        }
    }
}

extension String {
    internal func serialize(yajl_gen yg: yajl_gen) throws {
        try self.utf8CString.withUnsafeBufferPointer { (str) in
            str.withMemoryRebound(to: UInt8.self) { (str) in
                yajl_gen_string(yg, str.baseAddress, str.count - 1)
            }
            }.check()
    }
}
