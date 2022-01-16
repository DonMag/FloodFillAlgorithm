//
//  FloodView.swift
//  FloodFillAlgorithm
//
//  Created by Don Mag on 1/15/22.
//

import UIKit

enum FloodShape: String, Codable, CaseIterable {
	case square = "Square"
	case cross = "Cross"
	case triangle = "Triangle"
	case random = "Random"
}

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
		var x = Int(r.origin.x)
		var y = Int(r.origin.y)
		var w = Int(r.size.width)
		var h = Int(r.size.height)
		
		if x < 0 {
			w += x
			x = 0
		}
		if y < 0 {
			h += y
			y = 0
		}
		x = min(x, self.w - w)
		y = min(y, self.h - h)
		w = min(w, self.w - x)
		h = min(h, self.h - y)

		guard x > -1 && x + w < self.w + 1,
			  y > -1 && y + h < self.h + 1
		else {
			print("err")
			return
		}
		
		for row in y..<y+h {
			let p = row * self.w + x
			buffer.replaceSubrange(p..<p+w, with: repeatElement(colorNumber, count: w))
		}
	}
	
	mutating func fillLine(pt1: MyPoint, pt2: MyPoint, lineWidth: Int, colorNumber: Int) -> Void {
		
		let x1: CGFloat = CGFloat(pt1.x)
		let x2: CGFloat = CGFloat(pt2.x)
		let y1: CGFloat = CGFloat(pt1.y)
		let y2: CGFloat = CGFloat(pt2.y)

		let halfLineWidth: CGFloat = CGFloat(lineWidth / 2)

		var w: CGFloat = x2 - x1
		var h: CGFloat = y2 - y1
		
		if w == 0 {
			var y = min(y1, y2)
			h = max(y1, y2) - y
			y -= halfLineWidth
			h += CGFloat(lineWidth)
			fillRect(CGRect(x: x1 - halfLineWidth, y: y, width: CGFloat(lineWidth), height: h), colorNumber: colorNumber)
			return
		}
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
		var p: CGPoint = .zero
		
		points.append(pp1)

		let lw = CGFloat(lineWidth)
		var rects: [CGRect] = []
		
		if segW == 1 {
			pp1.x -= lw * 0.5
			for _ in 0..<Int(steps) {
				var r = CGRect(x: pp1.x, y: pp1.y, width: lw, height: ceil(segH))
				self.fillRect(r, colorNumber: colorNumber)
				pp1.x += xDir
				pp1.y += segH * yDir
			}
		} else {
			pp1.y -= lw * 0.5
			for _ in 0..<Int(steps) {
				var r = CGRect(x: pp1.x, y: pp1.y, width: ceil(segW), height: lw)
				self.fillRect(r, colorNumber: colorNumber)
				pp1.x += segW * xDir
				pp1.y += yDir
			}
		}
		
		return()
		
		for _ in 0..<Int(steps) {
			pp1.x += segW == 1 ? 0 : segW * xDir
			pp1.y += segH == 1 ? 0 : segH * yDir
			p = pp1
			p.x = xDir == 1 ? floor(p.x) : ceil(p.x)
			p.y = yDir == 1 ? floor(p.y) : ceil(p.y)
			points.append(p)
			pp1.x += segW == 1 ? segW * xDir : 0
			pp1.y += segH == 1 ? segH * yDir : 0
			p = pp1
//			p.x = xDir == 1 ? floor(p.x) : ceil(p.x)
//			p.y = yDir == 1 ? floor(p.y) : ceil(p.y)
			p.x = xDir == 1 ? ceil(p.x) : floor(p.x)
			p.y = yDir == 1 ? ceil(p.y) : floor(p.y)
			points.append(p)
		}
		
		points.removeLast()
		
		var r: CGRect = .zero

		
		if segW == 1 {
			for i in stride(from: 0, to: points.count, by: 2) {
				let x = points[i].x - halfLineWidth
				let w = CGFloat(lineWidth)
				let y = points[i].y
				let h = points[i + 1].y * yDir - points[i].y * yDir
				self.fillRect(CGRect(x: x, y: y, width: w, height: h), colorNumber: colorNumber)
			}
		} else {
			for i in stride(from: 0, to: points.count, by: 2) {
				let y = points[i].y - halfLineWidth
				let h = CGFloat(lineWidth)
				let x = points[i].x
				let w = points[i + 1].x * xDir - points[i].x * xDir
				self.fillRect(CGRect(x: x, y: y, width: w, height: h), colorNumber: colorNumber)
			}
		}
		
		return()
		
		var rW: CGFloat = 0
		var rH: CGFloat = 0
		
		var xStep: CGFloat = CGFloat(w) / CGFloat(lineWidth)
		var yStep: CGFloat = CGFloat(h) / CGFloat(lineWidth)
		
		let n: Int = Int(min(abs(xStep), abs(yStep))) + 1
		
		if abs(w) > abs(h) {
			rW = abs(w / min(abs(xStep), abs(yStep)))
			rH = CGFloat(lineWidth)
		} else {
			rH = abs(h / min(abs(xStep), abs(yStep)))
			rW = CGFloat(lineWidth)
		}

		xStep = w / CGFloat(n)
		yStep = h / CGFloat(n)

		r = CGRect(x: CGFloat(x1), y: CGFloat(y1), width: rW, height: rH)
		for _ in 0..<n {
			self.fillRect(r, colorNumber: colorNumber)
			r.origin.x += CGFloat(xStep)
			r.origin.y += CGFloat(yStep)
		}

	}
}

class TmpView: UIView {
	
	let shape = CAShapeLayer()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	func commonInit() {
		backgroundColor = .yellow
		layer.addSublayer(shape)
		shape.lineWidth = 1
		shape.strokeColor = UIColor.white.cgColor
		shape.fillColor = UIColor.clear.cgColor
	}
	override func layoutSubviews() {
		super.layoutSubviews()

		var pt1: CGPoint = CGPoint(x: 124, y: 21)
		var pt2: CGPoint = CGPoint(x: 25, y: 231)

		var w: CGFloat = pt2.x - pt1.x
		var h: CGFloat = pt2.y - pt1.y
		
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
			steps = w / segW
			segH = 1
		} else {
			w += 1
			segH = h / w
			steps = h / segH
			segW = 1
		}
		
		var points: [CGPoint] = []
		var p: CGPoint = .zero

		points.append(pt1)

		for _ in 0..<Int(steps) {
			pt1.x += segW == 1 ? 0 : segW * xDir
			pt1.y += segH == 1 ? 0 : segH * yDir
			//p = CGPoint(x: ceil(pt1.x), y: ceil(pt1.y))
			p = CGPoint(x: CGFloat(Int(pt1.x)), y: CGFloat(Int(pt1.y)))
			points.append(p)
			pt1.x += segW == 1 ? segW * xDir : 0
			pt1.y += segH == 1 ? segH * yDir : 0
			//p = CGPoint(x: ceil(pt1.x), y: ceil(pt1.y))
			p = CGPoint(x: CGFloat(Int(pt1.x)), y: CGFloat(Int(pt1.y)))
			points.append(p)
		}
		
		points.removeLast()

		let pth = UIBezierPath()

		for i in stride(from: 0, to: points.count, by: 2) {
			pth.move(to: points[i])
			pth.addLine(to: points[i + 1])
		}
		
		shape.path = pth.cgPath
		
	}
	
}

class FloodView: UIView {
	
	public var floodShape: FloodShape = .square {
		didSet {
			guard bounds.width > 10 else { return }
			switch floodShape {
			case .square:
				setupSquare()
				()
			case .cross:
				setupCross()
				()
			case .triangle:
				setupTriangle()
				()
			case .random:
				setupRandom()
				()
			}
			setNeedsDisplay()
		}
	}
	
	public var newColor: Int = 0 {
		didSet {
			newColor = min(colors.count - 1, newColor)
		}
	}
	
	public var colors: [UIColor] = [
		.red, .blue,
	]
	
	override var bounds: CGRect {
		didSet {
			screenBuffer.w = Int(bounds.width)
			screenBuffer.h = Int(bounds.height)
			if screenBuffer.count() != screenBuffer.length() {
				let t = self.floodShape
				self.floodShape = t
			}
		}
	}
	
	private var screenBuffer: MyBuffer = MyBuffer()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	func commonInit() {
		let t = UITapGestureRecognizer(target: self, action: #selector(cellTap(_:)))
		addGestureRecognizer(t)
	}
	
	@objc func cellTap(_ g: UITapGestureRecognizer) {
		
		let pt = g.location(in: self)
		
		let r: Int = Int(pt.y)
		let c: Int = Int(pt.x)
		
		let oldColor: Int = screenBuffer.buffer[r * screenBuffer.w + c]
		
		let st = CFAbsoluteTimeGetCurrent()
		
		let bChanged = floodFillScanlineStack(x: c, y: r, newColor: newColor, oldColor: oldColor, h: screenBuffer.h, w: screenBuffer.w)
		
		let elapsed = CFAbsoluteTimeGetCurrent() - st
		
		let nf = NumberFormatter()
		nf.maximumFractionDigits = 8
		
		//let str = "\(bChanged) :- bufSize: \(screenBuffer.count) :- Elapsed Time: " + nf.string(from: NSNumber(value: elapsed))! + " seconds"
		let str = "Elapsed Time: " + nf.string(from: NSNumber(value: elapsed))! + " seconds"
		print(str)
		
		if bChanged {
			setNeedsDisplay()
		}
		
	}
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		
		if screenBuffer.count() > 0 {
			
			guard let context = UIGraphicsGetCurrentContext() else { return }
			
			for r in 0..<screenBuffer.h {
				for c in 0..<screenBuffer.w {
					colors[screenBuffer.buffer[r * screenBuffer.w + c]].setFill()
					context.fill(CGRect(x: c, y: r, width: 1, height: 1))
				}
			}
			
		}
		
	}
	
}

// MARK: Algorithm
extension FloodView {
	
	func floodFillScanlineStack(x: Int, y: Int,
								newColor: Int, oldColor: Int,
								h: Int, w: Int) -> Bool
	{
		
		assert(x < w, "p.x \(x) out of range, must be < \(w)")
		assert(y < h, "p.y \(y) out of range, must be < \(h)")
		
		if oldColor == newColor {
			print("old == new")
			return false
		}
		
		var spanAbove = false
		var spanBelow = false
		
		var x1: Int = 0
		
		var stack : [(Int, Int)] = [(x, y)] // 0 is X, 1 is Y
		
		while let pp = stack.popLast() {
			
			x1 = pp.0
			let y = pp.1
			
			while(x1 >= 0 && screenBuffer.buffer[y * w + x1] == oldColor) {
				x1 -= 1
			}
			x1 += 1
			
			spanAbove = false
			spanBelow = false
			
			while(x1 < w && screenBuffer.buffer[y * w + x1] == oldColor) {
				screenBuffer.buffer[y * w + x1] = newColor;
				
				if(!spanAbove && y > 0 && screenBuffer.buffer[(y - 1) * w + x1] == oldColor) {
					stack.append((x1, y - 1))
					spanAbove = true
				}
				else if(spanAbove && y > 0 && screenBuffer.buffer[(y - 1) * w + x1] != oldColor) {
					spanAbove = false
				}
				if(!spanBelow && y < h - 1 && screenBuffer.buffer[(y + 1) * w + x1] == oldColor) {
					stack.append((x1, y + 1))
					spanBelow = true
				}
				else if(spanBelow && y < h - 1 && screenBuffer.buffer[(y + 1) * w + x1] != oldColor) {
					spanBelow = false
				}
				x1 += 1
			}
		}
		
		return true
	}
	
}

struct MyPoint {
	var x: Int = 0
	var y: Int = 0
}

// MARK: Shapes
extension FloodView {
	
	@objc func xsetupSquare() {
		
		// init array to all Zeroes
		screenBuffer.buffer = Array(repeating: 0, count: screenBuffer.length())
		
		let row1: Int = 2
		let row2: Int = screenBuffer.h - (row1 + 1)
		let col1: Int = 2
		let col2: Int = screenBuffer.w - (col1 + 1)
		
		for r in row1...row2 {
			for c in col1...col2 {
				let p = r * screenBuffer.w + c
				screenBuffer.buffer[p] = 1
			}
		}
		
	}
	
	@objc func setupSquare() {
		
		// clear with color 0
		screenBuffer.clear(with: 0)
		
		var r: CGRect = CGRect(origin: .zero, size: CGSize(width: screenBuffer.w, height: screenBuffer.h))
		let w: CGFloat = floor(Double(screenBuffer.w) * 0.1)
		
		r = r.insetBy(dx: w, dy: w)
		screenBuffer.fillRect(r, colorNumber: 1)
		
		r = r.insetBy(dx: w, dy: w)
		screenBuffer.fillRect(r, colorNumber: 0)
		
	}
	

	@objc func setupCross() {

		// clear with color 0
		screenBuffer.clear(with: 0)
		
		let r: CGRect = CGRect(origin: .zero, size: CGSize(width: screenBuffer.w, height: screenBuffer.h))

		let w: CGFloat = floor(Double(screenBuffer.w) * 0.45)
		let h: CGFloat = floor(Double(screenBuffer.h) * 0.1)

		screenBuffer.fillRect(r.insetBy(dx: w, dy: h), colorNumber: 1)
		screenBuffer.fillRect(r.insetBy(dx: h, dy: w), colorNumber: 1)

	}
	
	@objc func setupTriangle() {

		// clear with color 0
		screenBuffer.clear(with: 0)

		let lineW: Int = Int(floor(Double(screenBuffer.w) * 0.05))
		let top: Int = Int(floor(Double(screenBuffer.h) * 0.1)) - lineW / 2
		let bot: Int = screenBuffer.h - top - lineW
		let left: Int = Int(floor(Double(screenBuffer.w) * 0.1))
		let right: Int = screenBuffer.w - left
		
		var pt1 = MyPoint(x: screenBuffer.w / 2, y: top)
		var pt2 = MyPoint(x: left, y: bot)

		screenBuffer.fillLine(pt1: pt1, pt2: pt2, lineWidth: lineW, colorNumber: 1)
		
		pt2.x = right
		
		screenBuffer.fillLine(pt1: pt1, pt2: pt2, lineWidth: lineW, colorNumber: 1)
		
		pt1 = MyPoint(x: left, y: bot)
		pt2 = MyPoint(x: right, y: bot)
		
		screenBuffer.fillLine(pt1: pt1, pt2: pt2, lineWidth: lineW, colorNumber: 1)
		
	}
	
	@objc func setupRandom() {
		
		// clear with last color
		screenBuffer.clear(with: colors.count - 1)

//		let x1 = 100
//		let y1 = 100
//		let x2 = 190
//		let y2 = 102
//
//		screenBuffer.fillLine(pt1: MyPoint(x: x1, y: y1), pt2: MyPoint(x: x2, y: y2), lineWidth: 8, colorNumber: 0)
//
//		return
		

		let sizes: [Int] = [
			Int(bounds.width * 0.25),
			Int(bounds.width * 0.20),
			Int(bounds.width * 0.15),
		]
		
		// don't use ;ast color
		let m = colors.count - 1
		for i in 1...30 {
			let x = Int.random(in: 0...Int(bounds.width - 10))
			let y = Int.random(in: 0...Int(bounds.height - 10))
			let z = CGFloat(sizes[i % sizes.count])
			screenBuffer.fillRect(CGRect(x: CGFloat(x), y: CGFloat(y), width: z, height: z), colorNumber: i % m)
		}
		
//		let x1 = 100
//		let y1 = 100
//		let x2 = 190
//		let y2 = 102
//
//		screenBuffer.fillLine(pt1: MyPoint(x: x1, y: y1), pt2: MyPoint(x: x2, y: y2), lineWidth: 8, colorNumber: colors.count - 1)
//
//		return
		
		for i in 1...10 {
			let x1 = Int.random(in: 0...Int(bounds.width - 10))
			let y1 = Int.random(in: 0...Int(bounds.height - 10))
			let x2 = Int.random(in: 0...Int(bounds.width - 10))
			let y2 = Int.random(in: 0...Int(bounds.height - 10))
			screenBuffer.fillLine(pt1: MyPoint(x: x1, y: y1), pt2: MyPoint(x: x2, y: y2), lineWidth: 8, colorNumber: i % m)
		}
		
	}
	
}
