//
//  Extensions.swift
//  MyCarsProject
//
//  Created by Aleksandr Makarov on 07.04.2022.
//

import UIKit

extension UIButton {
   
    class func setupButton(title: String, cornerRadius: CGFloat) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = cornerRadius
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        return button
    }
}

extension UILabel {
    class func setupLabel(text: String?, fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.text = text
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.clipsToBounds = true
        return label
    }
}

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha/1)
    }
}

extension UISegmentedControl {
    static func setupSegmentedControl(items: [String]) -> UISegmentedControl {
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        sc.setWidth(90, forSegmentAt: 0)
        return sc
    }
}
