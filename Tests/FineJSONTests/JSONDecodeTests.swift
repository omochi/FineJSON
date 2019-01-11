import XCTest
import OrderedDictionary
import FineJSON

class JSONDecodeTests: XCTestCase {
    struct A : Codable {
        var a: JSONNumber
        var b: JSONArray
        var c: JSONObject
        var d: JSON
        var e: JSON
    }
    
    let aJSON = """
{
    "a": 0.123456789012345678901234567890,
    "b": [
      0.123456789012345678901234567890,
      "aaa",
      [],
      {}
    ],
    "c": {
      "a": 0.123456789012345678901234567890
    },
    "d": [],
    "e": {}
}
"""
    
    func test1() throws {
        let data = aJSON.data(using: .utf8)!
        let decoder = FineJSONDecoder()
        let a = try decoder.decode(A.self, from: data)
        
        XCTAssertEqual(a.a, JSONNumber("0.123456789012345678901234567890"))
        XCTAssertEqual(a.b, JSONArray([
            .number(JSONNumber("0.123456789012345678901234567890")),
            .string("aaa"),
            .array(JSONArray([])),
            .object(JSONObject(OrderedDictionary()))
            ]))
        XCTAssertEqual(a.c, JSONObject([
            "a": .number(JSONNumber("0.123456789012345678901234567890"))
            ]))
        XCTAssertEqual(a.d, JSON.array(JSONArray([])))
        XCTAssertEqual(a.e, JSON.object(JSONObject(OrderedDictionary())))
    }
}
