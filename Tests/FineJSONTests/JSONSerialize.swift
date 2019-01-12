import XCTest
import yajl
import FineJSON

class JSONSerialize: XCTestCase {
    
    func test1() throws {
        let a = JSON.object(JSONObject([
            "a": .number(JSONNumber("1.234")),
            "b": .string("hello")
            ]))
        
        do {
            let data = try a.serialize(options: JSON.SerializeOptions(isPrettyPrint: true,
                                                                      indentString: "  "))
            let json = String(data: data, encoding: .utf8)!

            let expect = """
{
  "a": 1.234,
  "b": "hello"
}
"""
            XCTAssertEqual(json, expect)
        }
        
        do {
            let data = try a.serialize(options: JSON.SerializeOptions(isPrettyPrint: true,
                                                                      indentString: "    "))
            let json = String(data: data, encoding: .utf8)!
            
            let expect = """
{
    "a": 1.234,
    "b": "hello"
}
"""
            XCTAssertEqual(json, expect)
        }
        
        do {
            let data = try a.serialize(options: JSON.SerializeOptions(isPrettyPrint: true,
                                                                      indentString: "\t"))
            let json = String(data: data, encoding: .utf8)!
            
            let t = "\t"
            let expect = """
{
\(t)"a": 1.234,
\(t)"b": "hello"
}
"""
            XCTAssertEqual(json, expect)
        }
        
        do {
            let data = try a.serialize(options: JSON.SerializeOptions(isPrettyPrint: false))
            let json = String(data: data, encoding: .utf8)!
            
            let expect = """
{"a":1.234,"b":"hello"}
"""
            XCTAssertEqual(json, expect)
        }
    }

    func test2() throws {
        let a = JSON.object(JSONObject([
            "a": .number(JSONNumber("1.234")),
            "b": .string("hello"),
            "c": .object(JSONObject([:])),
            "d": .object(JSONObject([
                "a": .string("a")
                ]))
            ]))
        
        let data = try a.serialize(options: JSON.SerializeOptions(isPrettyPrint: true))
        let json = String(data: data, encoding: .utf8)!
        
        let expect = """
{
  "a": 1.234,
  "b": "hello",
  "c": {

  },
  "d": {
    "a": "a"
  }
}
"""
        XCTAssertEqual(json, expect)
        
    }
}
