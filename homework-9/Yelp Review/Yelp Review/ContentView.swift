//
//  ContentView.swift
//  Yelp Review
//
//  Created by Nicolas Neven on 11/20/22.
//

import SwiftUI

struct ContentView: View {
        
    @State var keyword = ""
    @State var distance = "10"
    @State var category = "all"
    @State var location = ""
    @State var autoDetect = false
    @State var submitted = false
    @State var results = [Business]()

    var body: some View {
        NavigationView {
            VStack {
                Group {
                    Form {
                        Section {
                            HStack {
                                Text("Keyword:").foregroundColor(.gray)
                                TextField("Required", text: $keyword)
                            }
                            HStack {
                                Text("Distance:").foregroundColor(.gray)
                                TextField("Required", text: $distance)
                            }
                            HStack {
                                Picker("Category:", selection: $category) {
                                    Text("Default")
                                    Text("Arts and Entertainment")
                                    Text("Health and Medical")
                                    Text("Hotels and Travel")
                                    Text("Food")
                                    Text("Proffesional Services")
                                }
                                .foregroundColor(.gray)
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
                                .background(RoundedRectangle(cornerRadius: 8).fill(keyword.isEmpty || location.isEmpty ? .gray : .red))
                                .disabled(keyword.isEmpty || location.isEmpty)
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
                            if submitted && results.isEmpty {
                                Text("No results available").foregroundColor(.red)
                            } else {
                                List(results) { business in
                                    HStack {
                                        Text(String(business.id))
                                        Image(business.image)
                                        Text(business.name)
                                        Text(String(business.rating))
                                        Text(String(business.distance))
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Business Search")
            }
            .toolbar {
                NavigationLink(destination: Reservations(), label: {
                    Image(systemName: "calendar.badge.clock")
                })
            }
            
        }
    }
    
    func submit() {
        print("submit()", keyword, distance, category, location)
        // API CALL
        
        submitted = true
    }
    
    func clear() {
        keyword = ""
        distance = "10"
        category = "all"
        location = ""
        autoDetect = false
        submitted = false
        results = [Business]()
    }
}

struct Business: Identifiable {
    var id: Int
    var name: String
    var image: String
    var rating: Float
    var distance: Float
    
    init(id: Int, name: String, image: String, rating: Float, distance: Float) {
        self.id = id
        self.name = name
        self.image = image
        self.rating = rating
        self.distance = distance
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
