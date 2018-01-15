//
//  LoginBackgroundSteps.swift
//  breadwallet
//
//  Created by Brendan E. Mahon on 2018-01-14.
//  Copyright © 2018 KeyDino LLC. All rights reserved.
//

import UIKit

class LoginBackgroundSteps : UIView {

    //MARK: - Public
    init(vertexLocation: CGFloat) {
        self.vertexLocation = vertexLocation
        super.init(frame: .zero)
        backgroundColor = .clear
    }

    //MARK: - Private
    private let vertexLocation: CGFloat //A percentage value (0.0->1.0) of the right vertex's vertical location
    private let imageView = UIImageView(image: #imageLiteral(resourceName: "Step"))

    override func layoutSubviews() {
        /*
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0, y: 0))
        bezierPath.addLine(to: CGPoint(x: bounds.maxX, y: bounds.height*vertexLocation))
        bezierPath.addLine(to: CGPoint(x: 0, y: bounds.maxY))
        bezierPath.close()

        layer.shadowPath = bezierPath.cgPath
        layer.shadowColor = UIColor(white: 0.0, alpha: 0.15).cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 1.0
         */
        var transform = CATransform3DIdentity;
        transform.m34 = 1.0 / 500.0;
        transform = CATransform3DRotate(transform, CGFloat(45 * Double.pi / 180), 0, 1, 0)
        transform = CATransform3DRotate(transform, CGFloat(10 * Double.pi / 180), 1, 0, 0)
        imageView.layer.transform = transform
        setAnchorPoint(anchorPoint: CGPoint(x: 1.0, y: 0.5), forView: imageView)
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.move(to: CGPoint(x: 0, y: 0))
        context.addLine(to: CGPoint(x: rect.maxX, y: bounds.height*vertexLocation))
        context.addLine(to: CGPoint(x: 0, y: rect.maxY))
        context.closePath()
        context.clip()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = [UIColor.gradientStart.cgColor, UIColor.gradientEnd.cgColor] as CFArray
        let locations: [CGFloat] = [0.0, 1.0]
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) else { return }
        context.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: rect.width, y: 0.0), options: [])
    }
    
    func setAnchorPoint(anchorPoint: CGPoint, forView view: UIView) {
        var newPoint = CGPoint(x: view.bounds.size.width * anchorPoint.x, y: view.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(x: view.bounds.size.width * view.layer.anchorPoint.x, y: view.bounds.size.height * view.layer.anchorPoint.y)
        
        newPoint = newPoint.applying(view.transform)
        oldPoint = oldPoint.applying(view.transform)
        
        var position = view.layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        view.layer.position = position
        view.layer.anchorPoint = anchorPoint
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
