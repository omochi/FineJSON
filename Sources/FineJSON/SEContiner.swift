import Foundation

internal struct SEContainer : SingleValueEncodingContainer {
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
        write(.number(JSONNumber("\(value)")))
    }
    
    func encode(_ value: Int8) {
        write(.number(JSONNumber("\(value)")))
    }
    
    func encode(_ value: Int16) {
        write(.number(JSONNumber("\(value)")))
    }
    
    func encode(_ value: Int32) {
        write(.number(JSONNumber("\(value)")))
    }
    
    func encode(_ value: Int64) {
        write(.number(JSONNumber("\(value)")))
    }
    
    func encode(_ value: UInt) {
        write(.number(JSONNumber("\(value)")))
    }
    
    func encode(_ value: UInt8) {
        write(.number(JSONNumber("\(value)")))
    }
    
    func encode(_ value: UInt16) {
        write(.number(JSONNumber("\(value)")))
    }
    
    func encode(_ value: UInt32) {
        write(.number(JSONNumber("\(value)")))
    }
    
    func encode(_ value: UInt64) {
        write(.number(JSONNumber("\(value)")))
    }
    
    func encode(_ value: Float) {
        write(.number(JSONNumber(String(format: "%f", value))))
    }
    
    func encode(_ value: Double) {
        write(.number(JSONNumber(String(format: "%f", value))))
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
            write(.object(object))
            return
        }
        if let array = value as? JSONArray {
            write(.array(array))
            return
        }
        if let number = value as? JSONNumber {
            write(.number(number))
            return
        }

        try value.encode(to: encoder)
    }
    
    private func write(_ json: JSON) {
        encoder.box.value = BoxJSON.Value(json)
    }
}
