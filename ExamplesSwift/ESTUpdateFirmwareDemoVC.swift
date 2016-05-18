//
//  ESTUpdateFirmwareDemoVC.swift
//  ExamplesSwift
//
//  Ported to Swift by David Cutshaw on 6/27/15.
//  Copyright © 2015 Bit Smartz LLC. All rights reserved.
//

import UIKit

class ESTUpdateFirmwareDemoVC: UIViewController, ESTBeaconConnectionDelegate {

    var beaconConnection: ESTBeaconConnection?
    @IBOutlet weak var updateStateLabel: UILabel?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var updateProgressLabel: UILabel?
    
    func initWithMacAddress(macAddress: NSString) -> ESTUpdateFirmwareDemoVC? {
        
        if let _:ESTUpdateFirmwareDemoVC = ESTUpdateFirmwareDemoVC()
        {
            self.beaconConnection = ESTBeaconConnection(macAddress: macAddress as String,
                delegate: self,
                startImmediately: false)
        }
        return self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSBundle.mainBundle().loadNibNamed("ESTUpdateFirmwareDemoVC", owner: self, options: nil)
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.title = "Update Firmware Demo"
        
        //In order to read beacon accelerometer we need to connect to it.
        self.beaconConnection!.startConnection()
        self.activityIndicator!.startAnimating()
        
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.beaconConnection!.cancelConnection()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Update Firmware Model
    
    func beaconConnectionDidSucceed(connection: ESTBeaconConnection!) {
        self.navigationItem.hidesBackButton = true
        
        self.beaconConnection?.updateFirmwareWithProgress({ [weak self] (value: Int, description: String!, error: NSError!) -> Void in
            self!.updateStateLabel!.text = description
            self!.updateProgressLabel!.text = String(format: "%ld %%", value)

            }, completion: { [weak self] (error: NSError!) -> Void in
                self!.navigationItem.hidesBackButton = false
                
                if (error == nil)
                {
                    self!.updateStateLabel!.text = ""
                    self!.updateProgressLabel!.text = "Updated!"
                    self!.updateProgressLabel!.font = UIFont.boldSystemFontOfSize(50)
                }
                else
                {
                    print("Update failed.")
                    self!.updateStateLabel!.text = error.localizedDescription
                    self!.updateProgressLabel!.text = "Failed!"
                    self!.updateProgressLabel!.font = UIFont.boldSystemFontOfSize(50)
                }
                self!.activityIndicator!.stopAnimating()
        })
    }
    
    func beaconConnection(connection: ESTBeaconConnection!, didFailWithError error: NSError!) {
        //Beacon connection did fail. Try again.
        
        print("Somethingwent wrong. Beacon connection Did Fail. Error: %@", error)
        
        self.activityIndicator!.stopAnimating()
        self.activityIndicator!.alpha = 0.0
        
        self.updateStateLabel!.text = "Connection failed"
        self.updateStateLabel!.textColor = UIColor.redColor()
        
        if #available(iOS 8.0, *) {
            let alert: UIAlertController = UIAlertController.init(title: "Connection error",
                message: error.localizedDescription,
                preferredStyle: .Alert)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let errorView: UIAlertView = UIAlertView.init(title: "Connection error",
                message:error.localizedDescription,
                delegate:nil,
                cancelButtonTitle:"OK")
            errorView.show()
        }
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
