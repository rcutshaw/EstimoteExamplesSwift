//
//  ESTBulkUpdaterRemoteDemoVC.swift
//  ExamplesSwift
//
//  Ported to Swift by David Cutshaw on 6/29/15.
//  Copyright © 2015 Bit Smartz LLC. All rights reserved.
//

import UIKit

class ESTBulkUpdaterRemoteDemoVC: UIViewController {

    var cloudManager: ESTCloudManager?
    @IBOutlet weak var statusLabel: UILabel?
    @IBOutlet weak var cloudLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Remote Bulk Update Demo"
        
        NSBundle.mainBundle().loadNibNamed("ESTBulkUpdaterRemoteDemoVC", owner: self, options: nil)
        if ESTCloudManager.isAuthorized() {
            // Bulk update can be performed only when you are
            // authorized with App ID and App Token
            
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
            
            // Create ESTCloudManager object to fetch pending settings
            // from Estimote Cloud
            self.cloudManager = ESTCloudManager()
            
            // Perform pending settings fetch from Estimote Cloud
            self.cloudManager?.fetchPendingBeaconsSettingsWithCompletion({ [weak self] (value, error) -> Void
                in
                self!.cloudLabel!.text = String(format: "%tu beacons updated\nin Estimote Cloud", value.count)
                // start performing beacons update based on information fetched
                // from Estimote Cloud
                ESTBulkUpdater.sharedInstance().startWithBeaconInfos(value, timeout: (60 * 60))
            })
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
