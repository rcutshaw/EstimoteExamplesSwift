//
//  ESTBulkUpdaterDemoVC.swift
//  ExamplesSwift
//
//  Ported to Swift by David Cutshaw on 6/29/15.
//  Copyright © 2015 Bit Smartz LLC. All rights reserved.
//

import UIKit

class ESTBulkUpdaterDemoVC: UIViewController {

    var beacon: ESTBluetoothBeacon?
    @IBOutlet weak var statusLabel: UILabel?
    
    func initWithBeacon(beacon: ESTBluetoothBeacon) -> ESTBulkUpdaterDemoVC? {
        
        if let _:ESTBulkUpdaterDemoVC = ESTBulkUpdaterDemoVC()
        {
            self.beacon = beacon
        }
        return self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Bulk Update Demo"
        
        NSBundle.mainBundle().loadNibNamed("ESTBulkUpdaterDemoVC", owner: self, options: nil)
        if ESTCloudManager.isAuthorized() {
            // Bulk update can be performed only when you are
            // authorized with App ID and App Token
            
            // define configuration that will update power to Level2
            // and advertising interval to 500 ms
            
            let sampleConfig: ESTBeaconUpdateConfig = ESTBeaconUpdateConfig()
            sampleConfig.power = NSNumber(char: -20) // ESTBeaconPowerLevel2 = -20
            sampleConfig.advInterval = NSNumber(int: 500)
            
            // create update info object based on config and localy keept beacon
            
            let info: ESTBeaconUpdateInfo = ESTBeaconUpdateInfo(macAddress: self.beacon!.macAddress, config: sampleConfig)
            
            // listen for events from Bulk updater
            
            NSNotificationCenter.defaultCenter().addObserver(self,
                selector: "bulkUpdateBegin:",
                name: ESTBulkUpdaterBeginNotification,
                object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self,
                selector: "bulkUpdateProgress:",
                name: ESTBulkUpdaterProgressNotification,
                object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self,
                selector: "bulkUpdateComplete:",
                name: ESTBulkUpdaterCompleteNotification,
                object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self,
                selector: "bulkUpdateTimeout:",
                name: ESTBulkUpdaterTimeoutNotification,
                object: nil)
            
            // start performing update of the beacon
            
            ESTBulkUpdater.sharedInstance().startWithBeaconInfos([info], timeout:60 * 60)
        }
        else
        {
            if #available(iOS 8.0, *) {
                let alert: UIAlertController = UIAlertController.init(title: "Update error",
                    message: "You have to be authorized to perform Bulk update.",
                    preferredStyle: .Alert)
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                let alert: UIAlertView? = UIAlertView(title:"Update error",
                    message: "You have to be authorized to perform Bulk update.",
                    delegate:nil,
                    cancelButtonTitle:"OK")
                alert!.show()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: ESBulkUpdater notifications handling
    
    func bulkUpdateBegin(note: NSNotification) {
        self.statusLabel!.text = "Bulk Updater did begin!"
    }
    
    func bulkUpdateProgress(note: NSNotification)
    {
        let progress: NSNumber = note.userInfo?["progress"] as! NSNumber
        self.statusLabel!.text = String(format: "Update progress ... %.0f%%", (100.0 * progress.floatValue))
    }

    func bulkUpdateComplete(note: NSNotification) {
        self.statusLabel!.text = "Bulk Updater complete!"
    }
    
    func bulkUpdateTimeout(note: NSNotification)
    {
        self.statusLabel!.text = "Bulk Updater timeout!"
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
