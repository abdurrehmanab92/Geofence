

import CoreLocation
import Foundation
import MapKit
import NotificationCenter

extension GeofencingViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations{
            print(location.coordinate)
            
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus{
        case .notDetermined:
            print("When user did not yet determined")
        case .restricted:
            print("Restricted by parental control")
        case .denied:
            print("When user select option Dont't Allow")
        case .authorizedAlways:
            print("When user select option Allow While Using App or Allow Once")
        case .authorizedWhenInUse:
            locationManger?.requestAlwaysAuthorization()
        @unknown default:
            alert(message: "Unknown case")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        stopLocationUpdates()
        
        if let err = error as? CLError{
            switch err.code{
            case .locationUnknown, .denied, .network:
                alert(message: "Location request failed with error: \(err.localizedDescription)")
            case .headingFailure:
                alert(message: "Heading request failed with error: \(err.localizedDescription)")
            case .rangingFailure, .rangingUnavailable:
                alert(message: "Ranging request failed with error: \(err.localizedDescription)")
            case .regionMonitoringDenied, .regionMonitoringFailure, .regionMonitoringSetupDelayed, .regionMonitoringResponseDelayed:
                alert(message: "Region monitoring request failed with error: \(err.localizedDescription)")
            default:
                alert(message: "Unknown location manager error: \(err.localizedDescription)")
            }
        }else{
            alert(message: "Unknown error occurred while handling location manager error: \(error.localizedDescription)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion{
            var dwellTime = DWELL_TIME
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (Timer) in
                if dwellTime > 0 {
                    print ("\(dwellTime) seconds")
                    dwellTime -= 1
                } else {
                    self.handleEvent(forRegion: region, geofenceEventType: .entry)
                    Timer.invalidate()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion && timer != nil {
            handleEvent(forRegion: region, geofenceEventType: .exit)
            timer?.invalidate()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        alert(message: error.localizedDescription)
    }
}

extension GeofencingViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circle = MKCircleRenderer(overlay: overlay)
        circle.strokeColor = UIColor.green
        circle.fillColor = UIColor(red: 0, green: 255, blue: 0, alpha: 0.1)
        circle.lineWidth = 1
        return circle
    }
}


extension GeofencingViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag != STRING_TEXTFIELD_TAG{
            if textField.text != "" || string != "" {
                let res = (textField.text ?? "") + string
                return Double(res) != nil
            }
        }
        
        return true
    }
}

extension GeofencingViewController: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.banner)
    }
}

extension GeofencingViewController {
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    enum GeofenceEventType{
        case entry, exit
    }
}

