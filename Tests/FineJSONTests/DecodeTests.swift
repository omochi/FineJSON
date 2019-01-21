import XCTest
import RichJSONParser
import FineJSON

final class DecodeTests: XCTestCase {
    struct A : Codable {
        struct B : Codable {
            var a: Int
            var b: Float
            var c: String
            var d: Int?
            var e: Float?
            var f: String?
        }
        
        var b: B
        var c: B?
        var d: [String]
    }

    
    func test1() throws {
        let json = """
{
  "b": {
    "a": 1,
    "b": 2.345,
    "c": "c1",
    "d": 2,
    "e": 3.456,
    "f": "f1"
  },
  "d": ["d1", "d2", "d3"]
}
"""
        let data = json.data(using: .utf8)!
        let decoder = FineJSONDecoder()
        let a = try decoder.decode(A.self, from: data)
        
        XCTAssertEqual(a.b.a, 1)
        XCTAssertEqual(a.b.b, 2.345, accuracy: 0.001)
        XCTAssertEqual(a.b.c, "c1")
        XCTAssertEqual(a.b.d, 2)
        XCTAssertNotNil(a.b.e)
        XCTAssertEqual(a.b.e!, 3.456, accuracy: 0.001)
        XCTAssertEqual(a.b.f, "f1")
        XCTAssertNil(a.c)
        XCTAssertEqual(a.d, ["d1", "d2", "d3"])
    }
    
    struct B : Codable {
        var a: String
        var b: Int
    }
    
    struct K : LocalizedError, CustomStringConvertible {
        var description: String {
            return "kkk"
        }
    }

    func testBrokenJSON() throws {
        let json = """
{
  "a": "aaa"
  "b": 1
}
"""
        let data = json.data(using: .utf8)!
        let decoder = FineJSONDecoder()
        
        XCTAssertThrowsError(try decoder.decode(B.self, from: data))
    }
    
    func testSDinUD() throws {
        let json = """
[1, 2]
"""
        let data = json.data(using: .utf8)!
        let decoder = FineJSONDecoder()
        
        let a = try decoder.decode([Int].self, from: data)
        XCTAssertEqual(a, [1, 2])
    }
}
