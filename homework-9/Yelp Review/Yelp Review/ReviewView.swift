//
//  ReviewsView.swift
//  Yelp Review
//
//  Created by Nicolas Neven on 11/22/22.
//

import SwiftUI

struct ReviewView: View {
    var reviews: [Review]
    
    var body: some View {
        List {
            Section {
                ForEach(reviews) { review in
                    VStack {
                        HStack {
                            Text(review.user.name)
                                .bold()
                            Spacer()
                            Text(String(review.rating) + "/5")
                                .bold()
                        }
                        Text(review.text)
                            .foregroundColor(.gray)
                            .padding([.top], 1)
                        Text(review.timeCreated.prefix(10))
                            .padding([.top], 1)
                    }
                    .padding()
                }
            }
        }
    }
}

struct ReviewView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewView(reviews: [Review(id: "Bv-4SKgXzsD9FmUg4oe4mw", rating: 5, user: User(name: "Monica C."), text: "Came here on a whim because my boyfriend and I both had a sweet tooth, and were both craving something sweet. So we both looked up dessert spots that were...", timeCreated: "2022-11-27 00:15:40"), Review(id: "MvJHPkpcluhZecsKmWMMLw", rating: 4, user: User(name: "Kirsty L."), text: "24 hour donut shop? I\'m in! \n\nI went early in the morning and the donuts were fresh and plentiful. Service was fast and they were so kind, considering I put...", timeCreated: "2022-11-10 22:02:22"), Review(id: "EEhaGQTPIFf13jbbwtP6Tg", rating: 3, user: User(name: "Yen N."), text: "Finally got to try CA donuts after many many years of hypes and long lines \n\nLove that they are 24 hours and they have quite unique and different flavors....", timeCreated: "2022-10-20 08:14:48")])
    }
}
