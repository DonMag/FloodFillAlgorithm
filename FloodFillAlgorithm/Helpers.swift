//
//  Helpers.swift
//  FloodFillAlgorithm
//
//  Created by Don Mag on 1/17/22.
//

import UIKit

enum FloodShape: String, Codable, CaseIterable {
	case square = "Square"
	case cross = "Cross"
	case triangle = "Triangle"
	case spiral = "Spiral"
	case random = "Random"
}

enum GridSize: String, Codable, CaseIterable {
	case x64 = "64x64"
	case x128 = "128x128"
	case x256 = "256x256"
	var size: CGFloat {
		switch self {
		case .x64:
			return 64
		case .x128:
			return 128
		case .x256:
			return 256
		}
	}
}

enum Mode: Int, Codable, CaseIterable {
	case zoomIn
	case zoomOut
	case pan
	case draw
	case flood
	var stringValue: String {
		switch self {
		case .zoomIn:
			return "+"
		case .zoomOut:
			return "-"
		case .pan:
			return "P"
		case .draw:
			return "D"
		case .flood:
			return "F"
		}
	}
}


@objc protocol FloodViewDelegate {
	@objc optional func algorithmTime(_ t: CFTimeInterval, changed: Bool)
	@objc optional func drawTime(_ t: CFTimeInterval)
}


extension CGPoint {
	func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
		return CGPoint(x: x + dx, y: y + dy)
	}
	func multipliedBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
		return CGPoint(x: x * dx, y: y * dy)
	}
}
