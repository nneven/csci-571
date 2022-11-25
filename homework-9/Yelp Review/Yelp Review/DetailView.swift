//
//  DetailView.swift
//  Yelp Review
//
//  Created by Nicolas Neven on 11/22/22.
//

import SwiftUI

struct DetailView: View {
    var id: String
    @State var business: Detail?
    
    var body: some View {
        let _ = getBusiness()
        TabView {
            BusinessView(business: self.business)
                .tabItem {
                    Label("Business Details", systemImage: "text.bubble.fill")
                }
            MapView()
                .tabItem {
                    Label("Map Location", systemImage: "location.fill")
                }
            ReviewView()
                .tabItem {
                    Label("Account", systemImage: "message.fill")
                }
        }
    }
    
    func getBusiness() {
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
                    print(business!)
                } catch {
                    print(error)
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
}

struct Location: Codable {
    let displayAddress: [String]
}

struct Category: Codable {
    let title: String
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(id: "")
    }
}
