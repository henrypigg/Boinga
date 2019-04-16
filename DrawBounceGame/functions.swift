//
//  functions.swift
//  DrawBounceGame
//
//  Created by Henry Pigg on 4/15/19.
//  Copyright © 2019 Henry Pigg. All rights reserved.
//

import Foundation
import SpriteKit

func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
    let xDist = a.x - b.x
    let yDist = a.y - b.y
    return CGFloat(sqrt(xDist * xDist + yDist * yDist))
}
