//
//  ESTMotionDetectionDemoVC.swift
//  ExamplesSwift
//
//  Ported to Swift by David Cutshaw on 6/25/15.
//  Copyright © 2015 Bit Smartz LLC. All rights reserved.
//

import UIKit
import AudioToolbox

class ESTMotionDetectionDemoVC: UIViewController, ESTBeaconConnectionDelegate {

    var beaconConnection: ESTBeaconConnection?
    @IBOutlet weak var counterTextLabel: UILabel?
    @IBOutlet weak var counterLabel: UILabel?
    @IBOutlet weak var beaconImage: UIImageView?
    @IBOutlet weak var activityLabel: UILabel?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    
    func initWithBeacon(beacon: CLBeacon) -> ESTMotionDetectionDemoVC? {
        
        if let _:ESTMotionDetectionDemoVC = ESTMotionDetectionDemoVC()
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
        
        NSBundle.mainBundle().loadNibNamed("ESTMotionDetectionDemoVC", owner: self, options: nil)
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.title = "Motion Detection Demo"
        
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
    
    // MARK: Other Methods
    
    func readMotionDetectionCount() {
        self.beaconConnection!.readAccelerometerCountWithCompletion({ [weak self] (value:NSNumber!, error:NSError?) -> () in
            if error == nil {
                self!.counterLabel!.text = NSString(format: "Beacon moves count: %tu", value.intValue) as String
            } else {
                self!.counterLabel!.text = NSString(format: "Error:%@", error!.localizedDescription) as String
                self!.counterLabel!.textColor = UIColor.redColor()
            }
        })
    }
    
    func vibrateEffect() {
        if self.beaconConnection!.motionState == ESTBeaconMotionState.Moving
        {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            
            let animation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.duration = 0.6
            animation.values = [ -20, 20, -20, 20, -10, 10, -5, 5, 0 ]
            self.beaconImage!.layer.addAnimation(animation, forKey: "shake")
            
            _ = NSTimer.scheduledTimerWithTimeInterval(0.6, target: self, selector: Selector("vibrateEffect"), userInfo: nil, repeats: false)
        }
    }
    
   // MARK: ESTBeaconDelegate
    
    func beaconConnectionDidSucceed(connection: ESTBeaconConnection!) {
        self.activityIndicator!.stopAnimating()
        self.activityIndicator!.alpha = 0.0
        self.activityLabel!.text = "Connected!"
        
        //After successful connection, we can read or reset accelerometer data.
        self.beaconConnection!.resetAccelerometerCountWithCompletion({ [weak self] (value:UInt16, error:NSError?) -> () in
            if error == nil {
                self!.counterLabel!.text = NSString(format: "Beacon moves count: %tu", value) as String
            } else {
                self!.counterLabel!.text = NSString(format: "Error:%@", error!.localizedDescription) as String
                self!.counterLabel!.textColor = UIColor.redColor()
            }
        })
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
    
    func beaconConnection(connection: ESTBeaconConnection!, motionStateChanged state: ESTBeaconMotionState) {
        //State is updated after beacon accelerometer was stabilised.
        if state == ESTBeaconMotionState.Moving
        {
            self.vibrateEffect()
        }
        else
        {
            self.readMotionDetectionCount()
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
