//
//  ProfileMatchesViewModel.swift
//  MatchMate
//
//  Created by Nivrutti Kokane on 23/02/25.
//

import Foundation
import Combine

import Foundation
import Combine

class ProfileMatchesViewModel: ObservableObject {
    @Published var userMatches: [ProfileMatchesModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    private let dataRepo: ProfileMatchesDataRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(dataRepo: ProfileMatchesDataRepository) {
        self.dataRepo = dataRepo
    }
    
    func fetchUserMatches() {
        isLoading = true
        errorMessage = ""

        dataRepo.fetchProfileMatchesPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] matches in
                self?.userMatches = matches
            })
            .store(in: &cancellables)
    }
}


