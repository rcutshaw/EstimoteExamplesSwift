//
//  ESTDistanceDemoVC.swift
//  ExamplesSwift
//
//  Ported to Swift by David Cutshaw on 6/20/15.
//  Copyright © 2015 Bit Smartz LLC. All rights reserved.
//

import UIKit

class ESTDistanceDemoVC: UIViewController, ESTBeaconManagerDelegate {
    
    let maxDistance: Float = 20
    let topMargin: Float = 150
    
    var beacon: CLBeacon?
    var beaconManager: ESTBeaconManager?
    var beaconRegion: CLBeaconRegion?
    var backgroundImage: UIImageView?
    var positionDot: UIImageView?
    
    func initWithBeacon(beacon: CLBeacon) -> ESTDistanceDemoVC? {
        
        if let _:ESTDistanceDemoVC = ESTDistanceDemoVC()
        {
            self.beacon = beacon;
        }
        return self;
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.title = "Distance Demo"
        
        /*
        * UI setup.
        */
        
        self.backgroundImage = UIImageView.init(image: UIImage(named: "distance_bkg"))
        self.backgroundImage!.frame = UIScreen.mainScreen().bounds
        self.backgroundImage!.contentMode = .ScaleToFill;
        self.view.addSubview(self.backgroundImage!)
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        let beaconImageView: UIImageView? = UIImageView.init(image: UIImage(named: "beacon"))
        beaconImageView!.center = CGPointMake(self.view.center.x, 100)
        self.view.addSubview(beaconImageView!)
        
        self.positionDot = UIImageView.init(image: UIImage(named: "black_dot"))
        self.positionDot!.center = self.view.center
        self.view.addSubview(self.positionDot!)
        
        
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
    
    // MARK ESTBeaconManager delegate
    
    func beaconManager(manager: AnyObject!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        
        if beacons.count > 0 {
            let firstBeacon: CLBeacon? = beacons.first as? CLBeacon
            self.updateDotPositionForDistance(Float(firstBeacon!.accuracy))
        }
    }
    
    // MARK Position update
    
    func updateDotPositionForDistance(distance: Float) {
        print("distance: %f", distance)
        
        let step: Float = (Float(self.view.frame.size.height) - topMargin) / maxDistance
        
        let newY: Float = topMargin + (distance * step)
        
        self.positionDot!.center = CGPointMake(self.positionDot!.center.x, CGFloat(newY))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK - Navigation
/*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
*/
}
