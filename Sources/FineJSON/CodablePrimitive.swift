import Foundation

internal protocol CodablePrimitive : Codable {}

extension Bool : CodablePrimitive {}
extension Int : CodablePrimitive {}
extension Int8 : CodablePrimitive {}
extension Int16 : CodablePrimitive {}
extension Int32 : CodablePrimitive {}
extension Int64 : CodablePrimitive {}
extension UInt : CodablePrimitive {}
extension UInt8 : CodablePrimitive {}
extension UInt16 : CodablePrimitive {}
extension UInt32 : CodablePrimitive {}
extension UInt64 : CodablePrimitive {}
extension Float : CodablePrimitive {}
extension Double : CodablePrimitive {}
extension String : CodablePrimitive {}
