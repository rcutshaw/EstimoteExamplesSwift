//
//  ESTBeaconDetailsDemoVC.swift
//  ExamplesSwift
//
//  Ported to Swift by David Cutshaw on 6/26/15.
//  Copyright © 2015 Bit Smartz LLC. All rights reserved.
//

import UIKit

class ESTBeaconDetailsDemoVC: UIViewController, UITextFieldDelegate, ESTBeaconConnectionDelegate {

    var beaconConnection: ESTBeaconConnection?
    @IBOutlet weak var mainScrollView: UIScrollView?
    @IBOutlet weak var mainView: UIView?
    @IBOutlet weak var UUIDTextField: UITextField?
    @IBOutlet weak var motionUUIDTextField: UITextField?
    @IBOutlet weak var majorTextField: UITextField?
    @IBOutlet weak var minorTextField: UITextField?
    @IBOutlet weak var advertisingTextField: UITextField?
//    @IBOutlet weak var powerTextField: UITextField?  // I removed this field and replaced with powerLabel and powerStepper
//    in order to provide a clearer implementation of selecting discrete power levels.
    @IBOutlet weak var basicPowerModeSwitch: UISwitch?
    @IBOutlet weak var smartPowerModeSwitch: UISwitch?
    @IBOutlet weak var secureUUIDSwitch: UISwitch?
    @IBOutlet weak var conditionalBroadcastingSegment: UISegmentedControl?
    @IBOutlet weak var mac: UITextView?
    @IBOutlet weak var batteryLevel: UILabel?
    @IBOutlet weak var softwareVersion: UILabel?
    @IBOutlet weak var hardwareVersion: UILabel?
    @IBOutlet weak var activityLabel: UILabel?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var resetButton: UIButton?
    @IBOutlet weak var powerLabel: UILabel?
    @IBOutlet weak var powerStepper: UIStepper?
    
    var currentValue: Int = 0
    
    func initWithMacAddress(macAddress: NSString) -> ESTBeaconDetailsDemoVC? {
        
        if let _:ESTBeaconDetailsDemoVC = ESTBeaconDetailsDemoVC()
        {
            self.beaconConnection = ESTBeaconConnection(macAddress: macAddress as String,
                delegate: self,
                startImmediately: false)
        }
        return self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSBundle.mainBundle().loadNibNamed("ESTBeaconDetailsDemoVC", owner: self, options: nil)
        self.title = "Beacon Details"
        
        self.enableView(false)
        
        self.resetButton!.layer.cornerRadius = 5.0
        self.resetButton!.layer.masksToBounds = true
        
        self.mainScrollView!.frame = CGRectMake(
            0,
            0,
            UIScreen.mainScreen().bounds.size.width,
            UIScreen.mainScreen().bounds.size.height)
        
        self.mainScrollView!.contentSize = CGSizeMake(320, 800)
        self.mainScrollView!.contentOffset = CGPointMake(0, 10)
        
        // In order to read beacon accelerometer we need to connect to it.
        self.activityIndicator!.startAnimating()
        
        self.beaconConnection!.startConnection()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        /*
        * Disconnect beacon when leaving screen
        */
        if self.beaconConnection!.connectionStatus == ESTConnectionStatus.Connected || self.beaconConnection!.connectionStatus == ESTConnectionStatus.Connecting {
            self.beaconConnection!.cancelConnection()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: ESTBeacon connection handling
    
    func beaconConnectionDidSucceed(connection: ESTBeaconConnection!) {
        self.activityIndicator!.stopAnimating()
        self.activityIndicator!.alpha = 0.0
        self.activityLabel!.text = "Connected!"
        
        self.enableView(true)
        self.updateDataLabels()
    }

    func beaconConnection(connection: ESTBeaconConnection!, didFailWithError error: NSError!) {
        print("Something went wrong. Beacon connection Did Fail. Error: %@", error)
        
        self.activityIndicator!.stopAnimating()
        self.activityIndicator!.alpha = 0.0
        
        self.activityLabel!.text = "Connection failed"
        self.activityLabel!.textColor = UIColor.redColor()
    }
    
    func beaconConnection(connection: ESTBeaconConnection!, didDisconnectWithError error: NSError!) {
        self.updateDataLabels()
    }
    
    // MARK: UITextField delgate
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == self.majorTextField! {
            let newMajor: UInt16 = UInt16(self.majorTextField!.text!)!
            self.beaconConnection?.writeMajor(newMajor, completion: { (major: UInt16, error: NSError?) -> Void in
                if (error != nil) {
                    print("Error major write: %@", error!.localizedDescription)
                }
                self.majorTextField!.text = String(format: "%i", major)
            })
        } else if textField == self.minorTextField! {
            let newMinor: UInt16 = UInt16(self.minorTextField!.text!)!
            self.beaconConnection?.writeMinor(newMinor, completion: { (minor: UInt16, error: NSError?) -> Void in
                if (error != nil) {
                    print("Error minor write: %@", error!.localizedDescription)
                }
                self.minorTextField!.text = String(format: "%i", minor)
            })
        } else if textField == self.UUIDTextField! {
            self.beaconConnection?.writeProximityUUID(textField.text, completion: { (value, error) -> Void in
                if (error != nil) {
                    print("Error UUID write: %@", error!.localizedDescription)
                }
                self.UUIDTextField!.text = String(format: "%@", value)
            })
        } else if textField == self.advertisingTextField! {
            self.beaconConnection?.writeAdvInterval(UInt16(textField.text!)!, completion: { (value: UInt16, error) -> Void in
                if (error != nil) {
                    print("Error advertising write: %@", error!.localizedDescription)
                }
                self.advertisingTextField!.text = String(format: "%i", value)
            })
        }/* else if textField == self.powerTextField! {  // I removed this - (see stepperValueChanged() below)
            var requestedPower: ESTBeaconPower?
            if Int(textField.text!)! > 4 {
                requestedPower = ESTBeaconPower(rawValue: 4)
            } else if Int(textField.text!)! >= 2 && Int(textField.text!)! <= 4 {
                requestedPower = ESTBeaconPower(rawValue: 4)
            } else if Int(textField.text!)! >= -2 && Int(textField.text!)! < 2 {
                requestedPower = ESTBeaconPower(rawValue: 0)
            } else if Int(textField.text!)! >= -4 && Int(textField.text!)! < -2 {
                requestedPower = ESTBeaconPower(rawValue: -4)
            } else if Int(textField.text!)! >= -10 && Int(textField.text!)! < -6 {
                requestedPower = ESTBeaconPower(rawValue: -8)
            } else if Int(textField.text!)! >= -12 && Int(textField.text!)! < -10 {
                requestedPower = ESTBeaconPower(rawValue: -12)
            } else if Int(textField.text!)! >= -18 && Int(textField.text!)! < -14 {
                requestedPower = ESTBeaconPower(rawValue: -16)
            } else if Int(textField.text!)! >= -22 && Int(textField.text!)! < -18 {
                requestedPower = ESTBeaconPower(rawValue: -20)
            } else if Int(textField.text!)! >= -30 && Int(textField.text!)! < -25 {
                requestedPower = ESTBeaconPower(rawValue: -30)
            } else if Int(textField.text!)! < -30 {
                requestedPower = ESTBeaconPower(rawValue: -30)
            }
//            let somePower: ESTBeaconPower? = ESTBeaconPower(rawValue: -12)
            print("requestedPower = \(requestedPower)")

            
            self.beaconConnection!.writePower(requestedPower!, completion: { (requestedPower, error: NSError!) -> Void in
                if (error != nil) {
                    print("Error Power write: %@", error!.localizedDescription)
                }
                self.powerTextField!.text = String(format: "%i", (requestedPower.rawValue))
            })
        }*/
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func enableView(enable: Bool) {
        self.mainView!.userInteractionEnabled = enable
        self.mainView!.alpha = enable ? 1.0 : 0.5
    }
    
    func updateDataLabels() {
        self.resetButton!.enabled = true
        self.resetButton!.alpha = 1.0
        
        if self.beaconConnection!.proximityUUID != nil {
            self.UUIDTextField!.text = String(format: "%@", self.beaconConnection!.proximityUUID.UUIDString)
            self.UUIDTextField!.enabled = true
        } else {
            self.UUIDTextField!.text = "--"
            self.UUIDTextField!.enabled = false
        }
        
        if self.beaconConnection!.motionProximityUUID != nil {
            self.motionUUIDTextField!.text = String(format: "%@", self.beaconConnection!.motionProximityUUID.UUIDString)
        } else {
            self.motionUUIDTextField!.text = "--"
        }

        if self.beaconConnection!.major != nil {
            self.majorTextField!.text = String(format: "%i", self.beaconConnection!.major.unsignedShortValue as UInt16)
            self.majorTextField!.enabled = true
        } else {
            self.majorTextField!.text = "--"
            self.majorTextField!.enabled = false
        }
        
        if self.beaconConnection!.minor != nil {
            self.minorTextField!.text = String(format: "%i", self.beaconConnection!.minor.unsignedShortValue as UInt16)
            self.minorTextField!.enabled = true
        } else {
            self.minorTextField!.text = "--"
            self.minorTextField!.enabled = false
        }
        
        if self.beaconConnection!.advInterval != nil {
            self.advertisingTextField!.text = String(format: "%d", self.beaconConnection!.advInterval.unsignedShortValue as UInt16)
        } else {
            self.advertisingTextField!.text = "--"
        }

        if self.beaconConnection!.power != nil {  // I am not using these any more - changed to use of stepper and label
//            self.powerTextField!.text = String(format: "%i", self.beaconConnection!.power.shortValue as Int16)
//            self.powerTextField!.enabled = true
            self.powerLabel!.text = String(format: "%i", self.beaconConnection!.power.shortValue as Int16)
        } else {
//            self.powerTextField!.text = "--"
        }

        if self.beaconConnection!.batteryLevel != nil {
            self.batteryLevel!.text = String(format: "%i", self.beaconConnection!.advInterval!.unsignedCharValue as UInt8)
        } else {
            self.batteryLevel!.text = "--"
        }
        
        if self.beaconConnection!.firmwareVersion != nil {
            self.softwareVersion!.text = self.beaconConnection!.firmwareVersion
        } else {
            self.softwareVersion!.text = "--"
        }
        
        if self.beaconConnection!.hardwareVersion != nil {
            self.hardwareVersion!.text = self.beaconConnection!.hardwareVersion
        } else {
            self.hardwareVersion!.text = "--"
        }
        
        if self.beaconConnection!.macAddress != nil {
            self.mac!.text = String(format: "%@", self.beaconConnection!.macAddress!)
        } else {
            self.mac!.text = "--"
        }
        
        if self.beaconConnection!.basicPowerMode == ESTBeaconPowerSavingMode.On {
            self.basicPowerModeSwitch!.enabled = true
            self.basicPowerModeSwitch!.on = true
        } else if self.beaconConnection!.basicPowerMode == ESTBeaconPowerSavingMode.Off {
            self.basicPowerModeSwitch!.enabled = true
            self.basicPowerModeSwitch!.on = false
        }
        
        if self.beaconConnection!.smartPowerMode == ESTBeaconPowerSavingMode.On {
            self.smartPowerModeSwitch!.enabled = true
            self.smartPowerModeSwitch!.on = true
        } else if self.beaconConnection!.smartPowerMode == ESTBeaconPowerSavingMode.Off {
            self.smartPowerModeSwitch!.enabled = true
            self.smartPowerModeSwitch!.on = false
        }
        
        if self.beaconConnection!.estimoteSecureUUIDState == ESTBeaconEstimoteSecureUUID.On {
            self.secureUUIDSwitch!.enabled = true
            self.secureUUIDSwitch!.on = true
        } else if self.beaconConnection!.estimoteSecureUUIDState == ESTBeaconEstimoteSecureUUID.Off {
            self.secureUUIDSwitch!.enabled = true
            self.secureUUIDSwitch!.on = false
        }
        
        self.conditionalBroadcastingSegment!.enabled = true
        switch self.beaconConnection!.conditionalBroadcastingState {
        case ESTBeaconConditionalBroadcasting.Off:
            self.conditionalBroadcastingSegment!.selectedSegmentIndex = 0
        case ESTBeaconConditionalBroadcasting.MotionOnly:
            self.conditionalBroadcastingSegment!.selectedSegmentIndex = 1
        case ESTBeaconConditionalBroadcasting.FlipToStop:
            self.conditionalBroadcastingSegment!.selectedSegmentIndex = 2
        default:
            self.conditionalBroadcastingSegment!.selectedSegmentIndex = UISegmentedControlNoSegment
            self.conditionalBroadcastingSegment!.enabled = false
            break
        }
        
    }
    
    // MARK: UI item handling
    
    @IBAction func resetBtnTapped() {
        // Using [weak self] to eliminate retain cycle
        self.beaconConnection!.resetToFactorySettingsWithCompletion({ [weak self] (error:NSError?) -> () in
            
            var message = "Beacon was successfuly reset."
            
            if (error != nil)
            {
                message = error!.localizedDescription
            }
            
            if #available(iOS 8.0, *) {
                let alert: UIAlertController = UIAlertController.init(title: "Reset Finished!",
                    message: error!.localizedDescription,
                    preferredStyle: .Alert)
                self!.presentViewController(alert, animated: true, completion: nil)
            } else {
                let errorView = UIAlertView(title: "Reset Finished!", message: message, delegate: nil, cancelButtonTitle: "OK")
                errorView.show()
            }
            
            self!.updateDataLabels()
        })
    }

    @IBAction func switchBasicPowerModeState(sender: UISwitch) {
        self.basicPowerModeSwitch!.enabled = false
        self.smartPowerModeSwitch!.enabled = false
        
        // Using [weak self] to eliminate retain cycle
        self.beaconConnection!.writeBasicPowerModeEnabled(sender.on, completion: { [weak self] (value: Bool, error:
            NSError?) -> () in
            
            self!.basicPowerModeSwitch!.enabled = true
            self!.smartPowerModeSwitch!.enabled = true
            if (error != nil)
            {
                self!.basicPowerModeSwitch!.on = !self!.basicPowerModeSwitch!.on
            }
        })
    }
    
    @IBAction func switchSmartPowerModeState(sender: UISwitch) {
        self.basicPowerModeSwitch!.enabled = false
        self.smartPowerModeSwitch!.enabled = false
        
        // Using [weak self] to eliminate retain cycle
        self.beaconConnection!.writeSmartPowerModeEnabled(sender.on, completion: { [weak self] (value: Bool, error:
            NSError?) -> () in
            
            self!.basicPowerModeSwitch!.enabled = true
            self!.smartPowerModeSwitch!.enabled = true
            if (error != nil)
            {
                self!.smartPowerModeSwitch!.on = !self!.smartPowerModeSwitch!.on
            }
        })
    }
    
    @IBAction func switchSecureUUIDState(sender: UISwitch) {
        self.basicPowerModeSwitch!.enabled = false
        self.smartPowerModeSwitch!.enabled = false
        self.secureUUIDSwitch!.enabled = false
        
        // Using [weak self] to eliminate retain cycle
        self.beaconConnection!.writeEstimoteSecureUUIDEnabled(sender.on, completion: { [weak self] (value: Bool, error: NSError?) -> () in
            
            self!.basicPowerModeSwitch!.enabled = true
            self!.smartPowerModeSwitch!.enabled = true
            self!.secureUUIDSwitch!.enabled = true
            if (error != nil)
            {
                self!.secureUUIDSwitch!.on = self!.secureUUIDSwitch!.on
            }
        })
    }
    
    @IBAction func changeConditionalBroadcastingType(sender: UISegmentedControl) {
        self.conditionalBroadcastingSegment!.enabled = false
        
        var conditionalBroadcasting: ESTBeaconConditionalBroadcasting?
        
        switch sender.selectedSegmentIndex {
        case 0:
            conditionalBroadcasting = ESTBeaconConditionalBroadcasting.Off
        case 1:
            conditionalBroadcasting = ESTBeaconConditionalBroadcasting.MotionOnly
        case 2:
            conditionalBroadcasting = ESTBeaconConditionalBroadcasting.FlipToStop
        default:
            conditionalBroadcasting = ESTBeaconConditionalBroadcasting.Unknown
            break
        }
        
        if conditionalBroadcasting != nil {
            // Using [weak self] to eliminate retain cycle
            self.beaconConnection!.writeConditionalBroadcastingType(conditionalBroadcasting!, completion: { [weak self] (value: Bool, error: NSError?) -> () in
                
                self!.conditionalBroadcastingSegment!.enabled = true
                if (error != nil)
                {
                    self!.conditionalBroadcastingSegment!.selectedSegmentIndex = UISegmentedControlNoSegment
                }
            })
        }
    }
    
    @IBAction func stepperValueChanged(sender: UIStepper) {
        self.currentValue = Int(self.beaconConnection!.power.shortValue)
        switch self.currentValue {
        case 4:
            if currentValue < Int(sender.value) {
                currentValue = 4
                powerStepper!.value = 4
            } else {
                currentValue = 0
                powerStepper!.value = 0
            }
        case 0:
            if currentValue < Int(sender.value) {
                currentValue = 4
                powerStepper!.value = 4
            } else {
                currentValue = -4
                powerStepper!.value = -4
            }
        case -4:
            if currentValue < Int(sender.value) {
                currentValue = 0
                powerStepper!.value = 0
            } else {
                currentValue = -8
                powerStepper!.value = -8
            }
        case -8:
            if currentValue < Int(sender.value) {
                currentValue = -4
                powerStepper!.value = -4
            } else {
                currentValue = -12
                powerStepper!.value = -12
            }
        case -12:
            if currentValue < Int(sender.value) {
                currentValue = -8
                powerStepper!.value = -8
            } else {
                currentValue = -16
                powerStepper!.value = -16
            }
        case -16:
            if currentValue < Int(sender.value) {
                currentValue = -12
                powerStepper!.value = -12
            } else {
                currentValue = -20
                powerStepper!.value = -20
            }
        case -20:
            if currentValue < Int(sender.value) {
                currentValue = -16
                powerStepper!.value = -16
            } else {
                currentValue = -30
                powerStepper!.value = -30
            }
        case -30:
            if currentValue < Int(sender.value) {
                currentValue = -20
                powerStepper!.value = -20
            } else {
                currentValue = -30
                powerStepper!.value = -30
            }
        default:
            break
        }
        
        let newPower: ESTBeaconPower? = ESTBeaconPower(rawValue: Int8(self.currentValue))
        self.beaconConnection!.writePower(newPower!, completion: { (somePower, error: NSError!) -> Void in
            if (error != nil) {
                print("Error Power write: %@", error!.localizedDescription)
            }
            self.powerLabel!.text = Int(self.powerStepper!.value).description
        })
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
