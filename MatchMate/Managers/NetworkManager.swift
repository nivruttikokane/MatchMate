//
//  NetworkManager.swift
//  MatchMate
//
//  Created by Nivrutti Kokane on 23/02/25.
//

import Foundation

import Foundation
import Combine

 class NetworkManager {
    private init() {}
    static let shared = NetworkManager()

    func requestPublisher<T: Codable>(resultType: T.Type, endpoint: Endpoint) -> AnyPublisher<T, NetworkError> {
        guard let url = endpoint.url else {
            return Fail(error: .urlError).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> T in
                guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                    throw NetworkError.responseProblem
                }
                return try JSONDecoder().decode(T.self, from: data)
            }
            .mapError { error -> NetworkError in
                return (error as? NetworkError) ?? .decodingProblem
            }
            .eraseToAnyPublisher()
    }
}



enum NetworkError : Error {
    case urlError
    case responseProblem
    case decodingProblem
    case failureMessage(message : String)
}


enum Endpoint {
    case fetchProfileMatches
    var method: String {
        switch self {
        case .fetchProfileMatches:
            return "GET"
        }
    }
    var baseUrl: String {
        switch self {
        case .fetchProfileMatches:
            return "https://randomuser.me/api/?results=10"
        }
    }
    var url: URL? {
        guard let url = URL(string: baseUrl) else { return nil }
        return url
    }
}
