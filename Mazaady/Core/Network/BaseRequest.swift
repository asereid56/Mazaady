//
//  BaseRequest.swift
//  Mazaady
//
//  Created by Aser Eid on 25/04/2025.
//

import Alamofire

enum APIConfiguration {
    static let baseURL = "https://stagingapi.mazaady.com/api/interview-tasks"
}

protocol BaseRequest {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
}

extension BaseRequest {
    var parameters: Parameters? { nil }

    var fullURL: String {
        return "\(APIConfiguration.baseURL)\(path)"
    }
}
