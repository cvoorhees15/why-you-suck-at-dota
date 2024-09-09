//
//  OpenDotaService.swift
//  WhyYouSuckAtDota
//
//  Created by Caleb Voorhees on 9/8/24.
//

import Foundation
class OpenDotaService
{
    // Open Dota API call potential errors
    enum ApiError: Error {
        case invalidURL
        case invalidReponse
        case invalidData
    }
    
    // Open Dota API data objects
    // *****************************************
    struct Account: Codable
    {
        let profile: Profile
    }
    
    struct Profile: Codable
    {
        let account_id: Int
    }
    
    struct SearchResult: Codable 
    {
        let account_id: Int
        let personaname: String
        let avatarfull: String
    }
    // *****************************************
    
    func openDotaAPICall(endpoint: String) async throws -> Data
    {
        // Create url for API call
        guard let url = URL(string: endpoint) else {
            throw ApiError.invalidURL
        }
        
        // make API call
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Translate HTTP response from API call
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw ApiError.invalidReponse
        }
        
        return data
    }
    
    func fetchAccount(accountID: Int) async throws -> Account
    {
        let data = try await openDotaAPICall(endpoint: "https://api.opendota.com/api/players/\(accountID)")
        
        // Translate JSON response from API call
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(Account.self, from: data)
        } catch {
            throw ApiError.invalidData
        }
    }
    
    func fetchSearchResults(personaname: String) async throws -> [SearchResult]
    {
        let data = try await openDotaAPICall(endpoint: "https://api.opendota.com/api/search/?q=\(personaname)")
        
        // Translate JSON response from API call
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([SearchResult].self, from: data)
        } catch {
            throw ApiError.invalidData
        }
    }
}
