//
//  BezierCurve.swift
//  BezierCurves
//
//  Created by Spizzace on 10/20/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import Foundation

class CubicBezierCurve: NSObject, NSCoding {
    var p0: Point
    var p1: Point
    var p2: Point
    var p3: Point
    
    override init() {
        self.p0 = Point()
        self.p1 = Point()
        self.p2 = Point()
        self.p3 = Point()
        
        super.init()
    }
    
    init(p0: Point, p1: Point, p2: Point, p3: Point) {
        self.p0 = p0
        self.p1 = p1
        self.p2 = p2
        self.p3 = p3
        
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let p0 = aDecoder.decodeObject(forKey: "cubic_bezier_curve_p0") as? Point,
            let p1 = aDecoder.decodeObject(forKey: "cubic_bezier_curve_p1") as? Point,
            let p2 = aDecoder.decodeObject(forKey: "cubic_bezier_curve_p2") as? Point,
            let p3 = aDecoder.decodeObject(forKey: "cubic_bezier_curve_p3") as? Point else {
                return nil
        }
        
        self.init(p0: p0, p1: p1, p2: p2, p3: p3)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.p0, forKey: "cubic_bezier_curve_p0")
        aCoder.encode(self.p1, forKey: "cubic_bezier_curve_p1")
        aCoder.encode(self.p2, forKey: "cubic_bezier_curve_p2")
        aCoder.encode(self.p3, forKey: "cubic_bezier_curve_p3")
    }
    
    func registerObserver(_ object: NSObject) {
        self.p0.registerObserver(object)
        self.p1.registerObserver(object)
        self.p2.registerObserver(object)
        self.p3.registerObserver(object)
    }
    
    func unregisterObserver(_ object: NSObject) {
        self.p0.unregisterObserver(object)
        self.p1.unregisterObserver(object)
        self.p2.unregisterObserver(object)
        self.p3.unregisterObserver(object)
    }
}
