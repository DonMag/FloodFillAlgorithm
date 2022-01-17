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
		let pt2: CGPoint = CGPoint(x: 25, y: 231)

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
	
	@objc func xsetupTriangle() {

		// clear with color 0
		screenBuffer.clear(with: 0)

		let lineW: CGFloat = floor(Double(screenBuffer.w) * 0.05)
		let top: CGFloat = floor(Double(screenBuffer.h) * 0.1) - floor(lineW / 2)
		let bot: CGFloat = CGFloat(screenBuffer.h) - top - lineW
		let left: CGFloat = floor(Double(screenBuffer.w) * 0.1)
		let right: CGFloat = CGFloat(screenBuffer.w) - left
		
		var pt1 = CGPoint(x: floor(Double(screenBuffer.w) / 2), y: top)
		var pt2 = CGPoint(x: left, y: bot)

		screenBuffer.fillLine(pt1: pt1, pt2: pt2, lineWidth: Int(lineW), colorNumber: 1)
		
		pt2.x = right
		
		screenBuffer.fillLine(pt1: pt1, pt2: pt2, lineWidth: Int(lineW), colorNumber: 1)
		
		pt1 = CGPoint(x: left, y: bot)
		pt2 = CGPoint(x: right, y: bot)
		
		screenBuffer.fillLine(pt1: pt1, pt2: pt2, lineWidth: Int(lineW), colorNumber: 1)
		
	}

	@objc func setupTriangle() {
		
		// clear with color 0
		screenBuffer.clear(with: 0)
		
		let lineW: CGFloat = floor(Double(screenBuffer.w) * 0.05)
		
		
		
		let top: CGFloat = floor(Double(screenBuffer.h) * 0.1) - floor(lineW / 2)
		let bot: CGFloat = CGFloat(screenBuffer.h) - top - lineW
		let left: CGFloat = floor(Double(screenBuffer.w) * 0.1)
		let right: CGFloat = CGFloat(screenBuffer.w) - left
		
		var pt1 = CGPoint(x: floor(Double(screenBuffer.w) / 2), y: top)
		var pt2 = CGPoint(x: left, y: bot)
		
		screenBuffer.fillLine(pt1: pt1, pt2: pt2, lineWidth: Int(lineW), colorNumber: 1)
		
		pt2.x = right
		
		screenBuffer.fillLine(pt1: pt1, pt2: pt2, lineWidth: Int(lineW), colorNumber: 1)
		
		pt1 = CGPoint(x: left, y: bot)
		pt2 = CGPoint(x: right, y: bot)
		
		screenBuffer.fillLine(pt1: pt1, pt2: pt2, lineWidth: Int(lineW), colorNumber: 1)
		
	}

	@objc func setupRandom() {
		
		// clear with last color
		screenBuffer.clear(with: colors.count - 1)

		let sizes: [Int] = [
			Int(bounds.width * 0.25),
			Int(bounds.width * 0.20),
			Int(bounds.width * 0.15),
		]
		
		// don't use last color
		let m = colors.count - 1
		for i in 0..<m*3 {
			let x = CGFloat(Int.random(in: 0...Int(bounds.width - 10)))
			let y = CGFloat(Int.random(in: 0...Int(bounds.height - 10)))
			let z = CGFloat(sizes[i % sizes.count])
			screenBuffer.fillRect(CGRect(x: x, y: y, width: z, height: z), colorNumber: i % m)
		}
		
		for i in 1...10 {
			let x1 = CGFloat(Int.random(in: 0...Int(bounds.width - 10)))
			let y1 = CGFloat(Int.random(in: 0...Int(bounds.height - 10)))
			let x2 = CGFloat(Int.random(in: 0...Int(bounds.width - 10)))
			let y2 = CGFloat(Int.random(in: 0...Int(bounds.height - 10)))
			screenBuffer.fillLine(pt1: CGPoint(x: x1, y: y1), pt2: CGPoint(x: x2, y: y2), lineWidth: 8, colorNumber: i % m)
		}
		
	}
	
}
