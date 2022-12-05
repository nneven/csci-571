//
//  DetailView.swift
//  Yelp Review
//
//  Created by Nicolas Neven on 11/22/22.
//

import SwiftUI
import MapKit

struct DetailView: View {
    var id: String
    @State var business: Detail?
    @State var reviews: [Review]?
    // @Binding var reservation: String
    
    var body: some View {
        let _ = getBusiness()
        let _ = getReviews()
        TabView {
            BusinessView(business: business)
                .tabItem {
                    Label("Business Details", systemImage: "text.bubble.fill")
                }
            MapView(place: IdentifiablePlace(lat: business?.coordinates.latitude ?? 0, long: business?.coordinates.longitude ?? 0))
                .tabItem {
                    Label("Map Location", systemImage: "location.fill")
                }
            ReviewView(reviews: reviews ?? [])
                .tabItem {
                    Label("Reviews", systemImage: "message.fill")
                }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func getBusiness() {
        if (business != nil) {
            return
        }
        print("getBusiness()")
        var components = URLComponents(string: "https://csci-571-363723.wl.r.appspot.com/yelp")!
        components.queryItems = [
            URLQueryItem(name: "url", value: "https://api.yelp.com/v3/businesses/" + id)
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
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    business = try decoder.decode(Detail.self, from: JSONSerialization.data(withJSONObject: json!))
                    print(business ?? "")
                } catch {
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    func getReviews() {
        if (reviews != nil) {
            return
        }
        print("getReviews()")
        var components = URLComponents(string: "https://csci-571-363723.wl.r.appspot.com/yelp")!
        components.queryItems = [
            URLQueryItem(name: "url", value: "https://api.yelp.com/v3/businesses/" + id + "/reviews")
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
                if let dict = json as? [String: Any] {
                    if let businesses = dict["reviews"] as? [Any] {
                        do {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            reviews = try decoder.decode([Review].self, from: JSONSerialization.data(withJSONObject: businesses))
                            print(reviews ?? "")
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        }
        task.resume()
    }
}

struct Detail: Identifiable, Codable {
    let id: String
    let name: String
    let location: Location
    let categories: [Category]
    let displayPhone: String
    let price: String?
    let isClosed: Bool
    let url: String
    let photos: [String]
    let coordinates: Coordinates
}

struct Location: Codable {
    let displayAddress: [String]
}

struct Category: Codable {
    let title: String
}

struct Coordinates: Codable {
    let latitude: Double
    let longitude: Double
}

struct Review: Identifiable, Codable {
    let id: String
    let rating: Int
    let user: User
    let text: String
    let timeCreated: String
}

struct User: Codable {
    let name: String
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(id: "AUbKbVQAUNI6Vr6LYtOZzA", reviews: [])
    }
}
