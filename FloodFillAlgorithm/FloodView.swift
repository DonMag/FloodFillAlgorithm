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
	var intArray: [Int] = []
	var w: CGFloat = 0
	var h: CGFloat = 0
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
	
	private var screenBuffer: [Int] = []
	private var bufWidth: Int = 0
	private var bufHeight: Int = 0
	private var bufLength: Int = 0
	
	public var newColor: Int = 0
	
	public var colors: [UIColor] = [
		.red, .blue,
	]
	
	override var bounds: CGRect {
		didSet {
			bufWidth = Int(bounds.width)
			bufHeight = Int(bounds.height)
			bufLength = bufWidth * bufHeight
			if screenBuffer.count != bufLength {
				let t = self.floodShape
				self.floodShape = t
			}
		}
	}
	
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
		
		let oldColor: Int = screenBuffer[r * bufWidth + c]
		
		let st = CFAbsoluteTimeGetCurrent()
		
		let bChanged = floodFillScanlineStack(x: c, y: r, newColor: newColor, oldColor: oldColor, h: bufHeight, w: bufWidth)
		
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
		
		if screenBuffer.count > 0 {
			
			guard let context = UIGraphicsGetCurrentContext() else { return }
			
			for r in 0..<bufHeight {
				for c in 0..<bufWidth {
					colors[screenBuffer[r * bufWidth + c]].setFill()
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
			
			while(x1 >= 0 && screenBuffer[y * w + x1] == oldColor) {
				x1 -= 1
			}
			x1 += 1
			
			spanAbove = false
			spanBelow = false
			
			while(x1 < w && screenBuffer[y * w + x1] == oldColor) {
				screenBuffer[y * w + x1] = newColor;
				
				if(!spanAbove && y > 0 && screenBuffer[(y - 1) * w + x1] == oldColor) {
					stack.append((x1, y - 1))
					spanAbove = true
				}
				else if(spanAbove && y > 0 && screenBuffer[(y - 1) * w + x1] != oldColor) {
					spanAbove = false
				}
				if(!spanBelow && y < h - 1 && screenBuffer[(y + 1) * w + x1] == oldColor) {
					stack.append((x1, y + 1))
					spanBelow = true
				}
				else if(spanBelow && y < h - 1 && screenBuffer[(y + 1) * w + x1] != oldColor) {
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
		screenBuffer = Array(repeating: 0, count: bufLength)
		
		let row1: Int = 2
		let row2: Int = bufHeight - (row1 + 1)
		let col1: Int = 2
		let col2: Int = bufWidth - (col1 + 1)
		
		for r in row1...row2 {
			for c in col1...col2 {
				let p = r * bufWidth + c
				screenBuffer[p] = 1
			}
		}
		
	}
	
	@objc func setupCross() {
		
		// init array to all Zeroes
		screenBuffer = Array(repeating: 0, count: bufLength)
		
		var row1: Int = 2
		var row2: Int = bufHeight - (row1 + 1)
		var col1: Int = bufWidth / 2 - 1
		var col2: Int = col1 + 1
		for r in row1...row2 {
			for c in col1...col2 {
				let p = r * bufWidth + c
				screenBuffer[p] = 1
			}
		}
		row1 = bufHeight / 2 - 1
		row2 = row1 + 1
		col1 = 2
		col2 = bufWidth - (col1 + 1)
		for r in row1...row2 {
			for c in col1...col2 {
				let p = r * bufWidth + c
				screenBuffer[p] = 1
			}
		}
		
	}
	
	@objc func setupTriangle() {
		
		// init array to all Zeroes
		screenBuffer = Array(repeating: 0, count: bufLength)
		
		var row: Int = 1
		
		var col1: Int = bufWidth / 2 - 1
		var col2: Int = col1 + 1
		
		let p: Int = row * bufWidth + col1
		screenBuffer[p] = 1
		screenBuffer[p + 1] = 1
		row += 1
		col1 -= 1
		col2 += 1
		
		while col1 > 0 {
			var p1: Int = row * bufWidth + col1
			var p2: Int = row * bufWidth + col2
			screenBuffer[p1] = 1
			screenBuffer[p2] = 1
			row += 1
			
			p1 = row * bufWidth + col1
			p2 = row * bufWidth + col2
			screenBuffer[p1] = 1
			screenBuffer[p2] = 1
			row += 1
			
			col1 -= 1
			col2 += 1
		}
		for c in col1...col2 {
			let p: Int = row * bufWidth + c
			screenBuffer[p] = 1
		}
		
	}
	
	@objc func setupRandom() {
		
		// init array to all Zeroes
		screenBuffer = Array(repeating: 0, count: bufLength)
		
		// we'll fill grid with random excluding
		//	the first color, to make it easier to see
		//	the changes
		for r in 0..<bufHeight {
			for c in 0..<bufWidth {
				let p = r * bufWidth + c
				screenBuffer[p] = Int.random(in: 1..<colors.count)
			}
		}
		
	}
	
}
