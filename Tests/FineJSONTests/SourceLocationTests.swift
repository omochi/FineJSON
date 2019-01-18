import XCTest
import RichJSONParser
import FineJSON

struct User : Codable, Equatable, JSONAnnotatable {
    static let keyAnnotations: JSONKeyAnnotations = [
        "location": JSONKeyAnnotation(isSourceLocationKey: true)
        ]
    
    var location: SourceLocation
    var name: String
}

class SourceLocationTests: XCTestCase {
    func test1() throws {
        let json = """
[
  {
    "name": "taro"
  },
  {
    "name": "jiro"
  }
]
"""
        let d = FineJSONDecoder()
        let users = try d.decode([User].self, from: json.data(using: .utf8)!)
        
        let expected = [
            User(location: SourceLocation(offset: 4, line: 2, columnInByte: 3),
                 name: "taro"),
            User(location: SourceLocation(offset: 32, line: 5, columnInByte: 3),
                 name: "jiro")
        ]
        
        XCTAssertEqual(users, expected)
    }
    
    func test2() throws {
        let users: [User] = [
            User(location: SourceLocation(offset: 4, line: 2, columnInByte: 3),
                 name: "taro"),
            User(location: SourceLocation(offset: 32, line: 5, columnInByte: 3),
                 name: "jiro")
        ]
        
        let e = FineJSONEncoder()
        let json = String(data: try e.encode(users), encoding: .utf8)!
        
        let expected = """
[
  {
    "name": "taro"
  },
  {
    "name": "jiro"
  }
]
"""
        XCTAssertEqual(json, expected)
    }
}
