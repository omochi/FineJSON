import Foundation
import OrderedDictionary

internal class BoxJSON {
    enum Value {
        case null
        case boolean(Bool)
        case number(JSONNumber)
        case string(String)
        case array([BoxJSON])
        case object(OrderedDictionary<String, BoxJSON>)
        
        init(_ json: JSON) {
            switch json {
            case .null: self = .null
            case .boolean(let b): self = .boolean(b)
            case .number(let n): self = .number(n)
            case .string(let s): self = .string(s)
            case .array(let a):
                let ba = a.value.map { $0.box() }
                self = .array(ba)
            case .object(let o):
                let bo = OrderedDictionary(uniqueKeysWithValues:
                    o.value.map { (k, v: JSON) -> (String, BoxJSON) in
                        (k, v.box())
                })
                self = .object(bo)
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
            let ua = a.map { $0.unbox() }
            return .array(JSONArray(ua))
        case .object(let o):
            let uo = OrderedDictionary(uniqueKeysWithValues:
                o.map { (k, v: BoxJSON) -> (String, JSON) in
                    (k, v.unbox())
            })
            return .object(JSONObject(uo))
        }
    }
}

extension JSON {
    func box() -> BoxJSON {
        return BoxJSON(BoxJSON.Value(self))
    }
}
