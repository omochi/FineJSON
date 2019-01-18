import XCTest
import OrderedDictionary
import RichJSONParser
import FineJSON

class AnnotationTests: XCTestCase {
    struct A : Codable, JSONAnnotatable {
        static var keyAnnotations: JSONKeyAnnotations = [
            "userName": JSONKeyAnnotation(jsonKey: "user_name")
        ]

        var userName: String
    }
    
    func testJsonKey() throws {
        let json = """
{
  "user_name": "taro"
}
"""
        let data = json.data(using: .utf8)!
        let decoder = FineJSONDecoder()
        let a = try decoder.decode(A.self, from: data)
        XCTAssertEqual(a.userName, "taro")
        
        try assertJSON(value: a, json: json)
    }
    
    struct B : Codable, JSONAnnotatable {
        static var keyAnnotations: JSONKeyAnnotations = [
            "a": JSONKeyAnnotation(defaultValue: .number("1")),
            "b": JSONKeyAnnotation(defaultValue: .number("2")),
            "c": JSONKeyAnnotation(defaultValue: .object(OrderedDictionary([
                "a": .number("3"),
                "b": .number("4"),
                ])))
        ]
        
        var a: Int
        var b: Int?
        var c: C
    }
    
    struct C : Codable {
        var a: Int
        var b: Int
    }
    
    func testDefaultValue() throws {
        let json = """
{}
"""
        let data = json.data(using: .utf8)!
        let decoder = FineJSONDecoder()
        let a = try decoder.decode(B.self, from: data)
        XCTAssertEqual(a.a, 1)
        XCTAssertEqual(a.b, 2)
        XCTAssertEqual(a.c.a, 3)
        XCTAssertEqual(a.c.b, 4)
    }
    
    func assertJSON<T: Encodable>(value: T,
                                  json: String,
                                  file: StaticString = #file,
                                  line: UInt = #line) throws
    {
        let e = FineJSONEncoder()
        let data = try e.encode(value)
        let actual = String(data: data, encoding: .utf8)!
        
        XCTAssertEqual(actual, json, file: file, line: line)
    }

}
