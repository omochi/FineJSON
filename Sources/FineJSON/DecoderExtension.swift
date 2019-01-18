import Foundation
import RichJSONParser

extension Decoder {
    public var sourceLocation: SourceLocation? {
        guard let d = self as? _Decoder else {
            return nil
        }
        return d._sourceLocation
    }
}
