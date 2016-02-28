//
//  ViewController.swift
//  TwoDirectionScrolling
//
//  Created by martin chibwe on 2/27/16.
//  Copyright © 2016 martin chibwe. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var categories = ["Action", "Drama", "Science Fiction", "Kids", "Horror"]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


    
    

}

extension ViewController : UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return categories.count
    }
    

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categories[section]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as? CategoryCell
        
        return cell!
    }


    
}

