//
//  Reservations.swift
//  Yelp Review
//
//  Created by Nicolas Neven on 11/20/22.
//

import SwiftUI

struct ReservationView: View {
    var body: some View {
        VStack {
            Text("No bookings found")
                .foregroundColor(.red)
        }
        .navigationTitle("Reservations")
    }
}

struct Reservation: Identifiable, Codable {
    let id: String
    let name: String
    let date: Date
    let email: String
}

struct Reservations_Previews: PreviewProvider {
    static var previews: some View {
        ReservationView()
    }
}
