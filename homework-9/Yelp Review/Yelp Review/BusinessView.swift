//
//  BusinessView.swift
//  Yelp Review
//
//  Created by Nicolas Neven on 11/20/22.
//

import SwiftUI

func reserve() {
    
}

struct BusinessView: View {
    var business: Detail?
    @State var reserved = false
    
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
                Button(action: reserve) {
                    Text(reserved ? "Cancel Reservation" : "Reserve Now")
                        .foregroundColor(.white)
                        .padding()
                }
                .background(RoundedRectangle(cornerRadius: 12).fill(reserved ? .blue : .red))
                .buttonStyle(BorderlessButtonStyle())
                HStack {
                    Text("Share on:")
                        .bold()
                    var facebook = "https://www.facebook.com/sharer/sharer.php?u="
                    // facebook += (business?.url ?? "").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    var twitter = "https://twitter.com/intent/tweet?text="
                    // var twitterQuery = "Check " + business?.name ?? "" + " on Yelp. " + business?.url ?? ""
                    // twitterQuery = twitterQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    Link(destination: URL(string: facebook)!) {
                        Image("Facebook")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                    Link(destination: URL(string: twitter)!) {
                        Image("Twitter")
                            .resizable()
                            .frame(width: 50, height: 50)
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
        }
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
