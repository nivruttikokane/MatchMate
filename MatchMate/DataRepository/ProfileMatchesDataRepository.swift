//
//  ProfileMatchesDataRepository.swift
//  MatchMate
//
//  Created by Nivrutti Kokane on 23/02/25.
//

import SystemConfiguration
import Foundation
import Combine

class ProfileMatchesDataRepository {
    
    func fetchProfileMatchesPublisher() -> AnyPublisher<[ProfileMatchesModel], Error> {
        if isConnectedToNetwork() {
            return NetworkManager.shared.requestPublisher(resultType: ServerResponse.self, endpoint: .fetchProfileMatches)
                .map { ProfileMatchesModel.build(response: $0) }
                .handleEvents(receiveOutput: { matches in
                    self.saveToCoreData(matches)
                })
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        } else {
            return fetchFromCoreData()
        }
    }

    
    private func fetchFromCoreData() -> AnyPublisher<[ProfileMatchesModel], Error> {
        return Future<[ProfileMatchesModel], Error> { promise in
            let fetchObjects = CoreDataManager.shared.fetch(objectType: UserMatches.self)
            let result = fetchObjects.compactMap { object -> ProfileMatchesModel? in
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: object.dictionaryRepresentation(), options: [])
                    return try JSONDecoder().decode(ProfileMatchesModel.self, from: jsonData)
                } catch {
                    print("Decoding error: \(error.localizedDescription)")
                    return nil
                }
            }
            promise(.success(result))
        }
        .eraseToAnyPublisher()
    }

    
    private func saveToCoreData(_ matches: [ProfileMatchesModel]) {
        matches.forEach { user in
            let (exists, _) = CoreDataManager.shared.checkExistence(objectType: UserMatches.self, id: user.id, key: "id")
            
            if !exists {
                if let object = CoreDataManager.shared.create(objectType: UserMatches.self) {
                    object.name = user.name
                    object.address = user.address
                    object.status = user.status
                    object.id = user.id
                    object.imageUrl = user.imageUrl
                    CoreDataManager.shared.saveContext()
                }
            }
        }
    }

    
    func isConnectedToNetwork() -> Bool {
           var zeroAddress = sockaddr_in()
           zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
           zeroAddress.sin_family = sa_family_t(AF_INET)
           
           guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
               $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                   SCNetworkReachabilityCreateWithAddress(nil, $0)
               }
           }) else {
               return false
           }
           
           var flags: SCNetworkReachabilityFlags = []
           if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
               return false
           }
           
           let isReachable = flags.contains(.reachable)
           let needsConnection = flags.contains(.connectionRequired)
           
           return (isReachable && !needsConnection)
       }
}

import CoreData

extension UserMatches {
    func dictionaryRepresentation() -> [String: Any] {
        var jsonObject: [String: Any] = [:]
        
        if let id = id { jsonObject["id"] = id }
        if let name = name { jsonObject["name"] = name }
        if let address = address { jsonObject["address"] = address }
        if let status = status { jsonObject["status"] = status }
        if let imageUrl = imageUrl { jsonObject["imageUrl"] = imageUrl }
        
        return jsonObject
    }
}
