//
//  ESTViewController.swift
//  ExamplesSwift
//
//  Ported to Swift by David Cutshaw on 6/14/15.
//  Copyright © 2015 Bit Smartz LLC. All rights reserved.
//

import UIKit

class ESTDemoTableViewCell: UITableViewCell {
    
}

class ESTViewController: UITableViewController {

    // MARK: Lifecycle
    
    var beaconDemoList: NSArray = []
    var doppelgangerImageHasNotBeenDisplayed: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        self.title = "Estimote Demos"
        
        self.tableView.sectionHeaderHeight = 20
        self.tableView.registerClass(ESTDemoTableViewCell.self, forCellReuseIdentifier: "DemoCellIdentifier")
        
        self.beaconDemoList = [ ["Virtual Beacon", "Distance", "Proximity Zones","Notifications"],
        ["Temperature", "Accelerometer", "Motion UUID"],
        ["Beacon Settings", "Update Firmware", "Local Bulk Update", "Remote Bulk Update"],
        ["Fetch beacons from cloud", "Send Beacons GPS Position"]
        ]
        
        // Curl up from the launch image's doppelganger view to the ESTViewController view - the code to
        // do this is continued in viewDidAppear() below.
        let screenHeight: CGFloat = UIScreen.mainScreen().bounds.size.height
        let imageFile: NSString = (screenHeight == 568.0) ? "doppelgangerImage.png" : "doppelgangerImage.png"
        let doppelgangerView: UIImageView = UIImageView(image: UIImage(named: imageFile as String))
        doppelgangerView.tag = 1234
        let rootVC = (UIApplication.sharedApplication().delegate!.window!)!.rootViewController!
        rootVC.view.addSubview(doppelgangerView)
/*
        // Here is a second way to fade from Launch image through the doppelganger view to the ESTViewController.
        // If you choose to use this fade version instead of the curl transition version currently implemented, you
        // need to uncomment this animateWithDuration code and remove all the code in viewDidAppear() below.
        UIView.animateWithDuration(2.0, delay: 0.0, options: .TransitionCurlUp, animations: { () -> Void in
            doppelgangerView.alpha = 0.0
            doppelgangerView.frame = CGRectMake(160.0, 284.0, 0.0, 0.0)
        }) { (finished) -> Void in
            doppelgangerView.removeFromSuperview()
        }
*/
    }

    override func viewDidAppear(animated: Bool) {

        // This removes the doppelganger view created in viewDidLoad() as part of a page curl off the screen.
        if doppelgangerImageHasNotBeenDisplayed {
            // Delay so that the LaunchImage will remain on screen a little longer before being animated off
            NSThread.sleepForTimeInterval(0.75)
            let rootVC = (UIApplication.sharedApplication().delegate!.window!)!.rootViewController!
            UIView.transitionWithView(rootVC.view, duration: 0.75, options: .TransitionCurlUp, animations: { () -> Void in
                    rootVC.view.viewWithTag(1234)?.removeFromSuperview()
                }) { (finished) -> Void in
            }
            doppelgangerImageHasNotBeenDisplayed = false
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK:  Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.beaconDemoList.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.beaconDemoList.objectAtIndex(section).count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0) {
            return "iBeacon demos"
        }
        if(section == 1) {
            return "Sensor demos"
        }
        if(section == 2) {
            return "Utilities demos"
        }
        if(section == 3) {
            return "Estimote Cloud demos"
        }
        
        return nil;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DemoCellIdentifier", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = self.beaconDemoList.objectAtIndex(indexPath.section).objectAtIndex(indexPath.row) as? String
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    // MARK: Table view delegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var demoViewController:UIViewController?
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                demoViewController = ESTVirtualBeaconDemoVC.init(nibName: "ESTVirtualBeaconDemoVC", bundle:nil)
                
            case 1:
                demoViewController = ESTBeaconTableVC().initWithScanType(ESTBeaconTableVC.ESTScanType.ESTScanTypeBeacon,
                    completion:{ beacon in
                    
                    let distanceDemoVC = ESTDistanceDemoVC().initWithBeacon(beacon as! CLBeacon)
                    self.navigationController!.pushViewController(distanceDemoVC!, animated:true)
                    })
            case 2:
                demoViewController = ESTBeaconTableVC().initWithScanType(ESTBeaconTableVC.ESTScanType.ESTScanTypeBeacon,
                    completion:{ beacon in
                        
                        let proximityDemoVC = ESTProximityDemoVC().initWithBeacon(beacon as! CLBeacon)
                        self.navigationController!.pushViewController(proximityDemoVC!, animated:true)
                    })
            case 3:
                demoViewController = ESTBeaconTableVC().initWithScanType(ESTBeaconTableVC.ESTScanType.ESTScanTypeBeacon,
                    completion:{ beacon in
                        
                        let notificationDemoVC = ESTNotificationDemoVC()                        
                        notificationDemoVC.beacon = beacon as? CLBeacon
                        self.navigationController!.pushViewController(notificationDemoVC, animated:true)
                    })
            default:
                break
            }

        } else if (indexPath.section == 1) {
            switch indexPath.row {
            case 0:
                demoViewController =
                    ESTBeaconTableVC().initWithScanType(ESTBeaconTableVC.ESTScanType.ESTScanTypeBeacon,
                    completion:{ beacon in
                        
                        let temperatureDemoVC = ESTTemperatureDemoVC().initWithBeacon(beacon as! CLBeacon)
                        self.navigationController!.pushViewController(temperatureDemoVC!, animated:true)
                })
            case 1:
                demoViewController =
                    ESTBeaconTableVC().initWithScanType(ESTBeaconTableVC.ESTScanType.ESTScanTypeBeacon,
                    completion:{ beacon in
                        
                        let motionDetectionDemoVC = ESTMotionDetectionDemoVC().initWithBeacon(beacon as! CLBeacon)
                        self.navigationController!.pushViewController(motionDetectionDemoVC!, animated:true)
                })
            case 2:
                demoViewController =
                    ESTBeaconTableVC().initWithScanType(ESTBeaconTableVC.ESTScanType.ESTScanTypeBeacon,
                    completion:{ beacon in
                        
                        let motionUUIDDemoVC = ESTMotionUUIDDemoVC().initWithBeacon(beacon as! CLBeacon)
                        self.navigationController!.pushViewController(motionUUIDDemoVC!, animated:true)
                })
            default:
                break
            }
        } else if (indexPath.section == 2) {
            switch (indexPath.row) {
            case 0:
                demoViewController =
                    ESTBeaconTableVC().initWithScanType(ESTBeaconTableVC.ESTScanType.ESTScanTypeBluetooth,
                        completion:{ beacon in
                        
                        let beaconDetailsVC = ESTBeaconDetailsDemoVC().initWithMacAddress(beacon!.macAddress)
                        self.navigationController!.pushViewController(beaconDetailsVC!, animated:true)
                })
            case 1:
                demoViewController =
                    ESTBeaconTableVC().initWithScanType(ESTBeaconTableVC.ESTScanType.ESTScanTypeBluetooth,
                        completion:{ beacon in
                        
                        let updateFirmwareVC = ESTUpdateFirmwareDemoVC().initWithMacAddress(beacon!.macAddress)
                        self.navigationController!.pushViewController(updateFirmwareVC!, animated:true)
                })
            case 2:
                demoViewController =
                    ESTBeaconTableVC().initWithScanType(ESTBeaconTableVC.ESTScanType.ESTScanTypeBluetooth,
                    completion:{ beacon in
                        
                        let bulkDemoVC = ESTBulkUpdaterDemoVC().initWithBeacon(beacon as! ESTBluetoothBeacon)
                        self.navigationController!.pushViewController(bulkDemoVC!, animated:true)
                })
            case 3:
                demoViewController = ESTBulkUpdaterRemoteDemoVC.init()

            default:
                break
            }
        } else if (indexPath.section == 3) {
            switch (indexPath.row) {
            case 0:
                demoViewController = ESTCloudBeaconTableVC.init()
            case 1:
                demoViewController =
                    ESTBeaconTableVC().initWithScanType(ESTBeaconTableVC.ESTScanType.ESTScanTypeBeacon,
                    completion:{ beacon in
                        
                        let demoVC: ESTSendGPSDemoVC = ESTSendGPSDemoVC().initWithBeacon(beacon as! CLBeacon)!
                        self.navigationController!.pushViewController(demoVC, animated:true)
                })
            default:
                break
            }
        }
        if (demoViewController != nil) {
            self.navigationController?.pushViewController(demoViewController!, animated: true)
        }
    }
    
}

