//
//  CategoryCell.swift
//  TwoDirectionScrolling
//
//  Created by martin chibwe on 2/27/16.
//  Copyright © 2016 martin chibwe. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {




}


extension CategoryCell: UICollectionViewDataSource{
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("videoCell", forIndexPath: indexPath) as! UICollectionViewCell
        return cell

    }
    
    
    
    
}
