import XCTest
import RichJSONParser
import FineJSON

internal func sloc(_ offset: Int, _ line: Int, _ col: Int) -> SourceLocation {
    return SourceLocation(offset: offset,
                          line: line,
                          columnInByte: col,
                          file: nil)
}

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
            User(location: sloc(4, 2, 3),
                 name: "taro"),
            User(location: sloc(32, 5, 3),
                 name: "jiro")
        ]
        
        XCTAssertEqual(users, expected)
    }
    
    func test2() throws {
        let users: [User] = [
            User(location: sloc(4, 2, 3),
                 name: "taro"),
            User(location: sloc(32, 5, 3),
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
