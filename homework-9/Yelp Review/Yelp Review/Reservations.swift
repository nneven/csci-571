//
//  Reservations.swift
//  Yelp Review
//
//  Created by Nicolas Neven on 11/20/22.
//

import SwiftUI

struct Reservations: View {
    var body: some View {
        VStack {
            Text("No bookings found")
                .foregroundColor(.red)
        }
        .navigationTitle("Reservations")
    }
}

struct Reservations_Previews: PreviewProvider {
    static var previews: some View {
        Reservations()
    }
}
