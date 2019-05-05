

import Foundation
final class DriversModel: ResponseObjectSerializable, ResponseCollectionSerializable {
    var lat: Double
    var lng: Double
    
    init() {
        self.lat = 0
        self.lng = 0
    }
    
    init?(response: HTTPURLResponse, representation: Any) {
        guard let representation = representation as? [String: Any]
            else { return nil }
        
        self.lat = 0
        if (representation["lat"] != nil && !(representation["lat"] is NSNull)) {
            self.lat = representation["lat"] as! Double
        }
        
        self.lng = 0
        if (representation["lon"] != nil && !(representation["lon"] is NSNull)) {
            self.lng = representation["lon"] as! Double
        }
    }
    
   static func collection(response: HTTPURLResponse, representation: Any) -> [DriversModel] {
        let taxiArray = representation as! [AnyObject]
        return taxiArray.map({DriversModel(response:response, representation: $0)! })
    }
}
