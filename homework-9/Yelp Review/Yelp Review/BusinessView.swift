//
//  BusinessView.swift
//  Yelp Review
//
//  Created by Nicolas Neven on 11/20/22.
//

import SwiftUI

struct BusinessView: View {
    var business: Detail?
    
    var body: some View {
        if (business == nil) {
            ProgressView()
        } else {
            Text(business?.name ?? "")
        }
    }
}

struct BusinessView_Previews: PreviewProvider {
    static var previews: some View {
        BusinessView()
    }
}
