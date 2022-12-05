//
//  ContentView.swift
//  Yelp Review
//
//  Created by Nicolas Neven on 11/20/22.
//

import SwiftUI

struct SearchView: View {
        
    @State var keyword = ""
    @State var distance = "10"
    @State var category = "all"
    @State var location = ""
    @State var autoDetect = false
    @State var submitted = false
    @State var results = [Business]()
    @State var noResults = false
    @State var showPopover = false
    @State var suggestions: [String] = []
    
    var body: some View {
        NavigationView {
            VStack {
                Group {
                    Form {
                        Section {
                            HStack {
                                Text("Keyword:").foregroundColor(.gray)
                                TextField("Required", text: $keyword, onEditingChanged: { (editingChanged) in
                                    if editingChanged {
                                        
                                    } else {
                                        showPopover = false
                                    }
                                })
                                .onSubmit {
                                    showPopover = true
                                }
                                .alwaysPopover(isPresented: $showPopover) {
                                    PopoverContent(keyword: $keyword, showPopover: $showPopover)
                                }
                            }
                            HStack {
                                Text("Distance:").foregroundColor(.gray)
                                TextField("Required", text: $distance)
                            }
                            HStack {
                                Picker("Category:", selection: $category) {
                                    Text("Default").tag("all")
                                    Text("Arts and Entertainment").tag("arts")
                                    Text("Health and Medical").tag("health")
                                    Text("Hotels and Travel").tag("hotelstravel")
                                    Text("Food").tag("food")
                                    Text("Professional Services").tag("professional")
                                }
                                .foregroundColor(.gray)
                                .pickerStyle(.menu)
                            }
                            if !autoDetect {
                                HStack {
                                    Text("Location:").foregroundColor(.gray)
                                    TextField("Required", text: $location)
                                }
                            }
                            HStack {
                                Toggle("Auto-detect my location", isOn: $autoDetect)
                            }
                            HStack {
                                Spacer()
                                Button(action: submit) {
                                    Text("Submit")
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding()
                                }
                                .background(RoundedRectangle(cornerRadius: 8).fill(keyword.isEmpty || (location.isEmpty && !autoDetect) ? .gray : .red))
                                .disabled(keyword.isEmpty || (location.isEmpty && !autoDetect))
                                .buttonStyle(BorderlessButtonStyle())
                                Spacer().frame(width: 40)
                                Button(action: clear) {
                                    Text("Clear")
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding()
                                }
                                .background(RoundedRectangle(cornerRadius: 8).fill(.blue))
                                .buttonStyle(BorderlessButtonStyle())
                                Spacer()
                            }
                            .padding(.vertical)
                        }
                        Section {
                            Text("Results").font(.title).bold()
                            if (submitted && results.isEmpty && !noResults) {
                                VStack {
                                    ProgressView().frame(maxWidth: .infinity, alignment: .center)
                                    Text("Please wait...").foregroundColor(.gray).frame(maxWidth: .infinity, alignment: .center)
                                }
                            } else if noResults {
                                Text("No results available").foregroundColor(.red)
                            } else {
                                 ForEach(Array(results.enumerated()), id: \.1.id) { idx, result in
                                    let image = AsyncImage(url: URL(string: result.imageUrl)) { image in
                                        image.resizable()
                                    } placeholder: {
                                        // ProgressView()
                                    }.frame(width: 64, height: 64).cornerRadius(8)
                                    let distance = String(Int(round(Double(result.distance) / 1609.34)))
                                     NavigationLink(destination: DetailView(id: result.id), label: {
                                        HStack {
                                            Text(String(idx + 1)).bold()
                                            Spacer()
                                            image
                                            Spacer()
                                            Text(result.name).frame(maxWidth: 100).foregroundColor(.gray)
                                            Spacer()
                                            Text(String(result.rating)).bold()
                                            Spacer()
                                            Text(distance).bold()
                                        }
                                    })
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Business Search")
            }
            .toolbar {
                NavigationLink(destination: ReservationView(), label: {
                    Image(systemName: "calendar.badge.clock")
                })
            }
        }
    }
    
    func submit() {
        print("submit()")
        submitted = true
        var latitude = ""
        var longitude = ""
        if (autoDetect) {
            let url = URL(string: "https://ipinfo.io?token=41eab4d12ac318")!
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
                        if let loc = dict["loc"] as? String {
                            latitude = String(loc.split(separator: ",")[0])
                            longitude = String(loc.split(separator: ",")[1])
                            search(latitude: latitude, longitude: longitude)
                        }
                    }
                }
            }
            task.resume()
        } else {
            var components = URLComponents(string: "https://csci-571-363723.wl.r.appspot.com/google")!
            components.queryItems = [
                URLQueryItem(name: "url", value: "https://maps.googleapis.com/maps/api/geocode/json?address=" + location + "&key=AIzaSyDZQNW6Ut1G3ySELQPBUsI6JpdatAUyxvo")
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
                        if let resultsArray = dict["results"] as? [Any] {
                            if let resultsJson = resultsArray[0] as? [String: Any] {
                                if let geometry = resultsJson["geometry"] as? [String: Any] {
                                    if let location = geometry["location"] as? [String: Any] {
                                        if let lat = location["lat"] as? Double {
                                            latitude = String(lat)
                                        }
                                        if let lng = location["lng"] as? Double {
                                            longitude = String(lng)
                                        }
                                        search(latitude: latitude, longitude: longitude)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    func search(latitude: String, longitude: String) {
        print("search()")
        var components = URLComponents(string: "https://csci-571-363723.wl.r.appspot.com/yelp")!
        let rDistance = String(Int(round(Double(distance)! * 1609.34)))
        var queryValue = "https://api.yelp.com/v3/businesses/search?term=" + keyword
        queryValue += "&latitude=" + latitude + "&longitude=" + longitude
        queryValue += "&category=" + category + "&radius=" + rDistance
        queryValue += "&limit=10"
        components.queryItems = [
            URLQueryItem(name: "url", value: queryValue)
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
                    if let businesses = dict["businesses"] as? [Any] {
                        do {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            results = try decoder.decode([Business].self, from: JSONSerialization.data(withJSONObject: businesses))
                            print(results)
                            if (results.isEmpty) {
                                noResults = true
                            } else {
                                noResults = false
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    func clear() {
        keyword = ""
        distance = "10"
        category = "all"
        location = ""
        autoDetect = false
        submitted = false
        results = [Business]()
        noResults = false
    }
}

struct Business: Identifiable, Codable {
    let id: String
    let name: String
    let imageUrl: String
    let rating: Double
    let distance: Double
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
