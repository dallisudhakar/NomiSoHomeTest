//
//  ContentView.swift
//  HomeTestNomiSo
//
//  Created by apple on 4/28/25.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = ViewModel()
    @State var searchText = ""
    var filteredNames: [Posts] {
        if searchText.isEmpty {
            return viewModel.posts
        } else {
            return viewModel.posts.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                List(filteredNames, id:\.id) { post in
                    NavigationLink(destination: DetailView(post: post)) {
                        RowView(post: post)
                    }
                }
                .blur(radius: viewModel.isLoading ? 3 : 0) // Optional: Blur list when loading
                .disabled(viewModel.isLoading)
                
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)))
                        .shadow(radius: 10)
                }
                
            }
            .navigationTitle("Movie Lists")
            .searchable(text: $searchText, prompt: "Search by name")
            //for async await
            //        .task {
            //            do {
            //               try await viewModel.fetchDataUsingAsyncAwait()
            //            } catch {
            //                print("Error")
            //            }
            //        }
            
            .onAppear() {
                // Using combine
              //  viewModel.fetchDataUsingCombine()
                viewModel.loadPostsIfNeeded()
            }
            .alert(item: $viewModel.errorWrapper) { errorWrapper in
                Alert(
                    title: Text("Error"),
                    message: Text(errorWrapper.message),
                    primaryButton: .default(Text("Retry"), action: {
                        viewModel.fetchDataUsingCombine() // 🔥 Retry the API call
                    }),
                    secondaryButton: .cancel()
                )
            }
        }
    }
}
struct RowView: View {
    
    @State var post: Posts
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(.red)
                .frame(width: 80, height: 100)
                .cornerRadius(10)
            VStack(alignment: .leading) {
                Text(post.title)
                    .font(.title2)
                    .bold()
                    .lineLimit(2)
                Text(post.body)
                    .font(.title3)
                    .lineLimit(2)
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct DetailView: View {
    
    @State var post: Posts
    
    var body: some View {
        VStack {
            Spacer()
            Rectangle()
                .fill(.red)
                .frame(width: 100, height: 140)
                .cornerRadius(10)
            VStack(alignment: .center) {
                Text(post.title)
                    .font(.title2)
                    .bold()
                Text(post.body)
                    .font(.title3)
            }
            .padding()
            
            Spacer()
        }
    }
}
