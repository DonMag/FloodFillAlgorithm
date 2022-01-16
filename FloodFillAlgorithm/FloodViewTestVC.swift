//
//  FloodViewTestVC.swift
//  SW15Scratch
//
//  Created by Don Mag on 1/14/22.
//

import UIKit

class FloodViewTestVC: UIViewController {
	
	var gridWidth: Int = 128
	var gridHeight: Int = 128
	var bufLength: Int = 0
	
	var screenBuffer: [Int] = []
	
	let colors: [UIColor] = [
		.red, .green, .blue,
		.cyan, .magenta, .yellow,
		//		UIColor(red: 1.00, green: 0.60, blue: 0.60, alpha: 1.0),
		//		UIColor(red: 0.60, green: 1.00, blue: 0.60, alpha: 1.0),
		//		UIColor(red: 0.20, green: 0.85, blue: 1.00, alpha: 1.0),
		//		UIColor(red: 1.00, green: 1.00, blue: 0.60, alpha: 1.0),
		//		UIColor(red: 0.60, green: 1.00, blue: 1.00, alpha: 1.0),
		//		UIColor(red: 1.00, green: 0.60, blue: 1.00, alpha: 1.0),
	]
	
	var fvWidthConstraint: NSLayoutConstraint!
	
	let floodView = FloodView()
	
	let infoLabel: UILabel = {
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
		
		["64", "128", "256"].forEach { str in
			let v = UIButton()
			v.titleLabel?.font = .systemFont(ofSize: 13, weight: .light)
			v.setTitle(str, for: [])
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
		floodView.backgroundColor = .green
		view.addSubview(floodView)
		
		view.addSubview(infoLabel)
		
		let g = view.safeAreaLayoutGuide
		
		fvWidthConstraint = floodView.widthAnchor.constraint(equalToConstant: 256.0)
		
		NSLayoutConstraint.activate([
			
			shapeStack.topAnchor.constraint(equalTo: g.topAnchor, constant: 20.0),
			shapeStack.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 16),
			shapeStack.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -16),
			
			//floodView.widthAnchor.constraint(equalToConstant: 256.0),
			fvWidthConstraint,
			floodView.heightAnchor.constraint(equalTo: floodView.widthAnchor),
			floodView.centerXAnchor.constraint(equalTo: g.centerXAnchor),
			floodView.centerYAnchor.constraint(equalTo: g.centerYAnchor),
			
			infoLabel.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 16),
			infoLabel.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -16),
			infoLabel.bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: -20.0),
			
		])
		
		let v = TmpView()
		v.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(v)
		NSLayoutConstraint.activate([
			v.topAnchor.constraint(equalTo: floodView.topAnchor),
			v.leadingAnchor.constraint(equalTo: floodView.leadingAnchor),
			v.trailingAnchor.constraint(equalTo: floodView.trailingAnchor),
			v.bottomAnchor.constraint(equalTo: floodView.bottomAnchor),
		])
	
		// set colors array
		floodView.colors = colors
		
		// start with color 2 selected
		for i in 0..<colorStack.arrangedSubviews.count {
			colorStack.arrangedSubviews[i].layer.borderWidth = i == 2 ? 2 : 0
		}
		floodView.newColor = 2

		floodView.floodShape = .square
		
		//floodView.isHidden = true
		//v.backgroundColor = .clear
		v.isHidden = true
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
		var t: String = "64"
		if let btn = sender as? UIButton {
			t = btn.currentTitle ?? "64"
		}
		if let n = Int(t), n > 0 {
			fvWidthConstraint.constant = CGFloat(n)
		}
	}
	
	// MARK: grid setups
	@objc func newShapeTap(_ sender: Any?) {
		if let btn = sender as? UIButton,
		   let ct = btn.currentTitle,
		   let newShape = FloodShape.init(rawValue: ct)
		{
			floodView.floodShape = newShape
		}
		
	}
	
}

