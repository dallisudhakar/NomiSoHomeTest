//
//  ViewModelTests.swift
//  HomeTestNomiSo
//
//  Created by apple on 4/28/25.
//
import XCTest
import Combine
@testable import HomeTestNomiSo // Replace with your actual app name



class ViewModelTests: XCTestCase {
       var viewModel: ViewModel!
       var cancellables: Set<AnyCancellable>!
       
       override func setUp() {
           super.setUp()
           viewModel = ViewModel()
           cancellables = []
       }
       
       override func tearDown() {
           cancellables = nil
           viewModel = nil
           super.tearDown()
       }
       
       // Test success scenario
       func testFetchDataSuccess() {
           // Given
           let mockData = try! JSONEncoder().encode([Posts(userId: 1, id: 1, title: "Test Title", body: "Test Body")])
           let mockSession = MockURLSession()
           mockSession.mockData = mockData
           viewModel.session = mockSession  // Inject mock session
           
           // When
           viewModel.fetchDataUsingCombine()
           
           // Then
           let expectation = XCTestExpectation(description: "Data should be loaded")
           
           viewModel.$posts
               .sink { posts in
                   if !posts.isEmpty {
                       XCTAssertEqual(posts.count, 1)
                       XCTAssertEqual(posts.first?.title, "Test Title")
                       expectation.fulfill()
                   }
               }
               .store(in: &cancellables)
           
           wait(for: [expectation], timeout: 1.0)
       }
}

