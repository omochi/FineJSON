# FineJSON

FineJSON provides `FineJSONEncoder` and `FineJSONDecoder` which are more useful encoder of `Codable`. They alternates standard `Foundation`'s `JSONEncoder` and `JSONDecoder`. This library helps practical requirements in real world which is weird sometime.

# Features

Working code of all example code in this section are in [`FeaturesTests`][].

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

## Customize JSON key with keeping `Codable` methods auto synthesis.

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

## Default value for key absence

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

# Supporting build environment

- SwiftPM for mac, iOS.

- Carthage for mac, iOS.

- Manual xcworkspace for mac, iOS.
  This is my favourite. 
  [Detail is here](https://qiita.com/omochimetaru/items/3a8441be9152ea6619b6)

# License

MIT.

It includes [yajl](https://github.com/lloyd/yajl) which has ISC license.

[`FeaturesTests`]: Tests/FineJSONTests/FeaturesTests.swift
[`CodablePrimitiveJSONDecoder`]: Sources/FineJSON/CodablePrimitiveJSONDecoder.swift
[`JSON`]: Sources/FineJSON/JSON.swift

