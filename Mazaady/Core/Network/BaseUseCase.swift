//
//  BaseUseCase.swift
//  Mazaady
//
//  Created by Aser Eid on 25/04/2025.
//

import Alamofire
import Foundation

protocol UseCase {
    associatedtype RequestType: BaseRequest
    associatedtype ResponseType: BaseResponse
    func execute(request: RequestType, completion: @escaping (Result<ResponseType, Error>) -> Void)
}

class BaseUseCase<R: BaseRequest, T: BaseResponse>: UseCase {
    typealias RequestType = R
    typealias ResponseType = T

    func execute(request: R, completion: @escaping (Result<T, Error>) -> Void) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        AF.request(
            request.fullURL,
            method: request.method,
            parameters: request.parameters
        )
        .validate()
        .responseDecodable(of: T.self, decoder: decoder) { response in
            switch response.result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
