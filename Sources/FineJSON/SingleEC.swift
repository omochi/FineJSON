import Foundation
import RichJSONParser

internal struct SingleEC : SingleValueEncodingContainer {
    let encoder : _Encoder
    
    init(encoder: _Encoder) {
        self.encoder = encoder
    }
    
    var codingPath: [CodingKey] {
        return encoder.codingPath
    }
    
    func encodeNil() {
        write(.null)
    }
    
    func encode(_ value: Bool) {
        write(.boolean(value))
    }
    
    func encode(_ value: Int) {
        write(.number("\(value)"))
    }
    
    func encode(_ value: Int8) {
        write(.number("\(value)"))
    }
    
    func encode(_ value: Int16) {
        write(.number("\(value)"))
    }
    
    func encode(_ value: Int32) {
        write(.number("\(value)"))
    }
    
    func encode(_ value: Int64) {
        write(.number("\(value)"))
    }
    
    func encode(_ value: UInt) {
        write(.number("\(value)"))
    }
    
    func encode(_ value: UInt8) {
        write(.number("\(value)"))
    }
    
    func encode(_ value: UInt16) {
        write(.number("\(value)"))
    }
    
    func encode(_ value: UInt32) {
        write(.number("\(value)"))
    }
    
    func encode(_ value: UInt64) {
        write(.number("\(value)"))
    }
    
    func encode(_ value: Float) {
        write(.number(String(format: "%f", value)))
    }
    
    func encode(_ value: Double) {
        write(.number(String(format: "%f", value)))
    }
    
    func encode(_ value: String) {
        write(.string(value))
    }
    
    func encode<T>(_ value: T) throws where T : Encodable {
        if let json = value as? JSON {
            write(json)
            return
        }
        if let object = value as? JSONObject {
            write(.object(object.value))
            return
        }
        if let array = value as? JSONArray {
            write(.array(array.value))
            return
        }
        if let number = value as? JSONNumber {
            write(.number(number.value))
            return
        }
        
        let encoder = _Encoder(codingPath: codingPath,
                               options: self.encoder.options,
                               box: self.encoder.box,
                               encodingType: T.self)
        try value.encode(to: encoder)
    }
    
    private func write(_ json: JSON) {
        encoder.box.value = BoxedJSON.Value(json)
    }
}
