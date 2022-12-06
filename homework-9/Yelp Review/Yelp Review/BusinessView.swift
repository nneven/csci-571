//
//  BusinessView.swift
//  Yelp Review
//
//  Created by Nicolas Neven on 11/20/22.
//

import SwiftUI

struct BusinessView: View {
    var business: Detail?
    @State var reserved = false
    @State var showReserve = false
    @State var email = ""
    @State var date = Date()
    @State var hour = "10"
    @State var min = "00"
    @State var showToast = false
    @State var showConfirm = false
    @State var showCancel = false
    
    func reserve() {
        print(business?.name ?? "", email, date.formatted(date: .numeric, time: .omitted).replacingOccurrences(of: "/", with: "-"), hour, min)
        
        if (!email.contains("@")) {
            showToast.toggle()
        } else {
            showReserve.toggle()
            showConfirm.toggle()
            
            var components = URLComponents(string: "https://csci-571-363723.wl.r.appspot.com/reservation")!
            components.queryItems = [
                URLQueryItem(name: "business", value: business?.name ?? ""),
                URLQueryItem(name: "email", value: email),
                URLQueryItem(name: "date", value: date.formatted(date: .numeric, time: .omitted).replacingOccurrences(of: "/", with: "-")),
                URLQueryItem(name: "time", value: hour + ":" + min)
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
                    if let reservations = json as? [Any] {
                        do {
                            let decoder = JSONDecoder()
                            let results = try decoder.decode([Reservation].self, from: JSONSerialization.data(withJSONObject: reservations))
                            print(results)
                        } catch {
                            print(error)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    var body: some View {
        if (business == nil) {
            ProgressView()
        } else {
            VStack {
                Spacer()
                Text(business?.name ?? "")
                    .font(.title)
                    .bold()
                VStack {
                    HStack {
                        VStack {
                            Text("Address")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .bold()
                            Text(business?.location.displayAddress.joined(separator: " ") ?? "")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.gray)
                        }
                        VStack {
                            Text("Category")
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .bold()
                            Text(getCategory(categories: business?.categories ?? []))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding([.top, .bottom], 4)
                    HStack {
                        VStack {
                            Text("Phone")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .bold()
                            Text(business?.displayPhone ?? "")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.gray)
                        }
                        VStack {
                            Text("Price Range")
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .bold()
                            Text(business?.price ?? "")
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding([.top, .bottom], 4)
                    HStack {
                        VStack {
                            Text("Status")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .bold()
                            Text(business?.isClosed ?? false ? "Closed" : "Open Now")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(business?.isClosed ?? false ? .red : .green)
                        }
                        VStack {
                            Text("Visit Yelp for more")
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .bold()
                            Link("Business Link", destination: URL(string: business?.url ?? "")!)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                }
                .padding([.leading, .trailing], 16)
                if (!reserved) {
                    Button(action: {
                        showReserve.toggle()
                    }) {
                        Text("Reserve Now")
                            .foregroundColor(.white)
                            .padding()
                    }
                    .background(RoundedRectangle(cornerRadius: 12).fill(.red))
                    .sheet(isPresented: $showReserve) {
                        Form {
                            Section {
                                HStack {
                                    Spacer()
                                    Text("Reservation Form")
                                        .fontWeight(.bold)
                                        .font(.title)
                                    Spacer()
                                }
                            }
                            Section {
                                HStack {
                                    Spacer()
                                    Text(business?.name ?? "")
                                        .fontWeight(.semibold)
                                        .font(.title)
                                    Spacer()
                                }
                            }
                            Section {
                                HStack {
                                    Text("Email:").foregroundColor(.gray)
                                    TextField("", text: $email)
                                }
                                .padding([.top, .bottom], 16)
                                HStack {
                                    Text("Date/Time:").foregroundColor(.gray)
                                    DatePicker("", selection: $date, in: Date()..., displayedComponents: [.date])
                                        .padding(.leading, -12)
                                    HStack {
                                        Picker("", selection: $hour) {
                                            Text("10").tag("10")
                                            Text("11").tag("11")
                                            Text("12").tag("12")
                                            Text("13").tag("13")
                                            Text("14").tag("14")
                                            Text("15").tag("15")
                                            Text("16").tag("16")
                                            Text("17").tag("17")
                                        }
                                        .padding(.leading, -18)
                                        .pickerStyle(.menu)
                                        .tint(.black)
                                        Text(":")
                                        Picker("", selection: $min) {
                                            Text("00").tag("00")
                                            Text("15").tag("15")
                                            Text("30").tag("30")
                                            Text("45").tag("45")
                                        }
                                        .padding(.leading, -32)
                                        .pickerStyle(.menu)
                                        .tint(.black)
                                    }
                                    .background(Color(red: 0.94, green: 0.94, blue: 0.94).clipShape(RoundedRectangle(cornerRadius: 8)))
                                }
                                .padding([.top, .bottom], 16)
                                HStack {
                                    Spacer()
                                    Button(action: reserve) {
                                        Text("Submit")
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 16)
                                            .padding()
                                    }
                                    .background(RoundedRectangle(cornerRadius: 12).fill(.blue))
                                    Spacer()
                                }
                                .padding([.top, .bottom], 16)
                            }
                        }
                        .toast(isShowing: $showToast, text: Text("Please enter a valid email"))
                    }
                    .sheet(isPresented: $showConfirm) {
                        VStack {
                            Spacer()
                            Text("Congratulations!")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .bold()
                            Text("You have succesfully made a reservation at " + (business?.name ?? ""))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .padding()
                            Spacer()
                            Button(action: {
                                reserved = true
                                showConfirm.toggle()
                            }) {
                                Text("Done")
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 32)
                                    .padding()
                            }
                            .background(RoundedRectangle(cornerRadius: 32).fill(.white))
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                    }
                    .background(RoundedRectangle(cornerRadius: 12).fill(.red))
                    .buttonStyle(BorderlessButtonStyle())
                } else {
                    Button(action: {
                        reserved = false
                        showCancel.toggle()
                        
                        var components = URLComponents(string: "https://csci-571-363723.wl.r.appspot.com/cancel")!
                        components.queryItems = [
                            URLQueryItem(name: "index", value: "0")
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
                                        let reservations = try decoder.decode([Reservation].self, from: JSONSerialization.data(withJSONObject: reservationsArray))
                                        print(reservations)
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                        }
                        task.resume()
                    }) {
                        Text("Cancel Reservation")
                            .foregroundColor(.white)
                            .padding()
                    }
                    .background(RoundedRectangle(cornerRadius: 12).fill(.blue))
                    .buttonStyle(BorderlessButtonStyle())
                }
                HStack {
                    Text("Share on:")
                        .bold()
                    let facebook = (business?.url ?? "").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    let twitter = ("Check " + (business?.name ?? "") + " on Yelp. " + (business?.url ?? "")).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    if let url = URL(string: "https://www.facebook.com/sharer/sharer.php?u=\(facebook)") {
                        Link(destination: url) {
                            Image("Facebook")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                    }
                    if let url2 = URL(string: "https://twitter.com/intent/tweet?text=\(twitter)") {
                        Link(destination: url2) {
                            Image("Twitter")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                    }

                }
                .padding([.top])
                TabView {
                    AsyncImage(url: URL(string: business?.photos[0] ?? "")) { image in
                        image.resizable()
                    } placeholder: {
                        // ProgressView()
                    }
                    .frame(width: 300, height: 250)
                    AsyncImage(url: URL(string: business?.photos[1] ?? "")) { image in
                        image.resizable()
                    } placeholder: {
                        // ProgressView()
                    }
                    .frame(width: 300, height: 250)
                    AsyncImage(url: URL(string: business?.photos[2] ?? "")) { image in
                        image.resizable()
                    } placeholder: {
                        // ProgressView()
                    }
                    .frame(width: 300, height: 250)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                Spacer()
            }
            .toast(isShowing: $showCancel, text: Text("Your reservation is cancelled"))
        }
    }
}

struct Toast<Presenting>: View where Presenting: View {
    @Binding var isShowing: Bool
    let presenting: () -> Presenting
    let text: Text

    var body: some View {
        if self.isShowing {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.isShowing = false
            }
        }
        return GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                self.presenting()
                VStack {
                    self.text
                }
                .frame(width: geometry.size.width / 1.5,
                       height: geometry.size.height / 8)
                .background(Color.secondary.colorInvert())
                .foregroundColor(Color.primary)
                .cornerRadius(20)
                .transition(.identity)
                .opacity(self.isShowing ? 1 : 0)
            }
        }
    }
}

extension View {
    func toast(isShowing: Binding<Bool>, text: Text) -> some View {
        Toast(isShowing: isShowing,
              presenting: { self },
              text: text)
    }
}

func getCategory(categories: [Category]) -> String {
    var result = ""
    for category in categories {
        result += category.title + " | "
    }
    if (result != "") {
        result.removeLast()
        result.removeLast()
        result.removeLast()
    }
    return result
}

struct BusinessView_Previews: PreviewProvider {
    static var previews: some View {
        BusinessView(
            business:
                Detail(id: "AUbKbVQAUNI6Vr6LYtOZzA",
                       name: "California Donuts",
                       location: Location(displayAddress: ["3540 W 3rd St", "Los Angeles, CA 90020"]),
                       categories: [Category(title: "Bakeries"), Category(title: "Donuts"), Category(title: "Coffee & Tea")],
                       displayPhone: "(213) 385-3318",
                       price: Optional("$$"),
                       isClosed: false, url: "https://www.yelp.com/biz/california-donuts-los-angeles-2?adjust_creative=AC8xaQ6HRAv3KXHOg2qmkg&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_lookup&utm_source=AC8xaQ6HRAv3KXHOg2qmkg",
                       photos: ["https://s3-media2.fl.yelpcdn.com/bphoto/f4qoSJYs1SFdOU2pYaGMWQ/o.jpg", "https://s3-media3.fl.yelpcdn.com/bphoto/xFJcoSaXM4F9KyZHOU4Mqw/o.jpg", "https://s3-media2.fl.yelpcdn.com/bphoto/dIAVaGk-Kf1Y8Rpua4jwMg/o.jpg"],
                       coordinates: Coordinates(latitude: 34.068796, longitude: -118.293089)))
    }
}
