//
//  ESTProximityDemoVC.swift
//  ExamplesSwift
//
//  Ported to Swift by David Cutshaw on 6/22/15.
//  Copyright © 2015 Bit Smartz LLC. All rights reserved.
//

import UIKit

class ESTProximityDemoVC: UIViewController, ESTBeaconManagerDelegate {

    var beacon: CLBeacon?
    var beaconManager: ESTBeaconManager?
    var beaconRegion: CLBeaconRegion?
    var imageView: UIImageView?
    var zoneLabel: UILabel?
    
    func initWithBeacon(beacon: CLBeacon) -> ESTProximityDemoVC? {
        
        if let _:ESTProximityDemoVC = ESTProximityDemoVC()
        {
            self.beacon = beacon
        }
        return self
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Proximity Demo"
        
        /*
        * UI setup.
        */
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.zoneLabel = UILabel.init(frame: CGRectMake(0,
                                             100,
                                             self.view.frame.size.width,
                                             40))
        self.zoneLabel!.textAlignment = .Center;
        self.view.addSubview(self.zoneLabel!)
        
        self.imageView = UIImageView.init(frame: CGRectMake(0,
            64,
            self.view.frame.size.width,
            self.view.frame.size.height - 64))
        self.imageView!.contentMode = .Center;
        self.view.addSubview(self.imageView!)
        
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
        
        self.beaconManager!.startRangingBeaconsInRegion(self.beaconRegion)
    }

    override func viewDidDisappear(animated: Bool) {
        self.beaconManager!.stopRangingBeaconsInRegion(self.beaconRegion)
        
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK ESTBeaconManager delegate
    
    func beaconManager(manager: AnyObject!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        if (beacons.count > 0)
        {
            let firstBeacon: CLBeacon? = beacons.first as? CLBeacon
            self.zoneLabel!.text = self.textForProximity(firstBeacon!.proximity) as String
            self.imageView!.image = self.imageForProximity(firstBeacon!.proximity)
        }
    }

    // MARK: Proximity testing
    
    func textForProximity(proximity: CLProximity) -> NSString {
        switch (proximity) {
        case .Far:
            return "Far"
        case .Near:
            return "Near"
        case .Immediate:
            return "Immediate"
        case .Unknown:
            return "Unknown"
        }
    }
    
    func imageForProximity(proximity: CLProximity) -> UIImage? {
        switch (proximity) {
        case .Far:
            return UIImage(named: "far_image")
        case .Near:
            return UIImage(named: "near_image")
        case .Immediate:
            return UIImage(named: "immediate_image")
        case .Unknown:
            return UIImage(named: "unknown_image")
        }
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
