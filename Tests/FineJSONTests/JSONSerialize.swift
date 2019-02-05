import XCTest
import RichJSONParser
import FineJSON

class JSONSerialize: XCTestCase {
    
    func test1() throws {
        let a = JSON.object(JSONDictionary([
            "a": .number("1.234"),
            "b": .string("hello")
            ]))
        
        do {
            let json = try serialize(a, options: JSONSerializeOptions(isPrettyPrint: true,
                                                                      indentString: "  "))

            let expect = """
{
  "a": 1.234,
  "b": "hello"
}
"""
            XCTAssertEqual(json, expect)
        }
        
        do {
            let json = try serialize(a, options: JSONSerializeOptions(isPrettyPrint: true,
                                                                      indentString: "    "))

            let expect = """
{
    "a": 1.234,
    "b": "hello"
}
"""
            XCTAssertEqual(json, expect)
        }
        
        do {
            let json = try serialize(a, options: JSONSerializeOptions(isPrettyPrint: true,
                                                                       indentString: "\t"))
            
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
            let json = try serialize(a, options: JSONSerializeOptions(isPrettyPrint: false))
            
            let expect = """
{"a":1.234,"b":"hello"}
"""
            XCTAssertEqual(json, expect)
        }
    }

    func test2() throws {
        let a = JSON.object(JSONDictionary([
            "a": .number("1.234"),
            "b": .string("hello"),
            "c": .object(JSONDictionary()),
            "d": .object(JSONDictionary([
                "a": .string("a")
                ]))
            ]))
        
        let json = try serialize(a, options: JSONSerializeOptions(isPrettyPrint: true))
        
        let expect = """
{
  "a": 1.234,
  "b": "hello",
  "c": {},
  "d": {
    "a": "a"
  }
}
"""
        XCTAssertEqual(json, expect)
        
    }
    
    private func serialize(_ json: JSON, options: JSONSerializeOptions) throws -> String {
        let s = JSONSerializer()
        s.options = options
        let data = s.serialize(json)
        return String(data: data, encoding: .utf8)!
    }
}
