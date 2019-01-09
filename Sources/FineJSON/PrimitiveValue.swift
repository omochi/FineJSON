import Foundation

internal protocol PrimitiveValue {}

extension Bool : PrimitiveValue {}
extension Int : PrimitiveValue {}
extension Int8 : PrimitiveValue {}
extension Int16 : PrimitiveValue {}
extension Int32 : PrimitiveValue {}
extension Int64 : PrimitiveValue {}
extension UInt : PrimitiveValue {}
extension UInt8 : PrimitiveValue {}
extension UInt16 : PrimitiveValue {}
extension UInt32 : PrimitiveValue {}
extension UInt64 : PrimitiveValue {}
extension Float : PrimitiveValue {}
extension Double : PrimitiveValue {}
extension String : PrimitiveValue {}
