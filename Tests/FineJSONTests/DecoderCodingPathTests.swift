import XCTest
import FineJSON


internal func assert(_ codingPath: [CodingKey], _ expected: [String],
            file: StaticString = #file, line: UInt = #line)
{
    let actual = codingPath.map { $0.intValue.map { "\($0)" } ?? $0.stringValue }
    XCTAssertEqual(actual, expected,
                   file: file, line: line)
}

class DecoderCodingPathTests: XCTestCase {    
    let cJSON = """
{
  "a": {
    "bs": [
      null,
      null,
      {
        "i": [1, 2, 3]
      }
    ]
  }
}
"""
    
    struct C : Decodable {
        enum CodingKeys : String, CodingKey {
            case a
        }
        
        init(from decoder: Decoder) throws {
            assert(decoder.codingPath, [])
            
            let c = try decoder.container(keyedBy: CodingKeys.self)
            self.a = try c.decode(A.self, forKey: .a)
            
            assert(decoder.codingPath, [])
        }
        
        struct A : Decodable {
            enum CodingKeys : String, CodingKey {
                case bs
            }
            
            init(from decoder: Decoder) throws {
                assert(decoder.codingPath, ["a"])
                
                let c = try decoder.container(keyedBy: CodingKeys.self)
                self.bs = try c.decode(Array<B?>.self, forKey: .bs)
                
                assert(decoder.codingPath, ["a"])
            }
            
            var bs: [B?]
        }
        
        var a: A
        
        struct B : Decodable {
            enum CodingKeys : String, CodingKey {
                case i
            }
            
            init(from decoder: Decoder) throws {
                assert(decoder.codingPath, ["a", "bs", "2"])
                
                let c = try decoder.container(keyedBy: CodingKeys.self)
                
                self.i = []
                var c2 = try c.nestedUnkeyedContainer(forKey: .i)
                while !c2.isAtEnd {
                    let x = try c2.decode(Int.self)
                    self.i.append(x)
                }
                XCTAssertEqual(self.i, [1, 2, 3])
                
                assert(decoder.codingPath, ["a", "bs", "2"])
            }
            
            var i: [Int]
        }
    }
    
    func test1() throws {
        let data = cJSON.data(using: .utf8)!
        let decoder = FineJSONDecoder()
        let _ = try decoder.decode(C.self, from: data)
    }

}
