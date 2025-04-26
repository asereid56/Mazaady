//
//  productsRequest.swift
//  Mazaady
//
//  Created by Aser Eid on 25/04/2025.
//

import Alamofire

struct ProductsRequest: BaseRequest {
    var query: String?
    
    var path: String {
        "/products"
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var parameters: Parameters? {
        var params: Parameters = [:]
        if let query = query, !query.isEmpty {
            params["name"] = query
        }
        return params.isEmpty ? nil : params
    }
}

