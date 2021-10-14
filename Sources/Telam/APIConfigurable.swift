//
//  APIConfigurable.swift
//  BetShops
//
//  Created by Benjamin Mecanović on 08.10.2021..
//

import Foundation
import Alamofire

public typealias HTTPMethod = Alamofire.HTTPMethod
public typealias PathParameter = Int
public typealias QueryRequestable = Encodable
public typealias BodyRequestable = Encodable
public typealias Respondable = Decodable
public struct Discardable: Respondable {}

public protocol APIConfigurable: URLRequestConvertible {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryRequestable: QueryRequestable? { get }
    var bodyRequestable: BodyRequestable? { get }
}

public extension APIConfigurable {
    
    func asURLRequest() throws -> URLRequest {
        let url = try Telam.baseURL.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        
        // HTTP Method
        urlRequest.httpMethod = method.rawValue
        
        // Headers
        urlRequest.allHTTPHeaderFields = headers
        
        // Query Parameters
        if let queryParameters = self.queryRequestable?.asDictionary {
            let parameters = queryParameters.map { pair  in
                return URLQueryItem(name: pair.key, value: "\(pair.value)")
            }
            var components = URLComponents(string:url.appendingPathComponent(path).absoluteString)
            components?.queryItems = parameters
            urlRequest.url = components?.url
        }
        
        
        // Body
        if let bodyRequestable = self.bodyRequestable {
            urlRequest.httpBody = try bodyRequestable.asJSON()
        }
        
        return urlRequest
    }
}
