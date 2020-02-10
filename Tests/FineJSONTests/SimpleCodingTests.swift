import Foundation
import XCTest
import FineJSON

class SimpleCodingTests: XCTestCase {
    struct A : Codable, Equatable {
        var x: URL
    }
    
    func testURL() throws {
        let original = A(x: URL(string: "https://apple.com")!)
        
        let encoder = FineJSONEncoder()
        let json = String(data: try encoder.encode(original), encoding: .utf8)!
        
        print(json)
        
        let expectedJSON = """
{
  "x": {
    "relative": "https://apple.com"
  }
}
"""
        
        XCTAssertEqual(json, expectedJSON)

        let decoder = FineJSONDecoder()
        let decoded = try decoder.decode(A.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(decoded, original)
    }
    

}
