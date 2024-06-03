

import Foundation

struct Geofence{
    var lat: Double?
    var lng: Double?
    var radius: Double?
    var identifier: String?
    var didShowEntryNotification = false //to be implemented
    
    init(lat: Double? = nil, lng: Double? = nil, radius: Double? = nil, identifier: String? = nil) {
        self.lat = lat
        self.lng = lng
        self.radius = radius
        self.identifier = identifier
    }
}
