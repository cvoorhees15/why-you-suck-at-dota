//
//  DataView.swift
//  WhyYouSuckAtDota
//
//  Created by Caleb Voorhees on 9/10/24.
//

import SwiftUI

struct DataView: View {
    
    @State var account_ID: Int
    @State var matches: [OpenDotaService.Match] = []
    @State var recentmatches: [OpenDotaService.RecentMatch] = []
    var ODS = OpenDotaService()
    
    var body: some View {
        List(recentmatches, id: \.match_id) {
            recentmatch in
            Text(String(recentmatch.match_id))
        }
        .task {
            do {
                recentmatches = try await ODS.fetchRecentMatches(accountId: account_ID)
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

#Preview {
    DataView(account_ID: 0)
}
