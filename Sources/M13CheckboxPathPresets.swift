//
//  M13CheckboxPathManager.swift
//  M13Checkbox
//
//  Created by McQuilkin, Brandon on 3/27/16.
//  Copyright © 2016 Brandon McQuilkin. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import UIKit



internal class M13CheckboxPathPresets {
    
    //----------------------------
    // MARK: - Structures
    //----------------------------
    
    /// Contains the geometry information needed to generate the checkmark, as well as generates the locations of the feature points.
    struct CheckmarkProperties {
        
        /// The angle between the x-axis, and the line created between the origin, and the location where the extended long arm of the checkmark meets the box. (Diagram: Θ)
        var longArmBoxIntersectionAngle: CGFloat = 45.0 * CGFloat(M_PI / 180.0)
        
        /// The distance from the center the long arm of the checkmark draws to, as a percentage of size. (Diagram: S)
        var longArmRadius: (circle: CGFloat, box: CGFloat) = (circle: 0.22, box: 0.33)
        
        /// The distance from the center of the middle/bottom point of the checkbox, as a percentage of size. (Diagram: T)
        var middlePointRadius: (circle: CGFloat, box: CGFloat) = (circle: 0.133, box: 0.1995)
        
        /// The distance between the horizontal center and the middle point of the checkbox.
        var middlePointOffset: (circle: CGFloat, box: CGFloat) = (circle: -0.04, box: -0.06)
        
        /// The distance from the center of the left most point of the checkmark, as a percentage of size.
        var shortArmRadius: (circle: CGFloat, box: CGFloat) = (circle: 0.17, box: 0.255)
        
        /// The distance between the vertical center and the left most point of the checkmark, as a percentage of size.
        var shortArmOffset: (circle: CGFloat, box: CGFloat) = (circle: 0.02, box: 0.03)
    }
    
    //----------------------------
    // MARK: - Properties
    //----------------------------
    
    /// The maximum width or height the path will be generated with.
    var size: CGFloat = 0.0
    
    /// The line width of the created checkmark.
    var checkmarkLineWidth: CGFloat = 1.0
    
    /// The line width of the created box.
    var boxLineWidth: CGFloat = 1.0
    
    /// The corner radius of the box.
    var cornerRadius: CGFloat = 3.0
    
    /// The box type to create.
    var boxType: M13Checkbox.BoxType = .circle
    
    /// The type of checkmark to create.
    var markType: M13Checkbox.MarkType = .checkmark
    
    /// The parameters that define the checkmark.
    var checkmarkProperties: CheckmarkProperties = CheckmarkProperties()
    
    //----------------------------
    // MARK: - Points of Intrest
    //----------------------------
    
    /// The intersection point between the extended long checkmark arm, and the box.
    var checkmarkLongArmBoxIntersectionPoint: CGPoint {
        
        let cornerRadius: CGFloat = self.cornerRadius
        let boxLineWidth: CGFloat = self.boxLineWidth
        let size: CGFloat = self.size

        let radius: CGFloat = (size - boxLineWidth) / 2.0
        let theta:CGFloat = checkmarkProperties.longArmBoxIntersectionAngle
    
        if boxType == .circle {
            // Basic trig to get the location of the point on the circle.
            let x: CGFloat = (size / 2.0) + (radius * cos(theta))
            let y: CGFloat = (size / 2.0) - (radius * sin(theta))
            return CGPoint(x: x, y: y)
        } else {
            // We need to differentiate between the box edges and the rounded corner.
            let lineOffset: CGFloat = boxLineWidth / 2.0
            let circleX: CGFloat = size - lineOffset - cornerRadius
            let circleY: CGFloat = 0.0 + lineOffset + cornerRadius
            let edgeX: CGFloat = (size / 2.0) + (0.5 * (size - boxLineWidth) * (1.0 / tan(theta)))
            let edgeY: CGFloat = (size / 2.0) - (0.5 * (size - boxLineWidth) * tan(theta));

            if edgeX <= circleX {
                // On the top edge.
                return CGPoint(x: edgeX, y: lineOffset)
            } else if edgeY >= circleY {
                // On the right edge.
                let x: CGFloat = size - lineOffset
                return CGPoint(x: x, y: edgeY)
            } else {
                // On the corner
                let cos2Theta: CGFloat = cos(2.0 * theta)
                let sin2Theta: CGFloat = sin(2.0 * theta)
                let sqrtV: CGFloat = sqrt(((4.0 * cornerRadius) - size) * size)
                let powV: CGFloat = pow((2.0 * cornerRadius) + size, 2.0)
                
                let a: CGFloat = size * (3.0 + cos2Theta + sin2Theta)
                let b: CGFloat = -2.0 * cornerRadius * (cos(theta) + sin(theta))
                let c: CGFloat = sqrtV + (powV * sin2Theta)
                let d: CGFloat = size * cos(theta) * (cos(theta) - sin(theta))
                let e: CGFloat = 2.0 * cornerRadius * sin(theta) * (cos(theta) + sin(theta))
                
                let x: CGFloat = 0.25 * (a + (2.0 * (b + c) * cos(theta))) + (boxLineWidth / 2.0)
                let y: CGFloat = 0.5 * (d + e - (c * sin(theta))) + (boxLineWidth / 2.0)
                
                return CGPoint(x: x, y: y)
            }
        }
    }
    
    var checkmarkLongArmEndPoint: CGPoint {
        let s: CGFloat = size
        let bLW: CGFloat = boxLineWidth
        
        // Known variables
        let boxEndPoint: CGPoint = checkmarkLongArmBoxIntersectionPoint
        let x2: CGFloat = boxEndPoint.x
        let y2: CGFloat = boxEndPoint.y
        let midPoint: CGPoint = checkmarkMiddlePoint
        let x1: CGFloat = midPoint.x
        let y1: CGFloat = midPoint.y
        let r: CGFloat = boxType == .circle ? s * checkmarkProperties.longArmRadius.circle : s * checkmarkProperties.longArmRadius.box
        
        let a1: CGFloat = (s * pow(x1, 2.0)) - (2.0 * s * x1 * x2) + (s * pow(x2, 2.0)) + (s * x1 * y1) - (s * x2 * y1)
        let a2: CGFloat = (2.0 * x2 * pow(y1, 2.0)) - (s * x1 * y2) + (s * x2 * y2) - (2.0 * x1 * y1 * y2) - (2.0 * x2 * y1 * y2) + (2.0 * x1 * pow(y2, 2.0))
        
        let b: CGFloat = -16.0 * (pow(x1, 2.0) - (2.0 * x1 * x2) + pow(x2, 2.0) + pow(y1, 2.0) - (2.0 * y1 * y2) + pow(y2, 2.0))
        
        let c1: CGFloat = pow(r, 2.0) * ((-pow(x1, 2.0)) + (2.0 * x1 * x2) - pow(x2, 2.0))
        let c2: CGFloat = pow(s, 2.0) * ((0.5 * pow(x1, 2.0)) - (x1 * x2) + (0.5 * pow(x2, 2.0)))
        
        let d1: CGFloat = (pow(x2, 2.0) * pow(y1, 2.0)) - (2.0 * x1 * x2 * y1 * y2) + (pow(x1, 2.0) * pow(y2, 2.0))
        let d2: CGFloat = s * ((x1 * x2 * y1) - (pow(x2, 2.0) * y1) - (pow(x1, 2.0) * y2) + (x1 * x2 * y2))
        
        let cd: CGFloat = c1 + c2 + d1 + d2
        
        let e1: CGFloat = (x1 * ((4.0 * y1) - (4.0 * y2)) * y2) + (x2 * y1 * ((-4.0 * y1) + (4.0 * y2)))
        let e2: CGFloat = s * ((-2.0 * pow(x1, 2.0)) + (x2 * ((-2.0 * x2) + (2.0 * y1) - (2.0 * y2))) + (x1 * (4.0 * x2 - (2.0 * y1) + (2.0 * y2))))
        
        let f: CGFloat = pow(x1, 2.0) - (2.0 * x1 * x2) + pow(x2, 2.0) + pow(y1, 2.0) - (2.0 * y1 * y2) + pow(y2, 2)
        
        let g1: CGFloat = (0.5 * s * x1 * y1) - (0.5 * s * x2 * y1) - (x1 * x2 * y1) + (pow(x2, 2.0) * y1) + (0.5 * s * pow(y1, 2.0))
        let g2: CGFloat = (-0.5 * s * x1 * y2) + (pow(x1, 2.0) * y2) + (0.5 * s * x2 * y2) - (x1 * x2 * y2) - (s * y1 * y2) + (0.5 * s * pow(y2, 2.0))
        
        let h1: CGFloat = (-4.0 * pow(x2, 2.0) * y1) - (4.0 * pow(x1, 2.0) * y2) + (x1 * x2 * ((4.0 * y1) + (4.0 * y2)))
        let h2: CGFloat = s * ((-2.0 * x1 * y1) + (2.0 * x2 * y1) - (2.0 * pow(y1, 2.0)) + (2.0 * x1 * y2) - (2.0 * x2 * y2) + (4.0 * y1 * y2) - (2.0 * pow(y2, 2.0)))
        
        let i: CGFloat = (pow(r, 2.0) * (-pow(y1, 2.0) + (2.0 * y1 * y2) - pow(y2, 2.0))) + (pow(s, 2.0) * ((0.5 * pow(y1, 2.0)) - (y1 * y2) + (0.5 * pow(y2, 2.0))))
        let j: CGFloat = s * ((x1 * (y1 - y2) * y2) + (x2 * y1 * (-y1 + y2)))
        
        let powE1E2: CGFloat = pow(e1 + e2, 2.0)
        let subX1: CGFloat = (b * cd) + powE1E2
        
        let powH1H2: CGFloat = pow(h1 + h2, 2.0)
        let subY1: CGFloat = powH1H2 + (b * (d1 + i + j))
        
        let x: CGFloat = (0.5 * (a1 + a2 + (0.5 * sqrt(subX1))) + (bLW / 2.0)) / f
        let y: CGFloat = (g1 + g2 - (0.25 * sqrt(subY1)) + (bLW / 2.0)) / f
  
        return CGPoint(x: x, y: y)
    }
    
    var checkmarkMiddlePoint: CGPoint {
        let r: CGFloat = boxType == .circle ? checkmarkProperties.middlePointRadius.circle : checkmarkProperties.middlePointRadius.box
        let o: CGFloat = boxType == .circle ? checkmarkProperties.middlePointOffset.circle : checkmarkProperties.middlePointOffset.box
        let x: CGFloat = (size / 2.0) + (size * o)
        let y: CGFloat = (size / 2.0 ) + (size * r)
        return CGPoint(x: x, y: y)
    }
    
    var checkmarkShortArmEndPoint: CGPoint {
        let r: CGFloat = boxType == .circle ? checkmarkProperties.shortArmRadius.circle : checkmarkProperties.shortArmRadius.box
        let o: CGFloat = boxType == .circle ? checkmarkProperties.shortArmOffset.circle : checkmarkProperties.shortArmOffset.box
        let x: CGFloat = (size / 2.0) - (size * r)
        let y: CGFloat = (size / 2.0) + (size * o)
        return CGPoint(x: x, y: y)
    }
    
    //----------------------------
    // MARK: - Paths
    //----------------------------
    
    /**
     Creates a path object for the box.
     - returns: A `UIBezierPath` representing the box.
     */
    final func pathForBox() -> UIBezierPath {
        switch boxType {
        case .circle:
            return pathForCircle()
        case .square:
            return pathForRoundedRect()
        }
    }
    
    func pathForCircle() -> UIBezierPath {
        let radius = (size - boxLineWidth) / 2.0
        // Create a circle that starts in the top right hand corner.
        return UIBezierPath(arcCenter: CGPoint(x: size / 2.0, y: size / 2.0),
                            radius: radius,
                            startAngle: -checkmarkProperties.longArmBoxIntersectionAngle,
                            endAngle: CGFloat(2 * M_PI) - checkmarkProperties.longArmBoxIntersectionAngle,
                            clockwise: true)
    }
    
    func pathForRoundedRect() -> UIBezierPath {
        let path = UIBezierPath()
        let lineOffset: CGFloat = boxLineWidth / 2.0
        
        let trX: CGFloat = size - lineOffset - cornerRadius
        let trY: CGFloat = 0.0 + lineOffset + cornerRadius
        let tr = CGPoint(x: trX, y: trY)
        
        let brX: CGFloat = size - lineOffset - cornerRadius
        let brY: CGFloat = size - lineOffset - cornerRadius
        let br = CGPoint(x: brX, y: brY)
        
        let blX: CGFloat = 0.0 + lineOffset + cornerRadius
        let blY: CGFloat = size - lineOffset - cornerRadius
        let bl = CGPoint(x: blX, y: blY)
        
        let tlX: CGFloat = 0.0 + lineOffset + cornerRadius
        let tlY: CGFloat = 0.0 + lineOffset + cornerRadius
        let tl = CGPoint(x: tlX, y: tlY)
        
        // Start in the top right corner.
        let offset: CGFloat = ((cornerRadius * sqrt(2)) / 2.0)
        let trXOffset: CGFloat = tr.x + offset
        let trYOffset: CGFloat = tr.y - offset
        path.move(to: CGPoint(x: trXOffset, y: trYOffset))
        // Bottom of top right arc.12124
        if cornerRadius != 0 {
            path.addArc(withCenter: tr,
                                  radius: cornerRadius,
                                  startAngle: CGFloat(-M_PI_4),
                                  endAngle: 0.0,
                                  clockwise: true)
        }
        // Right side.
        let brXCr: CGFloat = br.x + cornerRadius
        path.addLine(to: CGPoint(x: brXCr, y: br.y))
        
        // Bottom right arc.
        if cornerRadius != 0 {
            path.addArc(withCenter: br,
                                  radius: cornerRadius,
                                  startAngle: 0.0,
                                  endAngle: CGFloat(M_PI_2),
                                  clockwise: true)
        }
        // Bottom side.
        let blYCr: CGFloat = bl.y + cornerRadius
        path.addLine(to: CGPoint(x: bl.x , y: blYCr))
        // Bottom left arc.
        if cornerRadius != 0 {
            path.addArc(withCenter: bl,
                                  radius: cornerRadius,
                                  startAngle: CGFloat(M_PI_2),
                                  endAngle: CGFloat(M_PI),
                                  clockwise: true)
        }
        // Left side.
        let tlXCr: CGFloat = tl.x - cornerRadius
        path.addLine(to: CGPoint(x: tlXCr, y: tl.y))
        // Top left arc.
        if cornerRadius != 0 {
            path.addArc(withCenter: tl,
                                  radius: cornerRadius,
                                  startAngle: CGFloat(M_PI),
                                  endAngle: CGFloat(M_PI + M_PI_2),
                                  clockwise: true)
        }
        // Top side.
        let trYCr: CGFloat = tr.y - cornerRadius
        path.addLine(to: CGPoint(x: tr.x, y: trYCr))
        // Top of top right arc
        if cornerRadius != 0 {
            path.addArc(withCenter: tr,
                                  radius: cornerRadius,
                                  startAngle: CGFloat(M_PI + M_PI_2),
                                  endAngle: CGFloat(M_PI + M_PI_2 + M_PI_4),
                                  clockwise: true)
        }
        path.close()
        return path
    }
    
    //----------------------------
    // MARK: - Check Generation
    //----------------------------
    
    final func path(_ state: M13Checkbox.CheckState) -> UIBezierPath? {
        switch state {
        case .unchecked:
            return pathForUnselectedMark()
        case .checked:
            return pathForMark()
        case .mixed:
            return pathForMixedMark()
        }
    }
    
    final func pathForMark() -> UIBezierPath {
        switch markType {
        case .checkmark:
            return pathForCheckmark()
        case .radio:
            return pathForRadio()
        }
    }
    
    /**
     Creates a path object for the checkmark.
     - returns: A `UIBezierPath` representing the checkmark.
     */
    func pathForCheckmark() -> UIBezierPath {
        let path = UIBezierPath()
        
        path.move(to: checkmarkShortArmEndPoint)
        path.addLine(to: checkmarkMiddlePoint)
        path.addLine(to: checkmarkLongArmEndPoint)
        
        return path
    }
    
    func pathForRadio() -> UIBezierPath {
        let transform = CGAffineTransform(scaleX: 0.665, y: 0.665)
        let translate = CGAffineTransform(translationX: size * 0.1675, y: size * 0.1675)
        let path = pathForBox()
        path.apply(transform)
        path.apply(translate)
        return path
    }
    
    //----------------------------
    // MARK: - Mixed Mark Generation
    //----------------------------
    
    /**
     Creates a path object for the mixed mark.
     - returns: A `UIBezierPath` representing the mixed mark.
     */
    final func pathForMixedMark() -> UIBezierPath {
        switch markType {
        case .checkmark:
            return pathForMixedCheckmark()
        case .radio:
            return pathForMixedRadio()
        }
    }
    
    func pathForMixedCheckmark() -> UIBezierPath {
        let path = UIBezierPath()
        
        // Left point
        path.move(to: CGPoint(x: size * 0.25, y: size / 2.0))
        // Middle point
        path.addLine(to: CGPoint(x: size * 0.5, y: size / 2.0))
        // Right point
        path.addLine(to: CGPoint(x: size * 0.75, y: size / 2.0))
        
        return path
    }
    
    func pathForMixedRadio() -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: size * 0.25, y: size / 2.0))
        path.addLine(to: CGPoint(x: size * 0.75, y: size / 2.0))
        path.reversing()
        return path
    }
    
    //----------------------------
    // MARK: - Unselected Mark Generation
    //----------------------------
    
    /**
     Creates a path object for the mixed mark.
     - returns: A `UIBezierPath` representing the mixed mark.
     */
    final func pathForUnselectedMark() -> UIBezierPath? {
        switch markType {
        case .checkmark:
            return pathForUnselectedCheckmark()
        case .radio:
            return pathForUnselectedRadio()
        }
    }
    
    func pathForUnselectedCheckmark() -> UIBezierPath? {
        return pathForCheckmark()
    }
    
    func pathForUnselectedRadio() -> UIBezierPath? {
        return pathForRadio()
    }
}
