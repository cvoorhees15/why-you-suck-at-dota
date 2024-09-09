//
//  DataView.swift
//  WhyYouSuckAtDota
//
//  Created by Caleb Voorhees on 9/10/24.
//

import SwiftUI

struct DataView: View {
    
    @State var account_ID: Int
    
    var body: some View {
        Text(String(account_ID))
    }
}

#Preview {
    DataView(account_ID: 0)
}
