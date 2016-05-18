//
//  ESTCloudBeaconTableVC.swift
//  ExamplesSwift
//
//  Ported to Swift by David Cutshaw on 6/26/15.
//  Copyright © 2015 Bit Smartz LLC. All rights reserved.
//

import UIKit

class ESTCloudTableViewCell: UITableViewCell {

}

class ESTCloudBeaconTableVC: UITableViewController, UITextFieldDelegate {

    var cloudAPI: ESTCloudManager?
    var beaconsArray: NSArray?
    @IBOutlet weak var beaconsTable: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        NSBundle.mainBundle().loadNibNamed("ESTCloudBeaconTableVC", owner: self, options: nil)
        self.cloudAPI = ESTCloudManager.init()
        self.title = "Cloud Beacons"
        
        self.beaconsTable!.delegate = self
        self.beaconsTable!.dataSource = self
        
        self.beaconsTable!.registerClass(ESTCloudTableViewCell.self,
            forCellReuseIdentifier:"CloudCellIdentifier")
        
        // Get list of beacons from the Estimote Cloud
        // Using [weak self] to eliminate retain cycle
        self.cloudAPI?.fetchEstimoteBeaconsWithCompletion({ [weak self] (value, error) -> Void in
            
            if (error == nil)
            {
                self!.beaconsArray = value
                self!.beaconsTable!.reloadData()
            } else {
                if #available(iOS 8.0, *) {
                    let alert: UIAlertController = UIAlertController.init(title: "Connection error",
                        message: error!.localizedDescription,
                        preferredStyle: .Alert)
                    self!.presentViewController(alert, animated: true, completion: nil)
                } else {
                    let errorView = UIAlertView(title: "Connection error",
                        message: error.localizedDescription,
                        delegate: nil,
                        cancelButtonTitle: "OK")
                    
                    errorView.show()
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // This code was in the original Examples Objective-C code, but never got used.
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.beaconsArray != nil {
            return self.beaconsArray!.count
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CloudCellIdentifier", forIndexPath: indexPath)

        /*
        * Fill the table with beacon data.
        */
        let beacon: ESTBeaconVO = self.beaconsArray!.objectAtIndex(indexPath.row) as! ESTBeaconVO

        cell.textLabel!.text = String(format: "Major: %@, Minor: %@", (beacon as ESTBeaconVO).major, (beacon as ESTBeaconVO).minor)
        cell.detailTextLabel?.text = String(format: "UUID: %@", (beacon as ESTBeaconVO).proximityUUID)
        if (beacon as ESTBeaconVO).isSecured == true {
            cell.imageView?.image = UIImage(named: "beacon_secure")
        } else {
            cell.imageView?.image = UIImage(named: "beacon")
        }
        return cell;
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
