//
//  RiderViewController.swift
//  uberClone
//
//  Created by Abouelouafa Yassine on 12/6/17.
//  Copyright © 2017 Abouelouafa Yassine. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth

class RiderViewController: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet var uberlabel: UIButton!
    @IBOutlet var mapOutlet: MKMapView!
    var locationManage = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    var uberAlreadybeenCalled = false
    var driverOnTheWay = false
    var driverLocation = CLLocation()
    
    
    
    @IBAction func uberTapped(_ sender: Any) {
        if driverOnTheWay == false {
        if let user = Auth.auth().currentUser {
            if let email = user.email {
        if uberAlreadybeenCalled {
            
            
           
            var ref: DatabaseReference
            ref = Database.database().reference()
            ref.child("ridesRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                snapshot.ref.removeValue()
                ref.child("ridesRequests").removeAllObservers()
            })
            uberlabel.setTitle("Call an uber", for: .normal )
            uberAlreadybeenCalled = false
            
        }else {
           
                    let rideRequestDictionary : [String:Any] = ["email":email, "lat":userLocation.latitude, "lon":userLocation.longitude]
                    
                    var ref: DatabaseReference
                    ref = Database.database().reference()
                    ref.child("ridesRequests").childByAutoId().setValue(rideRequestDictionary )
                    uberAlreadybeenCalled = true
                    uberlabel.setTitle("Cancel Uber", for: .normal )
            
        }
            }
            
        }
        
        
    
    }
    }
    
    func displayDriverRider() {
        
        mapOutlet.removeAnnotations(mapOutlet.annotations)
        
        let riderLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let distance = driverLocation.distance(from: riderLocation) / 1000
        let roundedDistance = round(distance * 100)/100
        self.uberlabel.setTitle("Your driver is \(roundedDistance) away", for: .normal)
        let latDelta = abs(userLocation.latitude - driverLocation.coordinate.latitude) * 2 + 0.005
        let lonDelta = abs(userLocation.longitude - driverLocation.coordinate.longitude) * 2 + 0.005
        let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
        mapOutlet.setRegion(region, animated: true)
        
        let userAnnotation = MKPointAnnotation()
        userAnnotation.coordinate = userLocation
        userAnnotation.title = "Your location"
        
        let driverAnnotation = MKPointAnnotation()
        driverAnnotation.coordinate = driverLocation.coordinate
        driverAnnotation.title = "Your driver location"
        
        mapOutlet.addAnnotation(userAnnotation)
        mapOutlet.addAnnotation(driverAnnotation)
        
        
    }
    
    @IBAction func logOutTapped(_ sender: Any) {
        
        try? Auth.auth().signOut()
            
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManage.delegate = self
        locationManage.desiredAccuracy = kCLLocationAccuracyBest
        locationManage.requestWhenInUseAuthorization()
        locationManage.startUpdatingLocation()
        
        if let user = Auth.auth().currentUser {
            if let email = user.email {
                
                var ref: DatabaseReference
                ref = Database.database().reference()
                ref.child("ridesRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                    self.uberAlreadybeenCalled = true
                    self.uberlabel.setTitle("Cancel Uber", for: .normal )
                    ref.child("ridesRequests").removeAllObservers()
                    if let rideRequestsDict = snapshot.value as? [String:AnyObject] {
                        if let DriverLat = rideRequestsDict["driverLat"] as? Double{
                            if let DriverLon = rideRequestsDict["driverLon"] as? Double{
                                self.driverLocation = CLLocation(latitude: DriverLat, longitude: DriverLon)
                                self.driverOnTheWay = true
                                self.displayDriverRider()
                                if let email = Auth.auth().currentUser?.email{
                                    Database.database().reference().child("ridesRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childChanged, with: { (snapshot) in
                                        if let rideRequestsDict = snapshot.value as? [String:AnyObject] {
                                            if let DriverLat = rideRequestsDict["driverLat"] as? Double{
                                                if let DriverLon = rideRequestsDict["driverLon"] as? Double{
                                                    self.driverLocation = CLLocation(latitude: DriverLat, longitude: DriverLon)
                                                    self.driverOnTheWay = true
                                                    self.displayDriverRider()
                                                }
                                            }
                                        }
                                    })
                                }
                            }
                        }
                    }
                })
                
            }
        }

        // Do any additional setup after loading the view.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = manager.location?.coordinate {
            let center = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            userLocation = center
           
            if uberAlreadybeenCalled {
                displayDriverRider()
              
            }else {
                mapOutlet.setRegion(region, animated: true)
                print("location update")
                mapOutlet.removeAnnotations(mapOutlet.annotations)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "Your location"
                mapOutlet.addAnnotation(annotation)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
