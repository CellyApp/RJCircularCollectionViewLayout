//
//  CircularCollectionViewLayout.swift
//  CircularCollectionView
//
//  Created by Rounak Jain on 27/05/15.
//  Copyright (c) 2015 Rounak Jain. All rights reserved.
//

import UIKit

open class BaseCircularCollectionViewCell: UICollectionViewCell {
    override open func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        let circularlayoutAttributes = layoutAttributes as! CircularCollectionViewLayoutAttributes
        self.layer.anchorPoint = circularlayoutAttributes.anchorPoint
        self.center.y += (circularlayoutAttributes.anchorPoint.y - 0.5)*self.bounds.height
    }
}

class CircularCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    
    var anchorPoint = CGPoint(x: 0.5, y: 0.5)
    
    var angle: CGFloat = 0 {
        didSet {
            zIndex = Int(angle*1000000)
            transform = CGAffineTransform(rotationAngle: angle)
        }
    }
    
    override func copy(with zone: NSZone?) -> Any {
        let copiedAttributes: CircularCollectionViewLayoutAttributes = super.copy(with: zone) as! CircularCollectionViewLayoutAttributes
        copiedAttributes.anchorPoint = self.anchorPoint
        copiedAttributes.angle = self.angle
        return copiedAttributes
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object {
            if (!(object as AnyObject).isKind(of: CircularCollectionViewLayoutAttributes.self)) {
                return false
            }
            let objectCast = object as! CircularCollectionViewLayoutAttributes
            if objectCast.angle != self.angle || objectCast.anchorPoint != self.anchorPoint {
                return false
            }
            return super.isEqual(object)
        } else {
            return false
        }
    }
    
    override var hash: Int {
        return super.hash ^ self.anchorPoint.x.hashValue ^ self.anchorPoint.y.hashValue ^ self.angle.hashValue
    }
    
}

open class CircularCollectionViewLayout: UICollectionViewLayout {
    
    @IBInspectable var itemSize: CGSize = CGSize(width: 150, height: 150) {
        didSet {
            anglePerItem = atan(itemSize.width/radius)
            attributesList = []
            invalidateLayout()
        }
    }
    
    var angleAtExtreme: CGFloat {
        return collectionView!.numberOfItems(inSection: 0) > 0 ? -CGFloat(collectionView!.numberOfItems(inSection: 0)-1)*anglePerItem : 0
    }
    
    var angle: CGFloat {
        return angleAtExtreme*collectionView!.contentOffset.x/(collectionViewContentSize.width - collectionView!.bounds.width)
    }
    
    @IBInspectable var radius: CGFloat = 500 {
        didSet {
            anglePerItem = atan(itemSize.width/radius)
            attributesList = []
            invalidateLayout()
        }
    }
    
    var anglePerItem: CGFloat = 0
    
    var attributesList: [CircularCollectionViewLayoutAttributes] = []
    
    override open var collectionViewContentSize : CGSize {
        return CGSize(width: CGFloat(collectionView!.numberOfItems(inSection: 0))*itemSize.width,
            height: collectionView!.bounds.height)
    }
    
    override open class var layoutAttributesClass : AnyClass {
        return CircularCollectionViewLayoutAttributes.self
    }
    
    override open func prepare() {
        super.prepare()
        let totalItems = collectionView!.numberOfItems(inSection: 0) - 1
        if attributesList.count != totalItems {
            let anchorPointY = ((itemSize.height/2.0) + radius)/itemSize.height
            attributesList = (0...totalItems).map { (i) -> CircularCollectionViewLayoutAttributes in
                let attributes = CircularCollectionViewLayoutAttributes(forCellWith: IndexPath(item: i, section: 0))
                attributes.size = self.itemSize
                attributes.anchorPoint = CGPoint(x: 0.5, y: anchorPointY)
                return attributes
            }
        }
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let centerX = collectionView!.contentOffset.x + (collectionView!.bounds.width/2.0)
        let theta = atan2(collectionView!.bounds.width/2.0, radius + (itemSize.height/2.0) - (collectionView!.bounds.height/2.0))

        var startIndex = 0
        var endIndex = collectionView!.numberOfItems(inSection: 0) - 1
        
        if (angle < -theta) {
            startIndex = Int(floor((-theta - angle)/anglePerItem))
        }
        
        endIndex = min(endIndex, Int(ceil((theta - angle)/anglePerItem)))
        if (endIndex < startIndex) {
            endIndex = 0
            startIndex = 0
        }
        
        let centerY = collectionView!.bounds.midY
        
        for i in (startIndex...endIndex) {
            let attributes = attributesList[i]
            attributes.center = CGPoint(x: centerX, y: centerY)
            attributes.angle = self.angle + (anglePerItem*CGFloat(i))
        }
        return Array(attributesList[startIndex...endIndex])
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath)
        -> UICollectionViewLayoutAttributes {
            return attributesList[(indexPath as NSIndexPath).row]
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var finalContentOffset = proposedContentOffset
        let factor = -angleAtExtreme/(collectionViewContentSize.width - collectionView!.bounds.width)
        let proposedAngle = proposedContentOffset.x*factor
        let ratio = proposedAngle/anglePerItem
        var multiplier: CGFloat
        if (velocity.x > 0) {
            multiplier = ceil(ratio)
        } else if (velocity.x < 0) {
            multiplier = floor(ratio)
        } else {
            multiplier = round(ratio)
        }
        finalContentOffset.x = multiplier*anglePerItem/factor
        return finalContentOffset
    }
    
}
