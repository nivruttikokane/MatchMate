//
//  NetworkConnectivityService.swift
//  MatchMate
//
//  Created by Nivrutti Kokane on 23/02/25.
//

import Network
import Combine


class NetworkConnectivityService {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    var isConnected = CurrentValueSubject<Bool, Never>(true)

    init() { startMonitoring() }

    func startMonitoring() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected.send(path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
    }

    func stopMonitoring() { monitor.cancel() }
}


