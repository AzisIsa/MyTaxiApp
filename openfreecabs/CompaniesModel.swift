

import UIKit

final class CompaniesModel: ResponseObjectSerializable, ResponseCollectionSerializable {
    var name: String
    var drivers: [DriversModel]
    var iconURL: String

    init() {
        self.name = ""
        self.drivers = []
        self.iconURL = ""
    }

    init?(response: HTTPURLResponse, representation: Any) {
        guard let representation = representation as? [String: Any]
            else { return nil }

        self.name = ""
        if (representation["name"] != nil && !(representation["name"] is NSNull)) {
            self.name = representation["name"] as! String
        }

        self.iconURL = ""
        if (representation["icon"] != nil && !(representation["icon"] is NSNull)) {
            self.iconURL = representation["icon"] as! String
        }

        self.drivers = []
        if (representation["drivers"] != nil && !(representation["drivers"] is NSNull)) {
            self.drivers = DriversModel.collection(response:response, representation: representation["drivers"]!)
        }

    }

    static func collection(response: HTTPURLResponse, representation: Any) -> [CompaniesModel] {
        let companiesArray = representation as! [AnyObject]
        return companiesArray.map({CompaniesModel(response:response, representation: $0)! })
    }
}
