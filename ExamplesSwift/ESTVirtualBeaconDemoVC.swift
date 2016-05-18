//
//  ESTVirtualBeaconDemoVC.swift
//  ExamplesSwift
//
//  Ported to Swift by David Cutshaw on 6/18/15.
//  Copyright © 2015 Bit Smartz LLC. All rights reserved.
//

//import Foundation
import UIKit

class ESTVirtualBeaconDemoVC: UIViewController, ESTBeaconManagerDelegate {
    
    // MARK: Lifecycle
    
    var beaconManager: ESTBeaconManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Virtual Beacon"
        
        // Create beacon manager
        self.beaconManager = ESTBeaconManager()
        self.beaconManager!.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        // Start advertising as ibeacon by providing required information
        // when view appears on the screen
        self.beaconManager!.startAdvertisingWithProximityUUID(NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D"),
            major:1111,
            minor:2222,
            identifier:"VirtualBeacon")
    }
    
    override func viewDidDisappear(animated: Bool) {
        // stop advertising when leaving screen
        self.beaconManager!.stopAdvertising()
    }
    
    // MARK: ESTBeaconManager delegate handling
    
    func beaconManagerDidStartAdvertising(manager: AnyObject!, error: NSError!) {
        // Advertising failed - usually when you try
        // to advertise when previous advertising wasn't stopped.
        if ((error) != nil)
        {
            if #available(iOS 8.0, *) {
                let alert: UIAlertController = UIAlertController.init(title: "Advertising error!",
                                     message: error.localizedDescription,
                              preferredStyle: .Alert)
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
                let alertView: UIAlertView? = UIAlertView(title: "Advertising error!",
                                                         message: error.localizedDescription,
                                                         delegate: nil,
                                                         cancelButtonTitle: "OK")
                alertView!.show()
            }
        }
    }

}