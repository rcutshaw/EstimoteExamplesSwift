//
//  ESTMotionUUIDSettingsDemoVC.swift
//  ExamplesSwift
//
//  Ported to Swift by David Cutshaw on 6/25/15.
//  Copyright © 2015 Bit Smartz LLC. All rights reserved.
//

import UIKit

class ESTMotionUUIDSettingsDemoVC: UIViewController, ESTBeaconConnectionDelegate {

    var beaconConnection: ESTBeaconConnection?
    @IBOutlet weak var accelerometerSwitch: UISwitch?
    @IBOutlet weak var motionUUIDSwitch: UISwitch?
    @IBOutlet weak var activityLabel: UILabel?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    
    func initWithBeacon(beacon: CLBeacon) -> ESTMotionUUIDSettingsDemoVC? {
        
        if let _:ESTMotionUUIDSettingsDemoVC = ESTMotionUUIDSettingsDemoVC()
        {
            self.beaconConnection = ESTBeaconConnection.init(beacon: beacon,
                delegate: self,
                startImmediately: false)
        }
        return self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSBundle.mainBundle().loadNibNamed("ESTMotionUUIDSettingsDemoVC", owner: self, options: nil)
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.title = "Motion Detection Settings"
        
        /**
        *  In order to adjust beacon accelerometer and motion UUID settings
        *  you need to connect to it first.
        */
        
        self.beaconConnection!.startConnection()
        
        self.activityIndicator!.startAnimating()
        
        self.accelerometerSwitch!.enabled = false
        self.motionUUIDSwitch!.enabled = false
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.beaconConnection!.cancelConnection()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: ESTBeaconDelegate
    
    func beaconConnectionDidSucceed(connection: ESTBeaconConnection!) {
        self.activityIndicator!.stopAnimating()
        self.activityIndicator!.alpha = 0.0
        self.activityLabel!.text = "Connected!"
        
        if self.beaconConnection!.motionDetectionState != ESTBeaconMotionDetection.Unsupported
        {
            self.accelerometerSwitch!.enabled = true
            self.accelerometerSwitch!.setOn(self.beaconConnection!.motionDetectionState == .On, animated: true)
        }
        
        if self.beaconConnection!.motionUUIDState != ESTBeaconMotionUUID.Unsupported
        {
            self.motionUUIDSwitch!.enabled = true
            self.motionUUIDSwitch!.setOn(self.beaconConnection!.motionUUIDState == ESTBeaconMotionUUID.On, animated: true)
        }
    }
    
    func beaconConnection(connection: ESTBeaconConnection!, didFailWithError error: NSError!) {
        print("Something went wrong. Beacon connection Did Fail. Error: %@", error)
        
        self.activityIndicator!.stopAnimating()
        self.activityIndicator!.alpha = 0.0
        
        self.activityLabel!.text = "Connection failed"
        self.activityLabel!.textColor = UIColor.redColor()
        
        if #available(iOS 8.0, *) {
            let alert: UIAlertController = UIAlertController.init(title: "Connection error",
                message: error.localizedDescription,
                preferredStyle: .Alert)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let errorView = UIAlertView(title: "Connection error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
            errorView.show()
        }
    }
    
    // MARK: Switch tap handling
    
    @IBAction func accelerometerSwitchValueChanged() {
        self.accelerometerSwitch!.enabled = false
        
        /**
        *  Here you can see how simple it is to enable beacons's accelerometer.
        *  As you can see this method can be invoked only when phone is connected
        *  to the beacon.
        */
        // Using [weak self] to eliminate retain cycle
        self.beaconConnection!.writeMotionDetectionEnabled(self.accelerometerSwitch!.on, completion: {
            [weak self] (value:Bool, error:NSError?) -> () in
            self!.accelerometerSwitch!.setOn(value, animated: true)
            self!.accelerometerSwitch!.enabled = true
        })
    }
    
    @IBAction func motionUUIDSwitchValueChanged() {
        self.motionUUIDSwitch!.enabled = false
        
        /**
        *  Here you can see how simple it is to enable beacons's motion UUID feature.
        *  As you can see this method can be invoked only when phone is connected
        *  to the beacon.
        */
        // Using [weak self] to eliminate retain cycle
        self.beaconConnection!.writeMotionUUIDEnabled(self.motionUUIDSwitch!.on, completion: {
            [weak self] (value:Bool, error:NSError?) -> () in
            self!.motionUUIDSwitch!.setOn(value, animated: true)
            self!.motionUUIDSwitch!.enabled = true
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
