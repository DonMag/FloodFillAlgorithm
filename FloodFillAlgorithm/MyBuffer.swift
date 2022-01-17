//
//  MyBuffer.swift
//  FloodFillAlgorithm
//
//  Created by Don Mag on 1/17/22.
//

import UIKit

struct MyBuffer {
	var buffer: [Int] = []
	var w: Int = 0
	var h: Int = 0
	func length() -> Int {
		return w * h
	}
	func count() -> Int {
		return buffer.count
	}
	
	mutating func clear(with colorNumber: Int) -> Void {
		buffer = Array(repeating: colorNumber, count: length())
	}
	
	mutating func fillRect(_ r: CGRect, colorNumber: Int) -> Void {
		var x1 = Int(r.origin.x)
		var y1 = Int(r.origin.y)
		var x2 = x1 + Int(r.size.width)
		var y2 = y1 + Int(r.size.height)
		
		x1 = max(0, x1)
		y1 = max(0, y1)
		x2 = min(w, x2)
		y2 = min(h, y2)
		
		let w = x2 - x1
		let h = y2 - y1
		guard w > 0, h > 0 else {
			print("Rect Size err", r)
			return
		}
		for row in y1..<y2 {
			let p = row * self.w + x1
			buffer.replaceSubrange(p..<p+w, with: repeatElement(colorNumber, count: w))
		}
	}
	
	mutating func replaceRectWithAlpha(_ r: CGRect, with rectArray: [Int], alpha: Int?) -> Void {
		var x1 = Int(r.origin.x)
		var y1 = Int(r.origin.y)
		var x2 = x1 + Int(r.size.width)
		var y2 = y1 + Int(r.size.height)
		
		x1 = max(0, x1)
		y1 = max(0, y1)
		x2 = min(w, x2)
		y2 = min(h, y2)
		
		let w = x2 - x1
		let h = y2 - y1
		guard w > 0, h > 0 else {
			print("Rect Size err", r)
			return
		}
		var pNew: Int = 0
		if alpha != nil {
			for row in y1..<y2 {
				let p = row * self.w + x1
				for col in 0..<w {
					if rectArray[pNew+col] != alpha {
						buffer[p+col] = rectArray[pNew+col]
					}
				}
				pNew += w
			}
		} else {
			for row in y1..<y2 {
				let p = row * self.w + x1
				buffer.replaceSubrange(p..<p+w, with: rectArray[pNew..<pNew+w])
				pNew += w
			}
		}
	}
	
	mutating func fillLine(pt1: CGPoint, pt2: CGPoint, lineWidth: Int, colorNumber: Int) -> Void {
		
		let x1: CGFloat = CGFloat(pt1.x)
		let x2: CGFloat = CGFloat(pt2.x)
		let y1: CGFloat = CGFloat(pt1.y)
		let y2: CGFloat = CGFloat(pt2.y)
		
		let halfLineWidth: CGFloat = CGFloat(lineWidth / 2)
		
		var w: CGFloat = x2 - x1
		var h: CGFloat = y2 - y1
		
		// if width == 0 (40,40 -> 40,140) it's a vertical line
		if w == 0 {
			var y = min(y1, y2)
			h = max(y1, y2) - y
			y -= halfLineWidth
			h += CGFloat(lineWidth)
			fillRect(CGRect(x: x1 - halfLineWidth, y: y, width: CGFloat(lineWidth), height: h), colorNumber: colorNumber)
			return
		}
		// if height == 0 (40,40 -> 140,40) it's a vertical line
		if h == 0 {
			var x = min(x1, x2)
			w = max(x1, x2) - x
			x -= halfLineWidth
			w += CGFloat(lineWidth)
			fillRect(CGRect(x: x, y: y1 - halfLineWidth, width: w, height: CGFloat(lineWidth)), colorNumber: colorNumber)
			return
		}
		
		var pp1:CGPoint = CGPoint(x: pt1.x, y: pt1.y)
		var pp2:CGPoint = CGPoint(x: pt2.x, y: pt2.y)
		
		// normalize for left-right
		if pp1.x > pp2.x {
			let tmp = pp1
			pp1 = pp2
			pp2 = tmp
		} else {
			// normalize for top-down
			if pp1.y > pp2.y {
				let tmp = pp1
				pp1 = pp2
				pp2 = tmp
			}
		}
		
		w = pp2.x - pp1.x
		h = pp2.y - pp1.y
		
		let xDir: CGFloat = w > 0 ? 1 : -1
		let yDir: CGFloat = h > 0 ? 1 : -1
		
		w *= xDir
		h *= yDir
		
		var steps: CGFloat = 0
		var segW: CGFloat = 0
		var segH: CGFloat = 0
		
		if w > h {
			h += 1
			segW = w / h
			steps = h //w / segW
			segH = 1
		} else {
			w += 1
			segH = h / w
			steps = w //h / segH
			segW = 1
		}
		
		var points: [CGPoint] = []
		
		points.append(pp1)
		
		let lw = CGFloat(lineWidth)
		
		if segW == 1 {
			pp1.x -= lw * 0.5
			for _ in 0..<Int(steps) {
				let r = CGRect(x: pp1.x, y: pp1.y, width: lw, height: ceil(segH))
				self.fillRect(r, colorNumber: colorNumber)
				pp1.x += xDir
				pp1.y += segH * yDir
			}
		} else {
			pp1.y -= lw * 0.5
			for _ in 0..<Int(steps) {
				let r = CGRect(x: pp1.x, y: pp1.y, width: ceil(segW), height: lw)
				self.fillRect(r, colorNumber: colorNumber)
				pp1.x += segW * xDir
				pp1.y += yDir
			}
		}
	}
	
}

