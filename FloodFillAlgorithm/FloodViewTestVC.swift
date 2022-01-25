//
//  FloodViewTestVC.swift
//  SW15Scratch
//
//  Created by Don Mag on 1/14/22.
//

import UIKit

class FloodViewTestVC: UIViewController, FloodViewDelegate {
	
	let colors: [UIColor] = [
		.systemRed, .systemGreen, .systemBlue,
		.cyan, .systemOrange, .yellow,
	]
	
	var fvWidthConstraint: NSLayoutConstraint!
	
	let floodView = FloodView()
	
	let infoLabelAlgorithm: UILabel = {
		let v = UILabel()
		v.textAlignment = .center
		v.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
		v.translatesAutoresizingMaskIntoConstraints = false
		return v
	}()
	
	let infoLabelDraw: UILabel = {
		let v = UILabel()
		v.textAlignment = .center
		v.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
		v.translatesAutoresizingMaskIntoConstraints = false
		return v
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .systemYellow
		
		// setup color selection UI
		let colorStack: UIStackView = {
			let v = UIStackView()
			v.spacing = 8
			v.distribution = .fillEqually
			v.translatesAutoresizingMaskIntoConstraints = false
			return v
		}()
		
		for i in 0..<colors.count {
			let v = UIButton()
			v.backgroundColor = colors[i]
			v.layer.borderColor = UIColor.white.cgColor
			v.layer.cornerRadius = 6
			v.addTarget(self, action: #selector(newColorTap(_:)), for: .touchUpInside)
			colorStack.addArrangedSubview(v)
		}
		
		// setup shape selection UI
		let shapeStack: UIStackView = {
			let v = UIStackView()
			v.spacing = 8
			v.distribution = .fillEqually
			v.translatesAutoresizingMaskIntoConstraints = false
			return v
		}()

		FloodShape.allCases.forEach { shp in
			let v = UIButton()
			v.titleLabel?.font = .systemFont(ofSize: 13, weight: .light)
			v.setTitle(shp.rawValue, for: [])
			v.backgroundColor = .systemBlue
			v.setTitleColor(.white, for: .normal)
			v.setTitleColor(.lightGray, for: .highlighted)
			v.layer.borderColor = UIColor.blue.cgColor
			v.layer.borderWidth = 1
			v.layer.cornerRadius = 6
			v.addTarget(self, action: #selector(newShapeTap(_:)), for: .touchUpInside)
			shapeStack.addArrangedSubview(v)
		}
		
		// setup size selection UI
		let sizeStack: UIStackView = {
			let v = UIStackView()
			v.spacing = 8
			v.distribution = .fillEqually
			v.translatesAutoresizingMaskIntoConstraints = false
			return v
		}()
		
		GridSize.allCases.forEach { str in
			let v = UIButton()
			v.titleLabel?.font = .systemFont(ofSize: 13, weight: .light)
			v.setTitle(str.rawValue, for: [])
			v.backgroundColor = .systemBlue
			v.setTitleColor(.white, for: .normal)
			v.setTitleColor(.lightGray, for: .highlighted)
			v.layer.borderColor = UIColor.blue.cgColor
			v.layer.borderWidth = 1
			v.layer.cornerRadius = 6
			v.addTarget(self, action: #selector(newSizeTap(_:)), for: .touchUpInside)
			sizeStack.addArrangedSubview(v)
		}
		
		let optionsStack: UIStackView = {
			let v = UIStackView()
			v.axis = .vertical
			v.spacing = 8
			v.translatesAutoresizingMaskIntoConstraints = false
			return v
		}()
		
		optionsStack.addArrangedSubview(shapeStack)
		optionsStack.addArrangedSubview(colorStack)
		optionsStack.addArrangedSubview(sizeStack)
		
		view.addSubview(optionsStack)
		
		floodView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(floodView)
		
		[infoLabelAlgorithm, infoLabelDraw].forEach { v in
			v.textAlignment = .center
			v.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
			v.font = .systemFont(ofSize: 13.0, weight: .light)
			v.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview(v)
		}

		let g = view.safeAreaLayoutGuide
		
		fvWidthConstraint = floodView.widthAnchor.constraint(equalToConstant: 256.0)
		
		NSLayoutConstraint.activate([
			
			shapeStack.topAnchor.constraint(equalTo: g.topAnchor, constant: 20.0),
			shapeStack.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 16),
			shapeStack.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -16),
			
			fvWidthConstraint,
			floodView.heightAnchor.constraint(equalTo: floodView.widthAnchor),
			floodView.centerXAnchor.constraint(equalTo: g.centerXAnchor),
			floodView.centerYAnchor.constraint(equalTo: g.centerYAnchor),
			
			infoLabelAlgorithm.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 16),
			infoLabelAlgorithm.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -16),
			infoLabelAlgorithm.bottomAnchor.constraint(equalTo: infoLabelDraw.topAnchor, constant: -4),
			
			infoLabelDraw.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 16),
			infoLabelDraw.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -16),
			infoLabelDraw.bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: -20.0),
			
			infoLabelDraw.heightAnchor.constraint(equalToConstant: 30.0),
			infoLabelAlgorithm.heightAnchor.constraint(equalTo: infoLabelDraw.heightAnchor),
			
		])
		
		// set colors array
		floodView.colors = colors
		
		// start with color 2 selected
		for i in 0..<colorStack.arrangedSubviews.count {
			colorStack.arrangedSubviews[i].layer.borderWidth = i == 2 ? 2 : 0
		}
		floodView.newColor = 2

		floodView.floodShape = .square
		
		floodView.delegate = self

	}
	
	@objc func newColorTap(_ sender: Any?) {
		
		guard let btn = sender as? UIButton,
			  let cStack = btn.superview as? UIStackView,
			  let vIDX = cStack.arrangedSubviews.firstIndex(of: btn)
		else { return }
		
		for i in 0..<cStack.arrangedSubviews.count {
			cStack.arrangedSubviews[i].layer.borderWidth = i == vIDX ? 2 : 0
		}
		
		floodView.newColor = vIDX
		
	}
	
	@objc func newSizeTap(_ sender: Any?) {
		if let btn = sender as? UIButton,
		   let ct = btn.currentTitle,
		   let newSize = GridSize.init(rawValue: ct)
		{
			fvWidthConstraint.constant = CGFloat(newSize.size)
		}
	}
	
	@objc func newShapeTap(_ sender: Any?) {
		if let btn = sender as? UIButton,
		   let ct = btn.currentTitle,
		   let newShape = FloodShape.init(rawValue: ct)
		{
			floodView.floodShape = newShape
		}
	}
	
	func algorithmTime(_ t: CFTimeInterval, changed: Bool) {
		let nf = NumberFormatter()
		nf.maximumFractionDigits = 8
		let str = "Flood Time: " + nf.string(from: NSNumber(value: t))! + " seconds"
		infoLabelAlgorithm.text = str
	}
	func drawTime(_ t: CFTimeInterval) {
		let nf = NumberFormatter()
		nf.maximumFractionDigits = 8
		let str = "Draw Time: " + nf.string(from: NSNumber(value: t))! + " seconds"
		infoLabelDraw.text = str
	}
}

