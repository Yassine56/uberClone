//
//  ViewController.swift
//  uberClone
//
//  Created by Abouelouafa Yassine on 12/5/17.
//  Copyright © 2017 Abouelouafa Yassine. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    var signUpMode = true
    @IBOutlet var email: UITextField!
    @IBOutlet var driverLabel: UILabel!
    
    @IBOutlet var riderLabel: UILabel!
    @IBOutlet var downButton: UIButton!
    @IBOutlet var topButton: UIButton!
    @IBOutlet var switchDriverRider: UISwitch!
    @IBOutlet var password: UITextField!
    
    func displayAlert(title:String , message:String){
         let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alertController, animated: true, completion: nil )
    }
    
    @IBAction func topButtonTapped(_ sender: Any) {
        if (email.text == "" || password.text == "") {
            displayAlert(title: "Missing information", message: "provide email and password")
        } else {
            if let emailString = email.text {
                if let passwordString = password.text {
                    if signUpMode {
                        // signup
                        
                        Auth.auth().createUser(withEmail: emailString, password: passwordString , completion: { (user, error) in
                            if error != nil {
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                            } else {
                                print("signup success")
                                if self.switchDriverRider.isOn {
                                    // driver signup
                                    
                                    let changerequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                    changerequest?.displayName = "Driver"
                                    changerequest?.commitChanges(completion: nil)
                                    self.performSegue(withIdentifier: "driverSeguee", sender: nil)
                                    
                                } else {
                                    // rider signup
                                let changerequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                changerequest?.displayName = "Rider"
                                changerequest?.commitChanges(completion: nil)
                                self.performSegue(withIdentifier: "riderSeguee", sender: nil)
                                }
                            }
                        })
                        
                    } else {
                        // login
                        Auth.auth().signIn(withEmail: emailString, password: passwordString, completion: { (user, error) in
                            if error != nil {
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                            } else {
                                print("login success")
                                if user?.displayName == "Rider" {
                                    
                                    self.performSegue(withIdentifier: "riderSeguee", sender: nil)
                                } else if user?.displayName == "Driver" {
                                    self.performSegue(withIdentifier: "driverSeguee", sender: nil)
                                }
                                
                            }
                        })
                    }
                }
            }
            
        }
    }
    
    @IBAction func downButtonTapped(_ sender: Any) {
        if signUpMode {
            topButton.setTitle("Log in", for: .normal)
            downButton.setTitle("Sign up", for: .normal)
            riderLabel.isHidden = true
            driverLabel.isHidden = true
            switchDriverRider.isHidden = true
            signUpMode = false
        }else {
            topButton.setTitle("Sign up", for: .normal)
            downButton.setTitle("Log in", for: .normal)
            riderLabel.isHidden = false
            driverLabel.isHidden = false
            switchDriverRider.isHidden = false
            signUpMode = true
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

