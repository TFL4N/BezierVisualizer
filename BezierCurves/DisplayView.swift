//
//  DisplayView.swift
//  BezierCurves
//
//  Created by Spizzace on 10/20/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import Cocoa

class DisplayView: NSView {
    private var axis_layer: CAShapeLayer = CAShapeLayer()
    private var grid_layer: CAShapeLayer = CAShapeLayer()
    private var curve_layer: CAShapeLayer = CAShapeLayer()
    
    var document: Document? = nil {
        willSet {
            if let document = self.document {
                document.bezier_curve.unregisterObserver(self)
                document.settings.unregisterObserver(self)
            }
        }
        
        didSet {
            if let document = self.document {
                document.bezier_curve.registerObserver(self)
                document.settings.registerObserver(self)
            }
            
            self.refresh()
        }
    }
    
    var settings: Settings {
        return self.document?.settings ?? Settings()
    }
    
    private var aspect_ratio: CGFloat {
        return self.layer!.bounds.width / self.layer!.bounds.height
    }
    
    private var x_scale: CGFloat {
        return self.layer!.bounds.width / CGFloat(self.settings.display_bounds.x)
    }
    
    private var y_scale: CGFloat {
        return self.layer!.bounds.height / CGFloat(self.settings.display_bounds.y)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.commonInit()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        self.commonInit()
    }
    
    private func commonInit() {
        let new_layer = CALayer()
        new_layer.layoutManager = CAConstraintLayoutManager()
        new_layer.backgroundColor = CGColor.white

        self.layer = new_layer
        self.wantsLayer = true
        
        self.settings.display_bounds.x *= Double(self.aspect_ratio)
        
        self.refresh()
    }
    
    public func refresh() {
        self.updateGridLayer()
        self.updateAxisLayer()
        self.updateBezierCurve()
    }
    
    private func getDenormalizedPoint(_ point: Point) -> CGPoint {
        var output = point.cgPoint
    
        // adjust scale
        output.x *= self.x_scale
        output.y *= self.y_scale
        
        // adjust origin
        output += self.settings.origin_offset.cgPoint
        
        return output
    }
    
    private func updateBezierCurve() {
        guard let document = self.document else {
            if self.curve_layer.superlayer != nil {
                self.curve_layer.removeFromSuperlayer()
            }
            
            return
        }
        
        let p0 = self.getDenormalizedPoint(document.bezier_curve.p0)
        let p1 = self.getDenormalizedPoint(document.bezier_curve.p1)
        let p2 = self.getDenormalizedPoint(document.bezier_curve.p2)
        let p3 = self.getDenormalizedPoint(document.bezier_curve.p3)
        
        let curve_path = CGMutablePath()
        curve_path.move(to: p0)
        curve_path.addCurve(to: p3, control1: p1, control2: p2)
        
        //// shape
        let curve_shape = CAShapeLayer()
        curve_shape.path = curve_path
        curve_shape.lineWidth = CGFloat(self.settings.curve_line_width)
        curve_shape.fillColor = CGColor.clear
        curve_shape.strokeColor = self.settings.curve_line_color.cgColor
        
        if self.curve_layer.superlayer != nil {
            self.curve_layer.removeFromSuperlayer()
        }
        self.curve_layer = curve_shape
        
        self.layer!.addSublayer(self.curve_layer)
    }
    
    private func updateAxisLayer() {
        let axis_path = CGMutablePath()
        
        ///// x-axis
        let x_interval = self.layer!.bounds.size.width / CGFloat(self.settings.display_bounds.x)
        let x_origin = CGFloat(self.settings.origin_offset.x) * x_interval
        
        let x_start = CGPoint(x: x_origin, y: 0)
        let x_end = CGPoint(x: x_origin, y: self.layer!.bounds.size.height)
        
        axis_path.move(to: x_start)
        axis_path.addLine(to: x_end)
        
        ///// y-axis
        let y_interval = self.layer!.bounds.size.height / CGFloat(self.settings.display_bounds.y)
        let y_origin = CGFloat(self.settings.origin_offset.y) * y_interval
        
        let y_start = CGPoint(x: 0, y: y_origin)
        let y_end = CGPoint(x: self.layer!.bounds.size.width, y: y_origin)
        
        axis_path.move(to: y_start)
        axis_path.addLine(to: y_end)
        
        //// shape
        let axis_shape = CAShapeLayer()
        axis_shape.path = axis_path
        axis_shape.lineWidth = CGFloat(self.settings.axis_line_width)
        axis_shape.fillColor = CGColor.clear
        axis_shape.strokeColor = self.settings.axis_line_color.cgColor
        
        if self.axis_layer.superlayer != nil {
            self.axis_layer.removeFromSuperlayer()
        }
        self.axis_layer = axis_shape
        
        self.layer!.addSublayer(self.axis_layer)
    }
    
    private func updateGridLayer() {
        let grid_path = CGMutablePath()
        
        ///// x
        let x_interval = self.layer!.bounds.size.width / CGFloat(self.settings.display_bounds.x)
        let x_origin = CGFloat(self.settings.origin_offset.x) * x_interval
        var x_position: CGFloat = x_origin + x_interval
        
        while x_position < self.layer!.bounds.size.width {
            let start = CGPoint(x: x_position, y: 0)
            let end = CGPoint(x: x_position, y: self.layer!.bounds.size.height)
            
            grid_path.move(to: start)
            grid_path.addLine(to: end)
            
            // loop
            x_position += x_interval
        }
        
        x_position = x_origin - x_interval
        while x_position > 0 {
            let start = CGPoint(x: x_position, y: 0)
            let end = CGPoint(x: x_position, y: self.layer!.bounds.size.height)

            grid_path.move(to: start)
            grid_path.addLine(to: end)

            // loop
            x_position -= x_interval
        }
        
        //// y
        let y_interval = self.layer!.bounds.size.height / CGFloat(self.settings.display_bounds.y)
        let y_origin = CGFloat(self.settings.origin_offset.y) * y_interval
        var y_position: CGFloat = y_origin + y_interval
        
        while y_position < self.layer!.bounds.size.height {
            let start = CGPoint(x: 0, y: y_position)
            let end = CGPoint(x: self.layer!.bounds.size.width, y:y_position)
            
            grid_path.move(to: start)
            grid_path.addLine(to: end)
            
            // loop
            y_position += y_interval
        }
        
        y_position = y_origin - y_interval
        while y_position > 0 {
            let start = CGPoint(x: 0, y: y_position)
            let end = CGPoint(x: self.layer!.bounds.size.width, y:y_position)
            
            grid_path.move(to: start)
            grid_path.addLine(to: end)
            
            // loop
             y_position -= y_interval
        }
        
        //// shape
        let grid_shape = CAShapeLayer()
        grid_shape.path = grid_path
        grid_shape.lineWidth = CGFloat(self.settings.major_line_width)
        grid_shape.fillColor = CGColor.clear
        grid_shape.strokeColor = self.settings.major_line_color.cgColor
        
        if self.grid_layer.superlayer != nil {
            self.grid_layer.removeFromSuperlayer()
        }
        self.grid_layer = grid_shape
        
        self.layer!.addSublayer(self.grid_layer)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath != nil {
            self.refresh()
        }
    }
}
