import XCTest
import FineJSON

final class WeakTypingTests: XCTestCase {
    struct A : Codable {
        var a: Int
        var b: String
    }
    
    func test1() throws {
        let json = """
{
  "a": "123",
  "b": 0.12345678901234567890123456789012345678901234567890
}
"""
        let data = json.data(using: .utf8)!
        let decoder = FineJSONDecoder()
        let a = try decoder.decode(A.self, from: data)
        XCTAssertEqual(a.a, 123)
        XCTAssertEqual(a.b, "0.12345678901234567890123456789012345678901234567890")
    }
}

