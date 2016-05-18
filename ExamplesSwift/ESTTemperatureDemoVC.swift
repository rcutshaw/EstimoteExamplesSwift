//
//  ESTTemperatureDemoVC.swift
//  ExamplesSwift
//
//  Ported to Swift by David Cutshaw on 6/24/15.
//  Copyright © 2015 Bit Smartz LLC. All rights reserved.
//

import UIKit

class ESTTemperatureDemoVC: UIViewController, ESTBeaconConnectionDelegate {

    @IBOutlet weak var activityLabel: UILabel?
    @IBOutlet weak var temperatureLabel: UILabel?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    var beaconConnection: ESTBeaconConnection?
    var readTemperatureWithInterval: NSTimer?
    
    func initWithBeacon(beacon: CLBeacon) -> ESTTemperatureDemoVC? {
        
        if let _:ESTTemperatureDemoVC = ESTTemperatureDemoVC()
        {
            self.beaconConnection = ESTBeaconConnection.init(beacon: beacon,
                delegate: self,
                startImmediately: false)
        }
        return self
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

         NSBundle.mainBundle().loadNibNamed("ESTTemperatureDemoVC", owner: self, options: nil)
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.title = "Temperature demo"
        self.activityIndicator!.startAnimating()
        
        //In order to read beacon temperature we need to connect to it.
        self.beaconConnection!.startConnection()
        
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if (self.beaconConnection!.connectionStatus == .Connected || self.beaconConnection!.connectionStatus == .Connecting)
        {
            if ((self.readTemperatureWithInterval) != nil)
            {
                self.readTemperatureWithInterval!.invalidate()
                self.readTemperatureWithInterval = nil
            }
            
            self.beaconConnection!.cancelConnection()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Beacon Operations
    
    func readBeaconTemperature() {
        
        //Reading temperature is asynchronous task, so we need to wait for completion block to be called.
        self.beaconConnection!.readTemperatureWithCompletion({ [weak self] (temp:NSNumber!, error:NSError?) -> () in
            if error == nil {
                self!.temperatureLabel!.text = NSString(format: "%.1f°C", temp.floatValue) as String
                self!.activityIndicator!.stopAnimating()
            } else {
                self!.activityLabel!.text = NSString(format: "Error:%@", error!.localizedDescription) as String
                self!.activityLabel!.textColor = UIColor.redColor()
            }   
        })
    }
    
    // MARK: ESTBeaconDelegate
    
    func beaconConnectionDidSucceed(connection: ESTBeaconConnection!) {
        self.activityIndicator!.stopAnimating()
        self.activityIndicator!.alpha = 0.0
        self.activityLabel!.text = "Connected!"
        
        //After successful connection, we can start reading temperature.
        self.readTemperatureWithInterval = NSTimer.scheduledTimerWithTimeInterval(2.0,
        target:self,
        selector:"readBeaconTemperature",
        userInfo:nil,
        repeats:true)
        
        self.readBeaconTemperature()
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
