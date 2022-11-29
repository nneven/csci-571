//
//  MapView.swift
//  Yelp Review
//
//  Created by Nicolas Neven on 11/22/22.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State var place: IdentifiablePlace
    
    var body: some View {
        VStack {
            Map(coordinateRegion: .constant(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: place.location.latitude,
                                               longitude: place.location.longitude),
                latitudinalMeters: 8000,
                longitudinalMeters: 8000
            )),
                annotationItems: [place])
            { place in
                MapMarker(coordinate: place.location)
            }
        }
    }
}

struct IdentifiablePlace: Identifiable {
    let id: UUID
    let location: CLLocationCoordinate2D
    init(id: UUID = UUID(), lat: Double, long: Double) {
        self.id = id
        self.location = CLLocationCoordinate2D(
            latitude: lat,
            longitude: long)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(place: IdentifiablePlace(lat: 34.068796, long: -118.293089))
    }
}
