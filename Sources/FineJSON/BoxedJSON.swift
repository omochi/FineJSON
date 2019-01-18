import Foundation
import OrderedDictionary
import RichJSONParser

internal class BoxedJSON {
    enum Value {
        case null
        case boolean(Bool)
        case number(String)
        case string(String)
        case array([BoxedJSON])
        case object(OrderedDictionary<String, BoxedJSON>)
        
        init(_ json: JSON) {
            switch json {
            case .null: self = .null
            case .boolean(let b): self = .boolean(b)
            case .number(let n): self = .number(n)
            case .string(let s): self = .string(s)
            case .array(let a):
                self = .array(a.map { $0.box() })
            case .object(let o):
                self = .object(o.mapValues { $0.box() })
            }
        }
    }
    
    var value: Value
    
    init(_ value: Value) {
        self.value = value
    }
    
    func unbox() -> JSON {
        switch value {
        case .null: return .null
        case .boolean(let b): return .boolean(b)
        case .number(let n): return .number(n)
        case .string(let s): return .string(s)
        case .array(let a):
            return .array(a.map { $0.unbox() })
        case .object(let o):
            return .object(o.mapValues { $0.unbox() })
        }
    }
}

extension JSON {
    func box() -> BoxedJSON {
        return BoxedJSON(BoxedJSON.Value(self))
    }
}
