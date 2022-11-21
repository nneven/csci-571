//
//  ContentView.swift
//  Yelp Review
//
//  Created by Nicolas Neven on 11/20/22.
//

import SwiftUI

struct ContentView: View {
        
    @State private var keyword = ""
    @State private var distance = "10"
    @State private var category = "Default"
    @State private var location = ""
    @State private var autoDetect = false
    @State private var validForm = false

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
        print("submit()")
    }
    
    func clear() {
        print("clear()")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
