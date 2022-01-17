//
//  Helpers.swift
//  FloodFillAlgorithm
//
//  Created by Don Mag on 1/17/22.
//

import UIKit

extension CGPoint {
	func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
		return CGPoint(x: x + dx, y: y + dy)
	}
	func multipliedBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
		return CGPoint(x: x * dx, y: y * dy)
	}
}
