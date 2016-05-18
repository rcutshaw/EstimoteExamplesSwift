//
//  ESTSendGPSDemoVC.swift
//  ExamplesSwift
//
//  Ported to Swift by David Cutshaw on 6/26/15.
//  Copyright © 2015 Bit Smartz LLC. All rights reserved.
//

import UIKit
import MapKit

class ESTSendGPSDemoVC: UIViewController {

    var beacon: CLBeacon?
    var cloudManager: ESTCloudManager?
    @IBOutlet weak var mapView: MKMapView?
    
    func initWithBeacon(beacon: CLBeacon) -> ESTSendGPSDemoVC? {
        
        if let _:ESTSendGPSDemoVC = ESTSendGPSDemoVC()
        {
            self.beacon = beacon
        }
        return self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSBundle.mainBundle().loadNibNamed("ESTSendGPSDemoVC", owner: self, options: nil)
        self.title = "GPS Location"
        
        self.assignGPSLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func assignGPSLocation() {
        // ESTCloudManager is responsible for assinging
        // GPS location to the beacons
        self.cloudManager = ESTCloudManager()
        
        // inoked method will automaticaly collect current GPS location
        // and send it to Estimote Cloud
        self.cloudManager?.assignCurrentGPSLocationToBeacon(self.beacon, completion: { (result: AnyObject?, error: NSError!) -> Void in
            if (error == nil)
            {
                // Assigned location is delevered in completion block
                let location: CLLocation = result as! CLLocation
                
                // We can show it easily on Map View
                let annotation: MKPointAnnotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude,
                location.coordinate.longitude)
                annotation.title = "Beacon Location"
                
                annotation.subtitle = String(format: "(%i, %i)", self.beacon!.major.unsignedShortValue as UInt16, self.beacon!.minor.unsignedShortValue as UInt16)
                
                self.mapView!.addAnnotation(annotation)
                
                var zoomRect: MKMapRect = MKMapRectNull
                let annotationPoint: MKMapPoint = MKMapPointForCoordinate(annotation.coordinate)
                let pointRect: MKMapRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
                zoomRect = MKMapRectUnion(zoomRect, pointRect)
                
                self.mapView!.setVisibleMapRect(zoomRect, animated:true)
                self.mapView!.selectAnnotation(annotation, animated:true)
            }
            else
            {
                // GPS coordinates assigning error occured
                if #available(iOS 8.0, *) {
                    let alert: UIAlertController = UIAlertController.init(title: "Location assign error!",
                        message: error.localizedDescription,
                        preferredStyle: .Alert)
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    let errorView: UIAlertView = UIAlertView.init(title: "Location assign error!",
                        message:error.localizedDescription,
                        delegate:nil,
                        cancelButtonTitle:"OK")
                    errorView.show()
                }
            }
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
