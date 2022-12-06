//
//  Reservations.swift
//  Yelp Review
//
//  Created by Nicolas Neven on 11/20/22.
//

import SwiftUI

struct ReservationView: View {
    @State var reservations: [Reservation]?
    
    var body: some View {
        VStack {
            if (reservations == nil) {
                let _ = getReservations()
            } else if ((reservations?.isEmpty) == true) {
                Text("No bookings found")
                    .foregroundColor(.red)
            } else {
                List {
                    Section {
                        ForEach(reservations!.indices, id: \.self) { index in
                            HStack {
                                Text(reservations![index].business).font(.system(size: 12))
                                Spacer()
                                Text(reservations![index].date).font(.system(size: 12))
                                Spacer()
                                Text(reservations![index].time).font(.system(size: 12))
                                Spacer()
                                Text(reservations![index].email).font(.system(size: 12))
                            }
                        }
                        .onDelete(perform: cancel)
                    }
                }
            }
        }
        .navigationTitle("Your Reservations")
    }
    
    func cancel(at offsets: IndexSet) {
        var components = URLComponents(string: "https://csci-571-363723.wl.r.appspot.com/cancel")!
        components.queryItems = [
            URLQueryItem(name: "index", value: String(offsets.first!))
        ]
        let url = URLRequest(url: components.url!)
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print(response!)
                return
            }
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data)
                if let reservationsArray = json as? [Any] {
                    do {
                        let decoder = JSONDecoder()
                        reservations = try decoder.decode([Reservation].self, from: JSONSerialization.data(withJSONObject: reservationsArray))
                        print(reservations ?? "")
                    } catch {
                        print(error)
                    }
                }
            }
        }
        task.resume()
    }
    
    func getReservations() {
        let components = URLComponents(string: "https://csci-571-363723.wl.r.appspot.com/reservations")!
        let url = URLRequest(url: components.url!)
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print(response!)
                return
            }
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data)
                if let reservationsArray = json as? [Any] {
                    do {
                        let decoder = JSONDecoder()
                        reservations = try decoder.decode([Reservation].self, from: JSONSerialization.data(withJSONObject: reservationsArray))
                        print(reservations ?? "")
                    } catch {
                        print(error)
                    }
                }
            }
        }
        task.resume()
    }
}

struct Reservation: Codable {
    let business: String
    let email: String
    let date: String
    let time: String
}

struct Reservations_Previews: PreviewProvider {
    static var previews: some View {
        ReservationView()
    }
}
