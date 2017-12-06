//
//  AnimatedSegmentedControl.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/24/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit

protocol Segmentable {
    func switchSegment(index: Int)
}

@IBDesignable
class AnimatedSegmentedControl: UIControl {
    var buttons = [UIButton]()
    var selector: UIView!
    var selectedSegmentIndex = 0
    
    var delegate: Segmentable?
    
    var items: [String] = ["Item 1", "Item 2"] {
        didSet {
            updateViews()
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat = 0 {
        didSet {
            updateViews()
        }
    }
    
    @IBInspectable
    var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = CGFloat(borderWidth)
        }
    }
    
    @IBInspectable
    var textColor: UIColor = .lightGray {
        didSet {
            updateViews()
        }
    }
    
    @IBInspectable
    var selectedTextColor: UIColor = .white {
        didSet {
            updateViews()
        }
    }
    
    @IBInspectable
    var selectorBackgroundColor: UIColor = .lightGray {
        didSet {
            updateViews()
        }
    }
    
    override func draw(_ rect: CGRect) {
        updateViews()
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
    }
    
    func setSelectedSegment(index: Int) {
        let selectedButton = buttons[index]
        selectedSegmentIndex = index
        onSegmentButtonTapped(button: selectedButton)
        
    }
}

fileprivate extension AnimatedSegmentedControl {
    func updateViews() {
        buttons.removeAll()
        subviews.forEach { $0.removeFromSuperview() }
        
        for title in items {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.setTitleColor(textColor, for: .normal)
            button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
            button.addTarget(self, action: #selector(onSegmentButtonTapped(button:)), for: .touchUpInside)
            buttons.append(button)
        }
        
        buttons[0].setTitleColor(selectedTextColor, for: .normal)
        
        let selectorWidth: CGFloat = frame.width / CGFloat(items.count)
        selector = UIView(frame: CGRect(x: 0, y: 0, width: selectorWidth, height: frame.height))
        selector.backgroundColor = selectorBackgroundColor
        selector.layer.cornerRadius = cornerRadius
        addSubview(selector)
        
        let sv = UIStackView(arrangedSubviews: buttons)
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fillEqually
        addSubview(sv)
        
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        sv.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        sv.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        sv.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        clipsToBounds = true
    }
    
    @objc func onSegmentButtonTapped(button: UIButton) {
        for (btnIndex, btn) in buttons.enumerated() {
            btn.setTitleColor(textColor, for: .normal)
            
            if btn == button {
                selectedSegmentIndex = btnIndex
                let startPosition:CGFloat = frame.width / CGFloat(buttons.count) * CGFloat(btnIndex)
                UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [], animations: {
                    self.selector.frame.origin.x = startPosition
                })
                btn.setTitleColor(selectedTextColor, for: .normal)
            }
        }
        sendActions(for: .valueChanged)
    }
}
