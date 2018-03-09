//
//  VNTankView.swift
//  VNTankViewDemo
//
//  Created by Varun Naharia on 28/11/17.
//  Copyright © 2017 Varun Naharia. All rights reserved.
//
import UIKit
@IBDesignable
class VNTankView: UIView {
    
    var view: UIView!
    @IBOutlet weak var tankView: VNTank!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpView()
        xibSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.setUpView()
    }
    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.view.isOpaque = false
        view.isOpaque = false
        updateView()
    }
    
    func updateView() {
        tankView.layer.borderColor = UIColor.black.cgColor
        tankView.layer.borderWidth = 4
    }
    
    func setUpView() {
        
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.backgroundColor = UIColor.clear
        // use bounds not frame or it'll be offset
        view.frame = bounds
        view.backgroundColor = self.backgroundColor
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
        view.isOpaque = false
        self.isOpaque = false
        self.updateView()
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "VNTankView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        tankView.layer.cornerRadius = tankView.frame.width/2
    }
    
    fileprivate var tankFillColor:UIColor!
    fileprivate var fillPercentage:CGFloat = 0.0
    
    @IBInspectable var percent:Float
        {
        set
        {
            fillPercentage = CGFloat(newValue)
            tankView.percentage = 1-fillPercentage
            tankView.setNeedsDisplay()
        }
        get
        {
            return Float(fillPercentage)
        }
        
    }
    
    @IBInspectable var fillColor:UIColor
        {
        set{
            tankFillColor = newValue
            if(tankView != nil)
            {
                tankView.fillColor = tankFillColor
            }
        }
        get{
            return tankFillColor
        }
    }
}

class VNTank: UIView {
    var fillColor:UIColor = UIColor.blue
    var percentage:CGFloat = 0.0
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let upperRect = CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width, height: rect.size.height*percentage)
        let lowerRect = CGRect(x: rect.origin.x, y: rect.origin.y + (rect.size.height * percentage), width: rect.size.width, height: rect.size.height*(1 - percentage))
        
        UIColor.clear.set()
        UIRectFill(upperRect)
        fillColor.set()
        UIRectFill(lowerRect)
        self.layer.masksToBounds = true
    }
}
