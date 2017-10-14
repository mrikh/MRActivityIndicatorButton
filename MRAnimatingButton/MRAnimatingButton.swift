//
//  MRAnimatingButton.swift
//  MRAnimatingButton
//
//  Created by Mayank Rikh on 17/09/17.
//  Copyright © 2017 Mayank Rikh. All rights reserved.
//

import UIKit

class MRAnimatingButton: UIButton {
    
    @IBInspectable var progressColor : UIColor = UIColor.white{
        
        didSet{
            
            if let tempLayer = searchForLayer(){
                
                tempLayer.strokeColor = progressColor.cgColor
                
                return
                
            }
        }
    }

    var tempCornerRadius : CGFloat!
    var originalRect : CGRect!
    var titleString : String?
    
    var stopRotation = false
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }

    func startAnimating(){
        
        titleString = titleLabel?.text
        originalRect = frame
        tempCornerRadius = layer.cornerRadius
        stopRotation = false
        self.setTitle("", for: .normal)
        
        animateWidth(bounds.size.width, toValue: bounds.size.height)
        //to prevent frame from snapping back to original values
        frame = CGRect(x: frame.origin.x + frame.size.width/2.0 - frame.size.height/2.0, y: frame.origin.y, width: frame.size.height, height: frame.size.height)
        
        
        animateCornerRadius(layer.cornerRadius, toValue: bounds.width/2.0)
        layer.cornerRadius = bounds.width/2.0
        
        drawAlmostCompleteCircle()
        
        showTick()
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.3) { 
            
            self.rotateInfinitely()
        }
    }
    
    func stopAnimating(){
        
        stopRotation = true
        
        self.layer.removeAllAnimations()
        
        clearTick()
        
        animateWidth(bounds.size.height, toValue: bounds.size.width)
        frame = originalRect
        
        animateCornerRadius(layer.cornerRadius, toValue: tempCornerRadius)
        layer.cornerRadius = tempCornerRadius
        
        setTitle(titleString, for: .normal)
    }
    
    private func animateWidth(_ fromValue : CGFloat, toValue : CGFloat){
        
        let animation = CABasicAnimation(keyPath: "bounds.size.width")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = 0.3;
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        layer.add(animation, forKey: "bounds.size.width")
    }
    
    private func animateCornerRadius(_ fromValue : CGFloat, toValue : CGFloat){
        
        let animationCornerRadius = CABasicAnimation(keyPath: "cornerRadius")
        animationCornerRadius.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animationCornerRadius.fromValue = fromValue
        animationCornerRadius.toValue = toValue
        animationCornerRadius.duration = 0.3;
        layer.add(animationCornerRadius, forKey: "cornerRadius")
    }
    
    private func drawAlmostCompleteCircle(){
        
        let tickLayer = CAShapeLayer()
        tickLayer.path = UIBezierPath(roundedRect: CGRect(x: 5, y: 5, width: frame.size.height - 10, height: frame.size.height - 10), cornerRadius: frame.size.height/2.0).cgPath
        tickLayer.lineWidth = 2.0
        tickLayer.fillColor = UIColor.clear.cgColor
        tickLayer.strokeEnd = 0.0
        tickLayer.strokeColor = progressColor.cgColor
        tickLayer.setValue(1005, forKey: "animationTag")
        layer.addSublayer(tickLayer)
    }
    
    private func showTick(){
        
        animating(fromValue: 0.0, andToValue: 0.9, andShouldClear: false)
    }
    
    private func clearTick(){
        
        animating(fromValue: 0.9, andToValue: 0.0, andShouldClear: true)
    }
    
    private func animating(fromValue from:CGFloat, andToValue to:CGFloat, andShouldClear clear:Bool){
        
        //get our shapeLayer reference
        guard let shapeLayer = searchForLayer() else {
            
            return
        }
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        animation.duration = 0.2
        
        animation.fromValue = from
        
        animation.toValue = to
        
        animation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionLinear)
        
        if clear{
            
            if shapeLayer.strokeEnd != 0.9{
                
                return;
            }
            
            shapeLayer.removeAnimation(forKey: "strokeEnd")
            
            shapeLayer.strokeEnd = 0.0
            
        }else{
            
            if shapeLayer.strokeEnd != 0.0{
                
                return;
            }
            
            shapeLayer.strokeEnd = 0.9
        }
        
        // Do the actual animation
        shapeLayer.add(animation, forKey: "strokeEnd")
    }
    
    private func searchForLayer() -> CAShapeLayer?{
        
        var shapeLayer : CAShapeLayer?
        
        guard let subLayers = layer.sublayers else{
            
            return shapeLayer
        }
        
        for layer in subLayers{
            
            guard let value =  layer.value(forKey: "animationTag"), let intValue = value as? Int else {
                
                continue
            }
            
            if intValue == 1005{
                
                shapeLayer = layer as? CAShapeLayer
                
                break
            }
        }
        
        return shapeLayer
    }
    
    private func rotateInfinitely(){
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.duration = 1.0
        rotateAnimation.toValue = CGFloat(.pi * 2.0)
        rotateAnimation.repeatCount = .infinity
        
        self.layer.add(rotateAnimation, forKey: nil)
    }
}
