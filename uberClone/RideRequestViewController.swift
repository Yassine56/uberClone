//
//  RideRequestViewController.swift
//  uberClone
//
//  Created by Abouelouafa Yassine on 12/7/17.
//  Copyright © 2017 Abouelouafa Yassine. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class RideRequestViewController: UIViewController {

    var riderEmail = ""
    var riderLocation = CLLocation()
    var driverLocation = CLLocation()
    @IBOutlet var map: MKMapView!
    
    
    
    
    @IBAction func accepteRequestTapped(_ sender: Any) {
        
    }
    @IBAction func backTapped(_ sender: Any) {
        print("back tapped")
        performSegue(withIdentifier: "backtoDriverTableviewSegue", sender: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let region = MKCoordinateRegion(center: riderLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: true)
        
        
        let riderannotation = MKPointAnnotation()
        riderannotation.coordinate = riderLocation.coordinate
        riderannotation.title = "client Location"
        
        map.center = CGPoint(x: riderLocation.coordinate.latitude, y: riderLocation.coordinate.longitude)
        map.addAnnotation(riderannotation)
        
        // Do any additional setup after loading the view.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
   
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func AccepteTapped(_ sender: Any) {
        
        let ref = Database.database().reference()
        ref.child("ridesRequests").queryOrdered(byChild: "email").queryEqual(toValue: riderEmail).observe(.childAdded) { (snapshot) in
            snapshot.ref.updateChildValues(["driverLon":self.driverLocation.coordinate.longitude, "driverLat":self.driverLocation.coordinate.latitude])
        }
        
        let requestCLLocation = CLLocation(latitude: riderLocation.coordinate.latitude, longitude: riderLocation.coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count > 0 {
                     let placemark = MKPlacemark(placemark: placemarks[0])
                     let mapItem = MKMapItem(placemark: placemark)
                     mapItem.name = self.riderEmail
                    let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                     mapItem.openInMaps(launchOptions: options)
                    
                    
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
