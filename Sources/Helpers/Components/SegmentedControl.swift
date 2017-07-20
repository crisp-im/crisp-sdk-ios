//
//  SwitchButton.swift
//  Crisp
//
//  Created by Quentin de Quelen on 02/05/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

class SegmentedControl: UIControl {

    fileprivate var labels = [UILabel]()
    var thumbView = UIView()

    var items: [String] = ["Item 1", "Item 2", "Item 3"] {
        didSet {
            setupLabels()
        }
    }

    var selectedIndex = Variable<Int>(0)

    var selectedLabelColor : UIColor = .white {
        didSet {
            setSelectedColors()
        }
    }

    var unselectedLabelColor : UIColor = .crispDarkNight {
        didSet {
            setSelectedColors()
        }
    }

    var thumbColor : UIColor = sharedPreferences.color {
        didSet {
            setSelectedColors()
        }
    }

    var font : UIFont! = UIFont.systemFont(ofSize: 12) {
        didSet {
            setFont()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func setupView(){
        backgroundColor = UIColor.clear

        setupLabels()

        addIndividualItemConstraints(labels, mainView: self, padding: 0)

        insertSubview(thumbView, at: 0)
    }

    func setupLabels(){

        for label in labels {
            label.removeFromSuperview()
        }

        labels.removeAll(keepingCapacity: true)

        for index in 1...items.count {

            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 70, height: 40))
            label.text = items[index - 1]
            label.backgroundColor = UIColor.clear
            label.textAlignment = .center
            label.font = UIFont(name: "Avenir-Black", size: 15)
            label.textColor = index == 1 ? selectedLabelColor : unselectedLabelColor
            label.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(label)
            labels.append(label)
        }

        addIndividualItemConstraints(labels, mainView: self, padding: 15)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        var selectFrame = self.bounds
        let newWidth = (selectFrame.width / CGFloat(items.count)) + 20.0
        let newHeight = selectFrame.height + 20.0
        selectFrame.size.width = newWidth
        selectFrame.size.height = newHeight
        thumbView.frame = selectFrame
        thumbView.backgroundColor = thumbColor
        thumbView.layer.cornerRadius = 4
        thumbView.layer.shadowColor = UIColor.darkGray.cgColor
        thumbView.layer.shadowOffset = CGSize(width: 0, height: 1)
        thumbView.layer.shadowRadius = 2
        thumbView.layer.shadowOpacity = 0.1

        displayNewSelectedIndex()

    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {

        let location = touch.location(in: self)

        var calculatedIndex : Int?
        for item in labels {
            if item.frame.contains(location) {
                calculatedIndex = labels.index(of: item)
            }
        }


        if calculatedIndex != nil {
            selectedIndex.value = calculatedIndex!
            sendActions(for: .valueChanged)
            displayNewSelectedIndex()
        }

        return false
    }

    func displayNewSelectedIndex(){
        for item in labels {
            item.textColor = unselectedLabelColor
        }

        let label = labels[selectedIndex.value]
        label.textColor = selectedLabelColor

        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: [], animations: {
            self.thumbView.frame = CGRect(x: label.frame.minX - 5, y: label.frame.minY - 5, width: label.frame.width + 10, height: label.frame.height + 10)
        }, completion: nil)
    }

    func addIndividualItemConstraints(_ items: [UIView], mainView: UIView, padding: CGFloat) {

        for button in items {

            let index = items.index(of: button)

            let topConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: mainView, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0)

            let bottomConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: mainView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0)

            var rightConstraint : NSLayoutConstraint!

            if index == items.count - 1 {

                rightConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: mainView, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: -padding)

            } else {

                let nextButton = items[index!+1]
                rightConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: nextButton, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: -padding)
            }


            var leftConstraint : NSLayoutConstraint!

            if index == 0 {

                leftConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: mainView, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: padding)

            } else {

                let prevButton = items[index!-1]
                leftConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: prevButton, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: padding)

                let firstItem = items[0]

                let widthConstraint = NSLayoutConstraint(item: button, attribute: .width, relatedBy: NSLayoutRelation.equal, toItem: firstItem, attribute: .width, multiplier: 1.0  , constant: 0)

                mainView.addConstraint(widthConstraint)
            }

            mainView.addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
        }
    }

    func setSelectedColors(){
        for item in labels {
            item.textColor = unselectedLabelColor
        }

        if labels.count > 0 {
            labels[0].textColor = selectedLabelColor
        }

        thumbView.backgroundColor = thumbColor
    }

    func setFont(){
        for item in labels {
            item.font = font
        }
    }
}
