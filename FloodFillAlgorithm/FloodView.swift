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
	
	@objc func setupSquare() {
		
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
	
	@objc func setupCross() {
		
		// init array to all Zeroes
		screenBuffer.buffer = Array(repeating: 0, count: screenBuffer.length())
		
		var row1: Int = 2
		var row2: Int = screenBuffer.h - (row1 + 1)
		var col1: Int = screenBuffer.w / 2 - 1
		var col2: Int = col1 + 1
		for r in row1...row2 {
			for c in col1...col2 {
				let p = r * screenBuffer.w + c
				screenBuffer.buffer[p] = 1
			}
		}
		row1 = screenBuffer.h / 2 - 1
		row2 = row1 + 1
		col1 = 2
		col2 = screenBuffer.w - (col1 + 1)
		for r in row1...row2 {
			for c in col1...col2 {
				let p = r * screenBuffer.w + c
				screenBuffer.buffer[p] = 1
			}
		}
		
	}
	
	@objc func setupTriangle() {
		
		// init array to all Zeroes
		screenBuffer.buffer = Array(repeating: 0, count: screenBuffer.length())
		
		var row: Int = 1
		
		var col1: Int = screenBuffer.w / 2 - 1
		var col2: Int = col1 + 1
		
		let p: Int = row * screenBuffer.w + col1
		screenBuffer.buffer[p] = 1
		screenBuffer.buffer[p + 1] = 1
		row += 1
		col1 -= 1
		col2 += 1
		
		while col1 > 0 {
			var p1: Int = row * screenBuffer.w + col1
			var p2: Int = row * screenBuffer.w + col2
			screenBuffer.buffer[p1] = 1
			screenBuffer.buffer[p2] = 1
			row += 1
			
			p1 = row * screenBuffer.w + col1
			p2 = row * screenBuffer.w + col2
			screenBuffer.buffer[p1] = 1
			screenBuffer.buffer[p2] = 1
			row += 1
			
			col1 -= 1
			col2 += 1
		}
		for c in col1...col2 {
			let p: Int = row * screenBuffer.w + c
			screenBuffer.buffer[p] = 1
		}
		
	}
	
	@objc func setupRandom() {
		
		// init array to all Zeroes
		screenBuffer.buffer = Array(repeating: 0, count: screenBuffer.length())
		
		// we'll fill grid with random excluding
		//	the first color, to make it easier to see
		//	the changes
		for r in 0..<screenBuffer.h {
			for c in 0..<screenBuffer.w {
				let p = r * screenBuffer.w + c
				screenBuffer.buffer[p] = Int.random(in: 1..<colors.count)
			}
		}
		
	}
	
}
