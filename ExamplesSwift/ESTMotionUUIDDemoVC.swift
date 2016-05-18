//
//  ESTMotionUUIDDemoVC.swift
//  ExamplesSwift
//
//  Ported to Swift by David Cutshaw on 6/25/15.
//  Copyright © 2015 Bit Smartz LLC. All rights reserved.
//

import UIKit
import AudioToolbox

class ESTMotionUUIDDemoVC: UIViewController, ESTBeaconManagerDelegate {

    var shouldVibrate: Bool? = false
    var beacon: CLBeacon?
    var beaconManager: ESTBeaconManager?
    @IBOutlet weak var motionLabel: UILabel?
    @IBOutlet weak var beaconImage: UIImageView?
    
    func initWithBeacon(beacon: CLBeacon) -> ESTMotionUUIDDemoVC? {
        
        if let _:ESTMotionUUIDDemoVC = ESTMotionUUIDDemoVC()
        {
            self.beacon = beacon
        }
        return self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSBundle.mainBundle().loadNibNamed("ESTMotionUUIDDemoVC", owner: self, options: nil)
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.title = "Motion UUID Demo"
        
        self.beaconManager = ESTBeaconManager()
        self.beaconManager!.delegate = self
        
        let motionUUID: NSUUID = ESTBeaconManager.motionProximityUUIDForProximityUUID(self.beacon!.proximityUUID)
        
        let motionRegion: CLBeaconRegion = CLBeaconRegion(proximityUUID: motionUUID,
            major: self.beacon!.major.unsignedShortValue as UInt16,
            minor: self.beacon!.minor.unsignedShortValue as UInt16,
            identifier: "MotionBeaconRegion")
        
        
        self.beaconManager!.startRangingBeaconsInRegion(motionRegion)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Other Methods
    
    func startVibrate() {
        if (self.shouldVibrate == false)
        {
            self.motionLabel!.text = "Beacon in motion"
            
            self.shouldVibrate = true
            self.animateVibration()
        }
    }
    
    func stopVibrate() {
        self.shouldVibrate = false
        
        self.motionLabel!.text = "Beacon not in motion"
    }
    
    func animateVibration() {
        if (self.shouldVibrate == true)
        {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            
            let animation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.duration = 0.6
            animation.values = [ -20, 20, -20, 20, -10, 10, -5, 5, 0 ]
            self.beaconImage!.layer.addAnimation(animation, forKey: "shake")
            
            _ = NSTimer.scheduledTimerWithTimeInterval(0.6, target: self, selector: Selector("animateVibration"), userInfo: nil, repeats: false)
        }
    }

    // MARK ESTBeaconManager delegate
    
    func beaconManager(manager: AnyObject!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        
        if beacons.count > 0 {
            self.startVibrate()
        } else {
            self.stopVibrate()
        }
    }
    
    @IBAction func showSettings() {
        /**
        *  Access settings to check how enable and disable motion UUID feature.
        */
        let settingsDemoVC: ESTMotionUUIDSettingsDemoVC = ESTMotionUUIDSettingsDemoVC().initWithBeacon(self.beacon!)!
        self.navigationController!.pushViewController(settingsDemoVC, animated:true)
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
