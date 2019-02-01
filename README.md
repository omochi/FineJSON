# FineJSON

FineJSON provides `FineJSONEncoder` and `FineJSONDecoder` which are more useful encoder of `Codable`. They alternates standard `Foundation`'s `JSONEncoder` and `JSONDecoder`. This library helps practical requirements in real world which is weird sometime.

## Index

- [Features](#features)
  - [Allowing unnecessary trailing commas](#allowing-unnecessary-trailing-commas)
  - [Allowing comments](#allowing-comments)
  - [Line number information in parse error](#line-number-information-in-parse-error)
  - [Location information from decoder](#location-information-from-decoder)
  - [Keeping JSON key order](#keeping-json-key-order)
  - [Control Optional.none encoding](#control-optionalnone-encoding)
  - [Control indent width](#control-indent-width)
  - [Handling arbitrary digits number](#handling-arbitrary-digits-number)
  - [Weak typing primitive decoding](#weak-typing-primitive-decoding)
  - [Handling complex JSON structure directly](#handling-complex-json-structure-directly)
  - [Customizing JSON key with keeping Codable methods auto synthesis](#customizing-json-key-with-keeping-codable-methods-auto-synthesis)
  - [Default value for absent key](#default-value-for-absent-key)
  - [Auto location information decoding](#auto-location-information-decoding)
- [Supported building environment](#supported-building-environment)
- [License](#License)

# Features

Working code of all example code in this section are in [`FeaturesTests`][].

## Allowing unnecessary trailing commas

Decoder allows unnecessary trailing comma.

```swift
    struct A : Codable, Equatable {
        var a: Int
        var b: Int
    }

    func testAllowTrailingComma() throws {
        let json = """
[
  {
    "a": 1,
    "b": 2,
  },
]
"""
        let decoder = FineJSONDecoder()
        let x = try decoder.decode([A].self, from: json.data(using: .utf8)!)
        XCTAssertEqual(x, [A(a: 1, b: 2)])
    }
```

## Allowing comments

Decoder allows comments in JSON.

```swift
    struct A : Codable, Equatable {
        var a: Int
        var b: Int
    }

    func testComment() throws {
        let json = """
[
  // entry 1
  {
    "a": 10,
    "b": 20
/*
    "a": 1,
    "b": 2,
*/
  }
]
"""
        let decoder = FineJSONDecoder()
        let x = try decoder.decode([A].self, from: json.data(using: .utf8)!)
        XCTAssertEqual(x, [A(a: 10, b: 20)])
    }
```

## Line number information in parse error

Parser error tells location in JSON.
line number, column number (in byte offset), byte offset.

```swift
    struct A : Codable, Equatable {
        var a: Int
        var b: Int
    }

    func testParseErrorLocation() throws {
        let json = """
[
  {
    "a": 1,
    "b": 2;
  }
]
"""
        let decoder = FineJSONDecoder()
        do {
            _ = try decoder.decode([A].self, from: json.data(using: .utf8)!)
            XCTFail()
        } catch {
            let message = "\(error)"
            // invalid character (";") at 4:11(28)
            XCTAssertTrue(message.contains("4:11(28)"))
        }
    }
```

File path also can be passed to decoder. It improves debugging experience.

```
    func testSourceLocationFilePath() throws {
        let json = """
{ invalid syntax }
"""
        do {
            let decoder = FineJSONDecoder()
            decoder.file = URL(fileURLWithPath: "resource/dir/info.json")
            _ = try decoder.decode(Int.self, from: json.data(using: .utf8)!)
            XCTFail("expect throw")
        } catch {
            let message = "\(error)"
            XCTAssertTrue(message.contains("resource/dir/info.json"))
        }
    }
```

## Location information from decoder

You can get location information from `Decoder`.

```swift
    struct B : Decodable {
        var location: SourceLocation?
        var name: String
        enum CodingKeys : String, CodingKey { case name }
        init(from decoder: Decoder) throws {
            self.location = decoder.sourceLocation
            let c = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try c.decode(String.self, forKey: .name)
        }
    }

    func testDecodeLocation() throws {
        let json = """
// comment
{
  "name": "b"
},
"""
        let decoder = FineJSONDecoder()
        let x = try decoder.decode(B.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(x.location, SourceLocation(offset: 11, line: 2, columnInByte: 1))
        XCTAssertEqual(x.name, "b")
    }
```

See also [auto location information decoding](#auto-location-information-decoding).

## Keeping JSON key order

Encoder keeps JSON key order.

```swift
    struct A : Codable {
        var a: Int
        var b: String
        var c: Int?
        var d: String?
    }
    
    func testKeyOrder() throws {
        let a = A(a: 1, b: "b", c: 2, d: "d")
        let e = FineJSONEncoder()
        let json = String(data: try e.encode(a), encoding: .utf8)!
        let expected = """
{
  "a": 1,
  "b": "b",
  "c": 2,
  "d": "d"
}
"""
        XCTAssertEqual(json, expected)
    }
```

`Foundation.JSONEncoder` does not define key order. So you may get this.

```
{
  "d": "d",
  "b": "b",
  "c": 2,
  "a": 1
}
```

## Control `Optional.none` encoding

You can specify `Optional.none` encoding.

Default is key absence which is same as `Foundation`.

```swift
    func testNoneKeyAbsence() throws {
        let a = A(a: 1, b: "b", c: nil, d: "d")
        let e = FineJSONEncoder()
        let json = String(data: try e.encode(a), encoding: .utf8)!
        let expected = """
{
  "a": 1,
  "b": "b",
  "d": "d"
}
"""
        XCTAssertEqual(json, expected)
    }
```

You can specify to emit explicit null for such key.

```swift
    func testNoneExplicitNull() throws {
        let a = A(a: 1, b: "b", c: nil, d: "d")
        let e = FineJSONEncoder()
        e.optionalEncodingStrategy = .explicitNull
        let json = String(data: try e.encode(a), encoding: .utf8)!
        let expected = """
{
  "a": 1,
  "b": "b",
  "c": null,
  "d": "d"
}
"""
        XCTAssertEqual(json, expected)
    }
```

## Control indent width

You can specify indent width.

```swift
    func testIndent4() throws {
        let a = A(a: 1, b: "b", c: 2, d: "d")
        let e = FineJSONEncoder()
        e.jsonSerializeOptions = JSON.SerializeOptions(indentString: "    ")
        let json = String(data: try e.encode(a), encoding: .utf8)!
        let expected = """
{
    "a": 1,
    "b": "b",
    "c": 2,
    "d": "d"
}
"""
        XCTAssertEqual(json, expected)
    }
```

Oneline style is also supported.

```swift
    func testOnelineFormat() throws {
        let a = A(a: 1, b: "b", c: 2, d: "d")
        let e = FineJSONEncoder()
        e.jsonSerializeOptions = JSON.SerializeOptions(isPrettyPrint: false)
        let json = String(data: try e.encode(a), encoding: .utf8)!
        let expected = """
{"a":1,"b":"b","c":2,"d":"d"}
"""
        XCTAssertEqual(json, expected)
    }
```

And prettyprint is default.

## Handling arbitrary digits number

JSON supports arbitrary digits originally. You can handle this by `JSONNumber` type.

```swift
    struct B : Codable {
        var x: JSONNumber
        var y: JSONNumber
    }

    func testArbitraryNumber() throws {
        let json1 = """
{
  "x": 1234567890.1234567890,
  "y": 0.01
}
"""
        let d = FineJSONDecoder()
        var b = try d.decode(B.self, from: json1.data(using: .utf8)!)
        
        var y = Decimal(string: b.y.value)!
        y += Decimal(string: "0.01")!
        b.y = JSONNumber(y.description)
        
        let e = FineJSONEncoder()        
        let json2 = String(data: try e.encode(b), encoding: .utf8)!
        
        let expected = """
{
  "x": 1234567890.1234567890,
  "y": 0.02
}
"""
        XCTAssertEqual(json2, expected)
    }
```

`Foundation.JSONEncoder` can not do this. So you may get this with `Float`.

```
{
  "x": 1234567936,
  "y": 0.019999999552965164
}
```

## Weak typing primitive decoding

JSON number and string are each compatible during decoding.

```swift
    struct C : Codable {
        var id: Int
        var name: String
    }

    func testWeakTypingDecoding() throws {
        let json = """
{
  "id": "123",
  "name": 4869.57
}
"""
        let d = FineJSONDecoder()
        let c = try d.decode(C.self, from: json.data(using: .utf8)!)
        
        XCTAssertEqual(c.id, 123)
        XCTAssertEqual(c.name, "4869.57")
    }
```

You can customize this behavior by inject your object which conforms to [`CodablePrimitiveJSONDecoder`][].

## Handling complex JSON structure directly

You can use [`JSON`][] type to handle complex structure.

```swift
    struct F : Codable {
        var name: String
        var data: JSON
    }
    
    func testJSONTypeProperty() throws {
        let json = """
{
  "name": "john",
  "data": [
    "aaa",
    { "bbb": "ccc" }
  ]
}
"""
        let d = FineJSONDecoder()
        let f = try d.decode(F.self, from: json.data(using: .utf8)!)
      
        XCTAssertEqual(f.name, "john")
        XCTAssertEqual(f.data, JSON.array(JSONArray([
            .string("aaa"),
            .object(JSONObject([
                "bbb": .string("ccc")
                ]))
            ])))
    }
```

## Customizing JSON key with keeping `Codable` methods auto synthesis

You can customize JSON key for property with `Codable` methods auto synthesis.

```swift
    struct G : Codable, JSONAnnotatable {
        static let keyAnnotations: JSONKeyAnnotations = [
            "id": JSONKeyAnnotation(jsonKey: "no"),
            "userName": JSONKeyAnnotation(jsonKey: "user_name")
        ]
        
        var id: Int
        var point: Int
        var userName: String
    }
    
    func testAnnotateJSONKey() throws {
        let json1 = """
{
  "no": 1,
  "point": 100,
  "user_name": "john"
}
"""
        let d = FineJSONDecoder()
        var g = try d.decode(G.self, from: json1.data(using: .utf8)!)
        
        XCTAssertEqual(g.id, 1)
        XCTAssertEqual(g.point, 100)
        XCTAssertEqual(g.userName, "john")
        
        g.point += 3
        
        let e = FineJSONEncoder()
        let json2 = String(data: try e.encode(g), encoding: .utf8)!
        
        let expect = """
{
  "no": 1,
  "point": 103,
  "user_name": "john"
}
"""
        XCTAssertEqual(json2, expect)
    }
```

## Default value for absent key

You can specify default value for property which is used when JSON key is absent.

```swift
    struct H : Codable, JSONAnnotatable {
        static let keyAnnotations: JSONKeyAnnotations = [
            "language": JSONKeyAnnotation(defaultValue: JSON.string("Swift"))
        ]
        
        var name: String
        var language: String
    }
    
    func testDefaultValue() throws {
        let json = """
{
  "name": "john"
}
"""
        let d = FineJSONDecoder()
        let h = try d.decode(H.self, from: json.data(using: .utf8)!)
        
        XCTAssertEqual(h.name, "john")
        XCTAssertEqual(h.language, "Swift")
    }
```

## Auto location information decoding

Location information decoding can be enabled from annotation.

```swift
    func testAutoLocationDecoding() throws {
        let json = """
// comment
{
  "name": "b"
},
"""
        let decoder = FineJSONDecoder()
        let x = try decoder.decode(C.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(x.location, SourceLocation(offset: 11, line: 2, columnInByte: 1))
        XCTAssertEqual(x.name, "b")
        
        let encoder = FineJSONEncoder()
        let json2 = String(data: try encoder.encode(x), encoding: .utf8)!
        XCTAssertEqual(json2, """
{
  "name": "b"
}
""")
        
    }
```

# Supported building environment

- SwiftPM for mac, iOS.

- Carthage for mac, iOS.

- Manual xcworkspace for mac, iOS.
  This is my favorite. 
  [Detail is here](https://qiita.com/omochimetaru/items/3a8441be9152ea6619b6)

# License

MIT.

[`FeaturesTests`]: Tests/FineJSONTests/FeaturesTests.swift
[`CodablePrimitiveJSONDecoder`]: Sources/FineJSON/CodablePrimitiveJSONDecoder.swift
[`JSON`]: Sources/FineJSON/JSON.swift

