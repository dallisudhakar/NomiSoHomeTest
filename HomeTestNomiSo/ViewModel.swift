//
//  ViewModel.swift
//  HomeTestNomiSo
//
//  Created by apple on 4/28/25.
//

import Foundation
import Combine

enum NetworkError: Error {
    case invalidUrl
    case invalidResponse
    case invalidData
}

class ViewModel: ObservableObject {
    
    @Published var posts: [Posts] = []
    @Published var errorWrapper: ErrorWrapper? = nil
    private var cancellables = Set<AnyCancellable>()
    @Published var isLoading: Bool = false // 🆕 loading state
    // Inject session via dependency injection
    var session: URLSessionProtocol = URLSession.shared
    
    func fetchDataUsingAsyncAwait() async throws {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            throw NetworkError.invalidUrl
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse,
              response.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let results = try JSONDecoder().decode([Posts].self, from: data)
            DispatchQueue.main.async {
                self.posts = results
                print(self.posts)
            }
            
        } catch {
            throw NetworkError.invalidData
        }
    }
    
    func loadPostsIfNeeded() {
        if posts.isEmpty {
            fetchDataUsingCombine()
        }
    }
    func fetchDataUsingCombine() {
        print("API is calling")
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
           // self.errorMessage = "Invalid URL"
            self.errorWrapper = ErrorWrapper(message: "Invalid URL")
            return
        }
        
        isLoading = true
        
        session.dataTaskPublisher(for: url)
                    .receive(on: DispatchQueue.main)
                    .map(\.data)
                    .decode(type: [Posts].self, decoder: JSONDecoder())
                    .sink { completion in
                        self.isLoading = false
                        switch completion {
                        case .finished:
                           
                            //self.hasLoadedData = true
                            break
                        case .failure(let error):
                            self.errorWrapper = ErrorWrapper(message: error.localizedDescription)
                        }
                    } receiveValue: { posts in
                        self.posts = posts
                    }
                    .store(in: &cancellables)
    }
}
struct ErrorWrapper: Identifiable {
    let id = UUID()
    let message: String
}

struct Posts: Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

protocol URLSessionProtocol {
    func dataTaskPublisher(for url: URL) -> URLSession.DataTaskPublisher
}
//extension URLSession: URLSessionProtocol {
//    func dataTaskPublisher(for url: URL) -> URLSession.DataTaskPublisher {
//        return URLSession.shared.dataTaskPublisher(for: url)
//    }
//}
extension URLSession: URLSessionProtocol {
    func dataTaskPublisher(for url: URL) -> URLSession.DataTaskPublisher {
        return dataTaskPublisher(for: url)
    }
}

// Mock URLSession for unit tests
class MockURLSession: URLSessionProtocol {
    var mockData: Data?
    var mockError: Error?
    
    func dataTaskPublisher(for url: URL) -> URLSession.DataTaskPublisher {
        if let error = mockError {
            return Fail<Any, Error>(error: error)
                .eraseToAnyPublisher()
                .eraseToDataTaskPublisher()
        }
        
        return Just((data: mockData!, response: URLResponse()))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
            .eraseToDataTaskPublisher()
    }
}

// Helper to cast AnyPublisher to DataTaskPublisher
private extension AnyPublisher {
    func eraseToDataTaskPublisher() -> URLSession.DataTaskPublisher {
        return URLSession.shared.dataTaskPublisher(for: URL(string: "")!) // Doesn't matter which URL we pass here.
    }
}
