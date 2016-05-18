//
//  ESTNotificationDemoVC.swift
//  ExamplesSwift
//
//  Ported to Swift by David Cutshaw on 6/23/15.
//  Copyright © 2015 Bit Smartz LLC. All rights reserved.
//

import UIKit

class ESTNotificationDemoVC: UIViewController, ESTBeaconManagerDelegate {

    var beacon: CLBeacon?
    var beaconManager: ESTBeaconManager?
    var beaconRegion: CLBeaconRegion?
    @IBOutlet weak var mainView: UIView?
    @IBOutlet weak var enterRegionSwitch: UISwitch?
    @IBOutlet weak var exitRegionSwitch: UISwitch?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSBundle.mainBundle().loadNibNamed("ESTNotificationDemoVC", owner: self, options: nil)
        
        self.title = "Notification Demo"
        
        /*
        * UI setup.
        */
        self.view.backgroundColor = UIColor.whiteColor()
        
        var frame: CGRect = self.mainView!.frame
        frame.origin.y = UIScreen.mainScreen().bounds.size.height - frame.size.height
        self.mainView!.frame = frame
        
        /*
        * Persmission to show Local Notification.
        */
        let application = UIApplication.sharedApplication()
        if application.respondsToSelector("registerUserNotificationSettings:") {
            // iOS 8 or later
            if #available(iOS 8.0, *) {
                let settings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
                application.registerUserNotificationSettings(settings)
            } else {
                // Fallback on earlier versions (iOS 7 or earlier)
                let types: UIRemoteNotificationType = [UIRemoteNotificationType.Badge, UIRemoteNotificationType.Sound, UIRemoteNotificationType.Alert]
                application.registerForRemoteNotificationTypes(types)
            }
        }
        
        /*
        * BeaconManager setup.
        */
        self.beaconManager = ESTBeaconManager()
        self.beaconManager!.delegate = self
        
        self.beaconRegion = CLBeaconRegion.init(
            proximityUUID: self.beacon!.proximityUUID,
            major: UInt16(self.beacon!.major.unsignedIntValue),
            minor: UInt16(self.beacon!.minor.unsignedIntValue),
            identifier: "RegionIdentifier")
        
        self.beaconRegion!.notifyOnEntry = (UIApplication.sharedApplication().delegate! as! ESTAppDelegate).enterSwitchOn
        self.enterRegionSwitch!.on = self.beaconRegion!.notifyOnEntry
        
        self.beaconRegion!.notifyOnExit = (UIApplication.sharedApplication().delegate! as! ESTAppDelegate).exitSwitchOn
        self.exitRegionSwitch!.on = self.beaconRegion!.notifyOnExit
        
        self.beaconManager!.startMonitoringForRegion(self.beaconRegion!)
        print("monitoring turned on")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: ESTBeaconManager delegate
    
    func beaconManager(manager: AnyObject!, monitoringDidFailForRegion region: CLBeaconRegion!, withError error: NSError!) {
        if #available(iOS 8.0, *) {
            let alert: UIAlertController = UIAlertController.init(title: "Monitoring error",
                message: error.localizedDescription,
                preferredStyle: .Alert)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let errorView = UIAlertView(title: "Monitoring error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
            errorView.show()
        }
    }
    
    func beaconManager(manager: AnyObject!, didEnterRegion region: CLBeaconRegion!) {
        let notification: UILocalNotification? = UILocalNotification()
        notification!.alertBody = "Enter region notification"
        print("didEnterRegion")
        UIApplication.sharedApplication().presentLocalNotificationNow(notification!)
    }

    func beaconManager(manager: AnyObject!, didExitRegion region: CLBeaconRegion!) {
        let notification: UILocalNotification? = UILocalNotification()
        notification!.alertBody = "Exit region notification"
        print("didExitRegion")
        UIApplication.sharedApplication().presentLocalNotificationNow(notification!)
    }
    
    // MARK:
    
    @IBAction func switchValueChanged() {
        self.beaconManager!.stopMonitoringForRegion(self.beaconRegion!)
        print("monitoring turned off")
        
        self.beaconRegion!.notifyOnEntry = self.enterRegionSwitch!.on
        (UIApplication.sharedApplication().delegate! as! ESTAppDelegate).enterSwitchOn = self.enterRegionSwitch!.on
        
        self.beaconRegion!.notifyOnExit = self.exitRegionSwitch!.on
        (UIApplication.sharedApplication().delegate! as! ESTAppDelegate).exitSwitchOn = self.exitRegionSwitch!.on
        
        self.beaconManager!.startMonitoringForRegion(self.beaconRegion!)
        print("monitoring turned on")
    }

    /*
    // MARK - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
