//
//  ESTBeaconTableVC.swift
//  ExamplesSwift
//
//  Ported to Swift by David Cutshaw on 6/19/15.
//  Copyright © 2015 Bit Smartz LLC. All rights reserved.
//

import UIKit

class ESTTableViewCell: UITableViewCell {
        
}

class ESTBeaconTableVC: UITableViewController, ESTBeaconManagerDelegate, ESTUtilityManagerDelegate {

    enum ESTScanType: Int
    {
        case ESTScanTypeBluetooth
        case ESTScanTypeBeacon
    }
    var scanType: ESTScanType?
    
    var beaconManager: ESTBeaconManager?
    var utilityManager: ESTUtilityManager?
    var region: CLBeaconRegion?
    var beaconsArray: NSArray = []
    
    var completion: ((value: AnyObject?) -> Void)?

    func initWithScanType(scanType: ESTScanType, completion: ((AnyObject?) -> Void)) -> UIViewController
    {
        if let _:ESTBeaconTableVC = ESTBeaconTableVC()
        {
            self.scanType = scanType
            self.completion = completion
        }
        return self
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.title = "Select beacon"
        self.tableView.registerClass(ESTTableViewCell.self, forCellReuseIdentifier: "BeaconCellIdentifier")
        
        self.beaconManager = ESTBeaconManager()
        self.beaconManager!.delegate = self
        
        self.utilityManager = ESTUtilityManager()
        self.utilityManager!.delegate = self
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        /*
        * Creates sample region object (you can additionaly pass major / minor values).
        *
        * We specify it using only the ESTIMOTE_PROXIMITY_UUID because we want to discover all
        * hardware beacons with Estimote's proximty UUID.
        */
        self.region = CLBeaconRegion.init(proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!,
             identifier: "EstimoteSampleRegion")
        
        /*
        * Starts looking for Estimote beacons.
        * All callbacks will be delivered to beaconManager delegate.
        */
        if (self.scanType == .ESTScanTypeBeacon) {
            self.startRangingBeacons()
        } else {
            self.utilityManager!.startEstimoteBeaconDiscovery()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        /*
        *Stops ranging after exiting the view.
        */
        self.beaconManager!.stopRangingBeaconsInRegion(self.region)
        self.utilityManager!.stopEstimoteBeaconDiscovery()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // This code was in the original Examples Objective-C code, but never got used.
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion:nil)
    }

    // MARK: Range beacons
    
    func startRangingBeacons() {
        
        if ESTBeaconManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
            self.beaconManager!.requestAlwaysAuthorization()
            self.beaconManager!.startRangingBeaconsInRegion(self.region)
        } else if ESTBeaconManager.authorizationStatus() == CLAuthorizationStatus.Authorized {
            self.beaconManager!.startRangingBeaconsInRegion(self.region)
        } else if ESTBeaconManager.authorizationStatus() == CLAuthorizationStatus.Denied  {
            if #available(iOS 8.0, *) {
                let alert: UIAlertController = UIAlertController.init(title: "Location Access Denied",
                    message: "You have denied access to location services. Change this in app settings.",
                    preferredStyle: .Alert)
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                let alert: UIAlertView? = UIAlertView(title:"Location Access Denied",
                    message: "You have denied access to location services. Change this in app settings.",
                    delegate:nil,
                    cancelButtonTitle:"OK")
                alert!.show()
            }
        } else if ESTBeaconManager.authorizationStatus() == CLAuthorizationStatus.Restricted {
            if #available(iOS 8.0, *) {
                let alert: UIAlertController = UIAlertController.init(title: "Location Not Available",
                    message: "You have no access to location services.",
                    preferredStyle: .Alert)
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                let alert: UIAlertView? = UIAlertView(title:"Location Not Available",
                    message: "You have no access to location services.",
                    delegate:nil,
                    cancelButtonTitle:"OK")
                alert!.show()
            }
        }
    }

    // MARK: ESTBeaconManager delegate
    
    func beaconManager(manager: AnyObject!, rangingBeaconsDidFailForRegion region: CLBeaconRegion!, withError error: NSError!) {
        if #available(iOS 8.0, *) {
            let alert: UIAlertController = UIAlertController.init(title: "Ranging error",
                message: error.localizedDescription,
                preferredStyle: .Alert)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let errorView: UIAlertView = UIAlertView.init(title: "Ranging error",
                message:error.localizedDescription,
                delegate:nil,
                cancelButtonTitle:"OK")
            errorView.show()
        }
    }
    
    func beaconManager(manager: AnyObject!, monitoringDidFailForRegion region: CLBeaconRegion!, withError error: NSError!) {
        
        if #available(iOS 8.0, *) {
            let alert: UIAlertController = UIAlertController.init(title: "Monitoring error",
                message: error.localizedDescription,
                preferredStyle: .Alert)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let errorView: UIAlertView = UIAlertView.init(title: "Monitoring error",
                message:error.localizedDescription,
                delegate:nil,
                cancelButtonTitle:"OK")
            errorView.show()
        }
    }
    
    func beaconManager(manager: AnyObject!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        self.beaconsArray = beacons
        
        self.tableView.reloadData()
    }
    
    func utilityManager(manager: ESTUtilityManager!, didDiscoverBeacons beacons: [AnyObject]!) {
        self.beaconsArray = beacons
        
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.beaconsArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BeaconCellIdentifier", forIndexPath: indexPath)

        /*
        * Fill the table with beacon data.
        */
        
        let beacon: AnyObject? = self.beaconsArray.objectAtIndex(indexPath.row)
        
        if beacon!.isKindOfClass(CLBeacon.self) {
            
            let cBeacon: CLBeacon = beacon as! CLBeacon
            cell.textLabel?.text = String(format: "Major: %@, Minor: %@", cBeacon.major, cBeacon.minor)
            cell.detailTextLabel?.text = String(format: "Distance: %.2f", cBeacon.accuracy)
        } else if beacon!.isKindOfClass(ESTBluetoothBeacon.self) {
            
            let cBeacon: ESTBluetoothBeacon = beacon as! ESTBluetoothBeacon
            
            cell.textLabel?.text = String(format: "Mac Address: %@", cBeacon.macAddress)
            cell.detailTextLabel?.text = String(format: "RSSI: %zd", cBeacon.rssi)
        }
        
        if beacon?.isSecured == true {
            cell.imageView?.image = UIImage(named: "beacon_secure")
        } else {
            cell.imageView?.image = UIImage(named: "beacon")
        }
        
        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedBeacon: AnyObject?
        if self.beaconsArray.objectAtIndex(indexPath.row).isKindOfClass(CLBeacon.self) {
            selectedBeacon = self.beaconsArray.objectAtIndex(indexPath.row) as! CLBeacon
            self.completion!(value: selectedBeacon)
        } else if self.beaconsArray.objectAtIndex(indexPath.row).isKindOfClass(ESTBluetoothBeacon.self) {
            selectedBeacon = self.beaconsArray.objectAtIndex(indexPath.row) as! ESTBluetoothBeacon
            self.completion!(value: selectedBeacon)
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
