//
//  PageView.swift
//  AnimatedPageView
//
//  Created by Alex K. on 13/04/16.
//  Copyright © 2016 Alex K. All rights reserved.
//

import UIKit

class PageView: UIView {
  
  private var itemsCount                  = 0
  private var itemRadius: CGFloat         = 0
  private var selectedItemRadius: CGFloat = 0
  private var duration: Double            = 0.7
  private var space: CGFloat              = 10// space between items
    
  var borderColor: UIColor = UIColor.whiteColor()
  var selectedBorderColor:UIColor = UIColor.whiteColor()

  // configure items set image or chage color for border view
  var configuration: ((item: PageViewItem, index: Int) -> Void)? {
    didSet {
      configurePageItems(containerView?.items)
    }
  }
  
  private var containerX: NSLayoutConstraint?
  private var containerView: PageContrainer?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
    init(frame: CGRect, itemsCount: Int, radius: CGFloat, selectedRadius: CGFloat, borderColor:UIColor, selectedBorderColor:UIColor) {
    self.itemsCount         = itemsCount
    self.itemRadius         = radius
    self.selectedItemRadius = selectedRadius
    self.borderColor = borderColor
    self.selectedBorderColor = selectedBorderColor
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
}

// MARK: public

extension PageView {
  
    class func pageViewOnView(view: UIView, itemsCount: Int, bottomConstant: CGFloat, radius: CGFloat, selectedRadius: CGFloat, borderColor:UIColor, selectedBorderColor:UIColor) -> PageView {
    let pageView = Init(PageView(frame: CGRect.zero, itemsCount: itemsCount, radius: radius, selectedRadius: selectedRadius, borderColor: borderColor, selectedBorderColor: selectedBorderColor)) {
      $0.translatesAutoresizingMaskIntoConstraints = false
      $0.alpha                                     = 1
    }
    view.addSubview(pageView)
    
    // add constraints 
    for (attribute, const) in [(NSLayoutAttribute.Left, 0), (NSLayoutAttribute.Right, 0), (NSLayoutAttribute.Bottom, bottomConstant)] {
      (view, pageView) >>>- {
        $0.constant  = CGFloat(const)
        $0.attribute = attribute
      }
    }
    
    pageView >>>- {
      $0.attribute = .Height
      $0.constant  = 30
    }
    
    return pageView
  }

  func currentIndex(index: Int, animated: Bool) {
    
    if 0..<itemsCount ~= index {
      containerView?.currenteIndex(index, duration: duration * 0.5, animated: animated)
      moveContainerTo(index, animated: animated, duration: duration)
    }
  }
  
  func positionItemIndex(index: Int, onView: UIView) -> CGPoint? {
    if 0..<itemsCount ~= index {
      if let currentItem = containerView?.items?[index].imageView {
        let pos = currentItem.convertPoint(currentItem.center, toView: onView)
        return pos
      }
    }
    return nil
  }
}

// MARK: life cicle

extension PageView {
  
  private func commonInit() {
    containerView = createContainerView()
    currentIndex(0, animated: false)
    self.backgroundColor = .clearColor()
  }
}

// MARK: create

extension PageView {
  
  private func createContainerView() -> PageContrainer {
    let container = Init(PageContrainer(radius: itemRadius, selectedRadius: selectedItemRadius, space: space, itemsCount: itemsCount, borderColor:self.borderColor, selectedBorderColor:self.selectedBorderColor)) {
      $0.backgroundColor                           = .clearColor()
      $0.translatesAutoresizingMaskIntoConstraints = false
    }
    self.addSubview(container)
    
    // add constraints 
    for attribute in [NSLayoutAttribute.Top, NSLayoutAttribute.Bottom] {
      (self, container) >>>- { $0.attribute = attribute }
    }
    
    containerX = (self, container) >>>- { $0.attribute = .CenterX }
    
    container >>>- {
      $0.attribute = .Width
      $0.constant  = selectedItemRadius * 2 + CGFloat(itemsCount - 1) * (itemRadius * 2) + space * CGFloat(itemsCount - 1)
    }
    
    return container
  }
  
  private func configurePageItems(items: [PageViewItem]?) {
    guard let items = items else {
      return
    }
    for index in 0..<items.count {
      configuration?(item: items[index], index: index)
    }
  }

}

// MARK: animation

extension PageView {
  
  private func moveContainerTo(index: Int, animated: Bool = true, duration: Double = 0) {
    guard let containerX = self.containerX else {
      return
    }
    
    let containerWidth  = CGFloat(itemsCount + 1) * selectedItemRadius + space * CGFloat(itemsCount - 1)
    let toValue         = containerWidth / 2.0 - selectedItemRadius - (selectedItemRadius + space) * CGFloat(index)
    containerX.constant = toValue
    
    if animated == true {
      UIView.animateWithDuration(duration,
                                 delay: 0,
                                 options: .CurveEaseInOut,
                                 animations: {
                                  self.layoutIfNeeded()
                                 },
                                 completion: nil)
    } else {
      layoutIfNeeded()
    }
  }
}
 