//
//  ContentView.swift
//  WhyYouSuckAtDota
//
//  Created by Caleb Voorhees on 9/8/24.
//

import SwiftUI

struct SearchView: View {
    let ODS = OpenDotaService()
    @State private var profile: OpenDotaService.Profile?
    @State private var searchResults: [OpenDotaService.SearchResult] = []
    @State private var searchTerm = ""
    
    var body: some View {
        NavigationStack {
            // List of persona name search results
            List(searchResults, id: \.account_id) {
                searchResult in
                HStack(spacing: 20) {
                    AsyncImage(url:URL(string: searchResult.avatarfull)) { avatar in avatar
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                    } placeholder: {
                        Circle()
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 44, height: 44)
                    
                    NavigationLink(searchResult.personaname, destination: DataView(account_ID: searchResult.account_id))
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }
            .navigationTitle("Steam Accounts")
            .searchable(text: $searchTerm, prompt: "Enter Account Name")
            // API call for list of steam accounts based on search criteria
            .onSubmit(of: .search) {
                Task {
                    do {
                        searchResults = try await ODS.fetchSearchResults(personaname: searchTerm)
                        
                    }
                    catch OpenDotaService.ApiError.invalidURL {
                        print ("invalid URL")
                    }
                    catch OpenDotaService.ApiError.invalidReponse {
                        print ("invalid response")
                    }
                    catch OpenDotaService.ApiError.invalidData {
                        print ("invalid data")
                    }
                    catch {
                        print ("unexpected error")
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    SearchView()
}
