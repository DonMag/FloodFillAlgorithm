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
	case spiral = "Spiral"
	case random = "Random"
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
			case .spiral:
				setupSpiral()
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

	@objc func setupSpiral() {
		
		// clear with color 0
		screenBuffer.clear(with: 0)
		
		let lineW: CGFloat = floor(Double(screenBuffer.w) * 0.05)
		
		let spSize: Int = 8
		let spLw: CGFloat = floor(bounds.width / CGFloat(spSize))
		let pts: [CGPoint] = buildSpiral(sz: spSize)
		
		var pt1: CGPoint = .zero
		var pt2: CGPoint = .zero

		pt1 = pts[0].multipliedBy(dx: spLw, dy: spLw).offsetBy(dx: lineW, dy: lineW)
		for i in 1..<pts.count {
			pt2 = pts[i].multipliedBy(dx: spLw, dy: spLw).offsetBy(dx: lineW, dy: lineW)
			screenBuffer.fillLine(pt1: pt1, pt2: pt2, lineWidth: Int(lineW), colorNumber: 1)
			pt1 = pt2
		}
		
	}

	@objc func setupRandom() {
		
		// clear with last color
		screenBuffer.clear(with: colors.count - 1)

		let sizes: [Int] = [
			Int(bounds.width * 0.25),
			Int(bounds.width * 0.20),
			Int(bounds.width * 0.15),
		]

		var newVals: [Int] = [
			0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0,
			0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0,
			2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
			2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
			2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
			2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
			0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0,
			0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0,
		]
		screenBuffer.replaceRectWithAlpha(CGRect(x: 0, y: 0, width: 12, height: 8), with: newVals, alpha: 0)

		screenBuffer.replaceRectWithAlpha(CGRect(x: 100, y: 100, width: 12, height: 8), with: newVals, alpha: nil)

		return()
		
		newVals = [
			2, 2, 3, 3, 3, 4, 4,
			2, 2, 3, 3, 3, 4, 4,
			2, 2, 5, 5, 5, 4, 4,
			2, 2, 3, 3, 3, 4, 4,
			2, 2, 3, 3, 3, 4, 4,
		]
		
		screenBuffer.replaceRectWithAlpha(CGRect(x: 0, y: 0, width: 7, height: 5), with: newVals, alpha: nil)
		
		return()
		
		var x: CGFloat = 0
		var y: CGFloat = 0
		var w: CGFloat = 1
		var h: CGFloat = 1
		w = 1
		h = 100
		screenBuffer.fillRect(CGRect(x: x, y: y, width: w, height: h), colorNumber: 1)
		return()
		
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
	
	func buildSpiral(sz: Int) -> [CGPoint] {
		
		enum MoveDir: Int {
			case r, l, d, u
		}
		
		var points: [CGPoint] = []
		
		var row: Int = 0
		var col: Int = 0
		var boundary: Int = sz - 1
		var sizeLeft: Int = sz - 1
		var bFlag: Bool = false
		
		var move: MoveDir = .r
		
		for i in 1...(sz * sz) {
			switch move {
			case .r:
				col += 1
				
			case .l:
				col -= 1
				
			case .u:
				row -= 1
				
			case .d:
				row += 1
			}
			
			if i == boundary {
				let p = CGPoint(x: col, y: row)
				points.append(p)
				
				boundary += sizeLeft

				if !bFlag {
					bFlag = true
				} else {
					bFlag = false
					sizeLeft -= 1
				}
				
				switch move {
				case .r:
					move = .d
					
				case .l:
					move = .u
					
				case .u:
					move = .r
					
				case .d:
					move = .l
				}
				
			}
		}
		
		return points
	}
	
}

extension CGPoint {
	func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
		return CGPoint(x: x + dx, y: y + dy)
	}
	func multipliedBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
		return CGPoint(x: x * dx, y: y * dy)
	}
}
