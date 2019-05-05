

import UIKit

final class TaxiListModel: ResponseObjectSerializable, ResponseCollectionSerializable {
    var success: Bool
    var companies: [CompaniesModel]

    init() {
        self.success = false
        self.companies = []
    }

    init?(response: HTTPURLResponse, representation: Any) {
        guard let representation = representation as? [String: Any]
            else { return nil }

        self.success = false
        if (representation["success"] != nil && !(representation["success"] is NSNull)) {
            self.success = representation["success"] as! Bool
        }

        self.companies = []
        if (representation["companies"] != nil && !(representation["companies"] is NSNull)) {
            self.companies = CompaniesModel.collection(response:response, representation: representation["companies"]!)
        }
    }
}

