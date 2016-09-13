//
//  CollectionViewController.swift
//  RJCircularCollectionViewLayout
//
//  Created by Rounak Jain on 11/26/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class CollectionViewController: UICollectionViewController {
    
    let images: [String] = Bundle.main.paths(forResourcesOfType: "jpg", inDirectory: "Images")
    
    var dataSource: [String] = []
    
    let gradientLayer = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        collectionView!.register(UINib(nibName: "ImageViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)

        gradientLayer.colors = [UIColor(red:0.1107, green:0.7848, blue:0.7686, alpha:1.0).cgColor,
            UIColor(red:0.0739, green:0.0848, blue:0.4347, alpha:1.0).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageViewCell
        cell.imageView.image = UIImage(named: self.images[(indexPath as NSIndexPath).item])!
        return cell
    }

}
