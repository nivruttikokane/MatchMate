//
//  MatchMateTests.swift
//  MatchMateTests
//
//  Created by Nivrutti Kokane on 23/02/25.
//

import XCTest
import Combine
@testable import MatchMate

 class MockProfileMatchesDataRepository: ProfileMatchesDataRepository {
    var mockResult: AnyPublisher<[ProfileMatchesModel], Error>!
    
     override func fetchProfileMatchesPublisher() -> AnyPublisher<[ProfileMatchesModel], Error> {
        return mockResult
    }
}

class ProfileMatchesViewModelTests: XCTestCase {
    
    private var viewModel: ProfileMatchesViewModel!
    private var mockRepository: MockProfileMatchesDataRepository!
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        mockRepository = MockProfileMatchesDataRepository()
        viewModel = ProfileMatchesViewModel(dataRepo: mockRepository)
    }

    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    //  Test Case 1: Successfully fetching user matches
    func testFetchUserMatches_Success() {
        // Arrange: Prepare mock response
        let mockMatches = [
            ProfileMatchesModel(id: "1", imageUrl: "", name: "John Doe", address: "ABC", status: "accepted"),
            ProfileMatchesModel(id: "2", imageUrl: "", name: "Jane Smith", address: "xyz", status: "rejected")
        ]
        
        mockRepository.mockResult = Just(mockMatches)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        let expectation = XCTestExpectation(description: "Successfully fetch user matches")
        
        // Act
        viewModel.fetchUserMatches()
        
        // Assert
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.viewModel.userMatches.count, 2)
            XCTAssertEqual(self.viewModel.userMatches.first?.name, "John Doe")
            XCTAssertEqual(self.viewModel.isLoading, false)
            XCTAssertEqual(self.viewModel.errorMessage, "")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
    }

    //  Test Case 2: Fetch user matches with an error
    func testFetchUserMatches_Failure() {
        // Arrange: Mock an error response
        let mockError = NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch matches"])
        
        mockRepository.mockResult = Fail(error: mockError)
            .eraseToAnyPublisher()
        
        let expectation = XCTestExpectation(description: "Handle error when fetching user matches")
        
        // Act
        viewModel.fetchUserMatches()
        
        // Assert
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertTrue(self.viewModel.userMatches.isEmpty)
            XCTAssertEqual(self.viewModel.isLoading, false)
            XCTAssertEqual(self.viewModel.errorMessage, "Failed to fetch matches")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
    }
    
    //  Test Case 3: isLoading state should be updated correctly
    func testFetchUserMatches_LoadingState() {
        // Arrange: Mock a delayed success response to check loading state
        let mockMatches = [
            ProfileMatchesModel(id: "1", imageUrl: "", name: "John Doe", address: "ABC", status: "accepted"),
        ]
        
        mockRepository.mockResult = Just(mockMatches)
            .setFailureType(to: Error.self)
            .delay(for: .seconds(1), scheduler: DispatchQueue.global())
            .eraseToAnyPublisher()
        
        let expectation1 = XCTestExpectation(description: "Check isLoading state during request")
        let expectation2 = XCTestExpectation(description: "Check isLoading state after completion")
        
        // Act
        viewModel.fetchUserMatches()
        
        // Check isLoading immediately after fetch starts
        XCTAssertEqual(viewModel.isLoading, true)
        expectation1.fulfill()
        
        // Wait for async completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            XCTAssertEqual(self.viewModel.isLoading, false)
            expectation2.fulfill()
        }
        
        wait(for: [expectation1, expectation2], timeout: 2)
    }
}
