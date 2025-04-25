//
//  productsRequest.swift
//  Mazaady
//
//  Created by Aser Eid on 25/04/2025.
//

import Alamofire

struct ProductsRequest: BaseRequest {
    var path: String {
        "/products"
    }
    
    var method: Alamofire.HTTPMethod {
        .get
    }
    
    var parameters: Parameters? {
        nil
    }
}

