//
//  DriverTableViewController.swift
//  uberClone
//
//  Created by Abouelouafa Yassine on 12/7/17.
//  Copyright © 2017 Abouelouafa Yassine. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit
class DriverTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var userLocation = CLLocation()
    var ridesRequests : [DataSnapshot] = []
    @IBAction func logoutTapped(_ sender: Any) {
        try? Auth.auth().signOut()
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if let coordinate = locationManager.location?.coordinate {
            userLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
        
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        let ref = Database.database().reference()
        ref.child("ridesRequests").observe(.childAdded) { (snapshot) in
            if let rideRequestsDict = snapshot.value as? [String:AnyObject] {
                if let DriverLat = rideRequestsDict["driverLat"] as? Double{
                    
                }else {
                    self.ridesRequests.append(snapshot)
                    self.tableView.reloadData()
                }
            }
            
       
        }
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (timer) in
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ridesRequests.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rideRequestCell", for: indexPath)
        
        if let riderequestsData = ridesRequests[indexPath.row].value as? [String:AnyObject] {
            if let email = riderequestsData["email"] as? String {
                // cell.textLabel?.text = email
                if let lat = riderequestsData["lat"] as? Double {
                    if let lon = riderequestsData["lon"] as? Double {
                        let riderLocation = CLLocation(latitude: lat, longitude: lon)
                        let distance = userLocation.distance(from: riderLocation) / 1000
                        let roundedDistance = round(distance * 100) / 100
                        
                        cell.textLabel?.text = "\(email) is \(roundedDistance)km away"
                        
                    }
                }
                
            }
        }
        
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = ridesRequests[indexPath.row]
        self.performSegue(withIdentifier: "rideRequestSegue", sender: snapshot)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? RideRequestViewController {
        if let snapshot = sender as? DataSnapshot {
            if let datasnapshot = snapshot.value as? [String:AnyObject] {
                if let email = datasnapshot["email"] as? String{
                    if let lon = datasnapshot["lon"] as? Double {
                        if let lat = datasnapshot["lat"] as? Double {
                            let riderLocation = CLLocation(latitude: lat, longitude: lon)
                            destinationVC.riderLocation = riderLocation
                            destinationVC.riderEmail = email
                            destinationVC.driverLocation = userLocation
                        }
                    }
                }
            }
        }
    }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
 
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
