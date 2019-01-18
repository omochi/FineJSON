import Foundation
import RichJSONParser

public struct JSONNumber {
    public var value: String
    
    public init(_ value: String) {
        self.value = value
    }
    
    public var nsNumber: NSNumber? {
        let f = NumberFormatter()
        return f.number(from: value)
    }
}
