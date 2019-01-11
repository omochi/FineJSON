import XCTest
import FineJSON

class AnnotationTests: XCTestCase {
    struct A : Codable, FineJSONAnnotatable {
        static var keyAnnotations: [String : FineJSONKeyAnnotation] = [
            "userName": FineJSONKeyAnnotation(jsonKey: "user_name")
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
