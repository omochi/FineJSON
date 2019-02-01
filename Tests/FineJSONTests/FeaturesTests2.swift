import XCTest
import FineJSON

class FeaturesTests2: XCTestCase {
    struct A : Codable, Equatable {
        var a: Int
        var b: Int
    }
    
    func testAllowTrailingComma() throws {
        let json = """
[
  {
    "a": 1,
    "b": 2,
  },
]
"""
        let decoder = FineJSONDecoder()
        let x = try decoder.decode([A].self, from: json.data(using: .utf8)!)
        XCTAssertEqual(x, [A(a: 1, b: 2)])
    }
    
    func testComment() throws {
        let json = """
[
  // entry 1
  {
    "a": 10,
    "b": 20
/*
    "a": 1,
    "b": 2,
*/
  }
]
"""
        let decoder = FineJSONDecoder()
        let x = try decoder.decode([A].self, from: json.data(using: .utf8)!)
        XCTAssertEqual(x, [A(a: 10, b: 20)])
    }
    
    func testParseErrorLocation() throws {
        let json = """
[
  {
    "a": 1,
    "b": 2;
  }
]
"""
        let decoder = FineJSONDecoder()
        do {
            _ = try decoder.decode([A].self, from: json.data(using: .utf8)!)
            XCTFail()
        } catch {
            let message = "\(error)"
            // invalid character (";") at 4:11(28)
            XCTAssertTrue(message.contains("4:11(28)"))
        }
    }
    
    struct B : Decodable {
        var location: SourceLocation?
        var name: String
        enum CodingKeys : String, CodingKey { case name }
        init(from decoder: Decoder) throws {
            self.location = decoder.sourceLocation
            let c = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try c.decode(String.self, forKey: .name)
        }
    }
    
    func testDecodeLocation() throws {
        let json = """
// comment
{
  "name": "b"
},
"""
        let decoder = FineJSONDecoder()
        let x = try decoder.decode(B.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(x.location, sloc(11, 2, 1))
        XCTAssertEqual(x.name, "b")
    }
    
    struct C : Codable, JSONAnnotatable {
        static var keyAnnotations: JSONKeyAnnotations = [
            "location": JSONKeyAnnotation(isSourceLocationKey: true)
        ]
        
        var location: SourceLocation?
        var name: String
    }
    
    func testAutoLocationDecoding() throws {
        let json = """
// comment
{
  "name": "b"
},
"""
        let decoder = FineJSONDecoder()
        let x = try decoder.decode(C.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(x.location, sloc(11, 2, 1))
        XCTAssertEqual(x.name, "b")
        
        let encoder = FineJSONEncoder()
        let json2 = String(data: try encoder.encode(x), encoding: .utf8)!
        XCTAssertEqual(json2, """
{
  "name": "b"
}
""")
        
    }
    
    func testSourceLocationFilePath() throws {
        let json = """
{ invalid syntax }
"""
        do {
            let decoder = FineJSONDecoder()
            decoder.file = URL(fileURLWithPath: "resource/dir/info.json")
            _ = try decoder.decode(Int.self, from: json.data(using: .utf8)!)
            XCTFail("expect throw")
        } catch {
            let message = "\(error)"
            XCTAssertTrue(message.contains("resource/dir/info.json"))
        }
    }
}
