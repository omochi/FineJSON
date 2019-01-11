import XCTest
import FineJSON

class JSONEncodeTests: XCTestCase {
    struct A : Codable {
        var a: JSONNumber
        var b: JSONArray
        var c: JSONObject
        var d: JSON
        var e: JSON
    }
    
    func test1() throws {
        let a = A(a: JSONNumber("0.123456789012345678901234567890"),
                  b: JSONArray([
                    .number(JSONNumber("0.123456789012345678901234567890")),
                    .string("aaa"),
                    .array(JSONArray()),
                    .object(JSONObject())
                    ]),
                  c: JSONObject([
                    "a": .number(JSONNumber("0.123456789012345678901234567890"))
                    ]),
                  d: .array(JSONArray()),
                  e: .object(JSONObject()))
        
        let encoder = FineJSONEncoder()
        let data = try encoder.encode(a)
        let json = String(data: data, encoding: .utf8)!
        
        let expect = """
{
  "a": 0.123456789012345678901234567890,
  "b": [
    0.123456789012345678901234567890,
    "aaa",
    [

    ],
    {

    }
  ],
  "c": {
    "a": 0.123456789012345678901234567890
  },
  "d": [

  ],
  "e": {

  }
}

"""
        
        XCTAssertEqual(json, expect)
    }

}
