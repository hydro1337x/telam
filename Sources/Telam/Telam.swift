//
//  Telam.swift
//  BetShops
//
//  Created by Benjamin Mecanović on 08.10.2021..
//

import Foundation
import Combine
import Alamofire

protocol Networkable {
    func request<Value>(for apiConfiguration: APIConfigurable) -> AnyPublisher<Value, Error> where Value: Decodable
}

public class Telam: Networkable {
    
    static var baseURL: String = ""
    
    init() {}
    
    public func request<Value>(for apiConfiguration: APIConfigurable) -> AnyPublisher<Value, Error> where Value: Decodable {
        AF.request(apiConfiguration)
            .cURLDescription(calling: { curl in
                print(curl)
            })
            .validate()
            .publishDecodable(type: Value.self)
            .compactMap { $0.data }
            .decode(type: Value.self, decoder: JSONDecoder())
            .handleEvents(receiveOutput: { decodable in
                print("Response: ", decodable)
            })
            .eraseToAnyPublisher()
    }
    
    public static func configure(with baseURL: String) -> Telam {
        Telam.baseURL = baseURL
        return Telam()
    }
}
