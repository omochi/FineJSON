import Foundation
import XCTest
import OrderedDictionary
import RichJSONParser
import FineJSON

class FeaturesTests: XCTestCase {
    struct A : Codable {
        var a: Int
        var b: String
        var c: Int?
        var d: String?
    }
    
    func testKeyOrder() throws {
        let a = A(a: 1, b: "b", c: 2, d: "d")
        let e = FineJSONEncoder()
        let json = String(data: try e.encode(a), encoding: .utf8)!
        let expected = """
{
  "a": 1,
  "b": "b",
  "c": 2,
  "d": "d"
}
"""
        XCTAssertEqual(json, expected)
    }
    
    func testNoneKeyAbsence() throws {
        let a = A(a: 1, b: "b", c: nil, d: "d")
        let e = FineJSONEncoder()
        let json = String(data: try e.encode(a), encoding: .utf8)!
        let expected = """
{
  "a": 1,
  "b": "b",
  "d": "d"
}
"""
        XCTAssertEqual(json, expected)
    }
    
    func testNoneExplicitNull() throws {
        let a = A(a: 1, b: "b", c: nil, d: "d")
        let e = FineJSONEncoder()
        e.optionalEncodingStrategy = .explicitNull
        let json = String(data: try e.encode(a), encoding: .utf8)!
        let expected = """
{
  "a": 1,
  "b": "b",
  "c": null,
  "d": "d"
}
"""
        XCTAssertEqual(json, expected)
    }
    
    func testIndent4() throws {
        let a = A(a: 1, b: "b", c: 2, d: "d")
        let e = FineJSONEncoder()
        e.jsonSerializeOptions = JSONSerializeOptions(indentString: "    ")
        let json = String(data: try e.encode(a), encoding: .utf8)!
        let expected = """
{
    "a": 1,
    "b": "b",
    "c": 2,
    "d": "d"
}
"""
        XCTAssertEqual(json, expected)
    }
    
    func testOnelineFormat() throws {
        let a = A(a: 1, b: "b", c: 2, d: "d")
        let e = FineJSONEncoder()
        e.jsonSerializeOptions = JSONSerializeOptions(isPrettyPrint: false)
        let json = String(data: try e.encode(a), encoding: .utf8)!
        let expected = """
{"a":1,"b":"b","c":2,"d":"d"}
"""
        XCTAssertEqual(json, expected)
    }
    
    struct B : Codable {
        var x: JSONNumber
        var y: JSONNumber
    }
    
    func testArbitraryNumber() throws {
        let json1 = """
{
  "x": 1234567890.1234567890,
  "y": 0.01
}
"""
        let d = FineJSONDecoder()
        var b = try d.decode(B.self, from: json1.data(using: .utf8)!)
        
        var y = Decimal(string: b.y.value)!
        y += Decimal(string: "0.01")!
        b.y = JSONNumber(y.description)
        
        let e = FineJSONEncoder()
        let json2 = String(data: try e.encode(b), encoding: .utf8)!
        
        let expected = """
{
  "x": 1234567890.1234567890,
  "y": 0.02
}
"""
        XCTAssertEqual(json2, expected)
    }
    
    struct C : Codable {
        var id: Int
        var name: String
    }
    
    func testWeakTypingDecoding() throws {
        let json = """
{
  "id": "123",
  "name": 4869.57
}
"""
        let d = FineJSONDecoder()
        let c = try d.decode(C.self, from: json.data(using: .utf8)!)
        
        XCTAssertEqual(c.id, 123)
        XCTAssertEqual(c.name, "4869.57")
    }
    
    struct F : Codable {
        var name: String
        var data: JSON
    }
    
    func testJSONTypeProperty() throws {
        let json = """
{
  "name": "john",
  "data": [
    "aaa",
    { "bbb": "ccc" }
  ]
}
"""
        let d = FineJSONDecoder()
        let f = try d.decode(F.self, from: json.data(using: .utf8)!)
      
        XCTAssertEqual(f.name, "john")
        XCTAssertEqual(f.data, JSON.array([
            .string("aaa"),
            .object(OrderedDictionary([
                "bbb": .string("ccc")
                ]))
            ]))
    }

    struct G : Codable, JSONAnnotatable {
        static let keyAnnotations: JSONKeyAnnotations = [
            "id": JSONKeyAnnotation(jsonKey: "no"),
            "userName": JSONKeyAnnotation(jsonKey: "user_name")
        ]
        
        var id: Int
        var point: Int
        var userName: String
    }
    
    func testAnnotateJSONKey() throws {
        let json1 = """
{
  "no": 1,
  "point": 100,
  "user_name": "john"
}
"""
        let d = FineJSONDecoder()
        var g = try d.decode(G.self, from: json1.data(using: .utf8)!)
        
        XCTAssertEqual(g.id, 1)
        XCTAssertEqual(g.point, 100)
        XCTAssertEqual(g.userName, "john")
        
        g.point += 3
        
        let e = FineJSONEncoder()
        let json2 = String(data: try e.encode(g), encoding: .utf8)!
        
        let expect = """
{
  "no": 1,
  "point": 103,
  "user_name": "john"
}
"""
        XCTAssertEqual(json2, expect)
    }
    
    struct H : Codable, JSONAnnotatable {
        static let keyAnnotations: JSONKeyAnnotations = [
            "language": JSONKeyAnnotation(defaultValue: JSON.string("Swift"))
        ]
        
        var name: String
        var language: String
    }
    
    func testDefaultValue() throws {
        let json = """
{
  "name": "john"
}
"""
        let d = FineJSONDecoder()
        let h = try d.decode(H.self, from: json.data(using: .utf8)!)
        
        XCTAssertEqual(h.name, "john")
        XCTAssertEqual(h.language, "Swift")
    }
}
