

import UIKit
import CoreLocation
import Foundation
import MapKit
import NotificationCenter

class GeofencingViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManger:CLLocationManager?
    var notificationCenter: UNUserNotificationCenter?
    
    var geofences: [Geofence] = []
    var timer: Timer?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.notificationCenter = UNUserNotificationCenter.current()
        notificationCenter?.delegate = self
        let options: UNAuthorizationOptions = [.alert, .sound]
        notificationCenter?.requestAuthorization(options: options) { (granted, error) in
            if !granted {
                print("Permission not granted")
            }
        }
        
        locationManger = CLLocationManager()
        locationManger?.delegate = self
        locationManger?.allowsBackgroundLocationUpdates = true
        locationManger?.showsBackgroundLocationIndicator = true
        locationManger?.requestWhenInUseAuthorization()
        locationManger?.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        
    }
    
    func stopLocationUpdates(){
        locationManger?.stopUpdatingLocation()
    }
    
    func createGeoFence(_ geofence: Geofence){
        let geofenceRegionCenter = CLLocationCoordinate2DMake(geofence.lat!, geofence.lng!)
        
        let geofenceRegion = CLCircularRegion(center: geofenceRegionCenter,
                                              radius: geofence.radius!,
                                              identifier: geofence.identifier!)
        geofenceRegion.notifyOnExit = true
        geofenceRegion.notifyOnEntry = true
        locationManger!.startMonitoring(for: geofenceRegion)
    }
    
    func showAddRegionAlert(){
        let alert = UIAlertController(title: "Add a Geofence", message: "Describe latitude,longitude and radius to create a geofence.\n Note: All fields are mandatory", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Latitude*"
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Longitude*"
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Radius*"
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Identifier*"
            textField.tag = STRING_TEXTFIELD_TAG
        }
        
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (_) in
            let latTF = alert?.textFields![0]
            let lngTF = alert?.textFields![1]
            let radiusTF = alert?.textFields![2]
            let identifierTF = alert?.textFields![3]
            
            for tf in alert!.textFields!{
                if tf.text!.isEmpty{
                    self.alert(message: "All fields are mandatory")
                    return
                }
            }
            let geofence = Geofence(lat: Double(latTF?.text! ?? "34.475951"), lng: Double(lngTF?.text! ?? "78.40256"), radius: Double(radiusTF?.text! ?? "100"), identifier: identifierTF?.text)
            self.geofences.append(geofence)
            self.addRegion(geofence)
            self.createGeoFence(geofence)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        for tf in alert.textFields!{
            tf.delegate = self
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func addRegion(_ geofence: Geofence){
        if mapView.overlays.count>0{
            mapView.removeOverlay(mapView.overlays.first!)
        }
        let myLocation = CLLocationCoordinate2DMake(geofence.lat!,geofence.lng!)
        let coordinateRegion = MKCoordinateRegion(center: myLocation, latitudinalMeters: geofence.radius! * 4, longitudinalMeters:geofence.radius! * 4)
        mapView.setRegion(coordinateRegion, animated: true)
        let location = CLLocationCoordinate2DMake(geofence.lat! , geofence.lng!)
        let circle = MKCircle(center: location, radius: geofence.radius! as CLLocationDistance)
        self.mapView.addOverlay(circle)
    }
    
    func handleEvent(forRegion region: CLRegion!, geofenceEventType: GeofenceEventType) {
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        switch geofenceEventType{
        case .entry:
            
            content.title = "Welcome to \(region.identifier)"
            content.body = "Nice to have you here"
        case .exit:
            content.title = "Goodbye"
            content.body = "Hope to see you again"
        }
        showNotification(forRegion: region, content: content)
    }
    
    func showNotification(forRegion region: CLRegion!, content: UNMutableNotificationContent){
        let identifier = region.identifier
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: nil)
        notificationCenter?.add(request, withCompletionHandler: { (error) in
            if error != nil {
                print("Error adding notification with identifier: \(identifier)")
            }
        })
    }
    
    @IBAction func didTapAddGeofence(_ sender: Any) {
        showAddRegionAlert()
    }
}



