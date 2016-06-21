//
//  PaperOnboarding.swift
//  AnimatedPageView
//
//  Created by Alex K. on 20/04/16.
//  Copyright © 2016 Alex K. All rights reserved.
//

import UIKit

public typealias OnboardingItemInfo = (imageName: String, title: String, description: String, iconName: String, color: UIColor, titleColor: UIColor, descriptionColor: UIColor, titleFont: UIFont, descriptionFont: UIFont)

/**
 *  The PaperOnboardingDataSource protocol is adopted by an object that mediates the application’s data model for a PaperOnboarding object.
 The data source information it needs to construct and modify a PaperOnboarding.
 */
public protocol PaperOnboardingDataSource {
  /**
   Asks the data source to return the number of items.
   
   - parameter index: An index of item in PaperOnboarding.
   
   - returns: The number of items in PaperOnboarding.
   */
  func onboardingItemsCount() -> Int
  
  /**
   Asks the data source for configureation item.
   
   - parameter index: An index of item in PaperOnboarding.
   
   - returns: configuration info for item
   */
  func onboardingItemAtIndex(index: Int) -> OnboardingItemInfo
}

/**
 *  The delegate of a PaperOnboarding object must adopt the PaperOnboardingDelegate protocol. Optional methods of the
 protocol allow the delegate to manage items, configure items, and perform other actions.
 */
public protocol PaperOnboardingDelegate {
  /**
   Tells the delegate that the paperOnbording start scrolling.
   
   - parameter index: An curretn index item
   */
  func onboardingWillTransitonToIndex(index: Int)
  
  /**
   Tells the delegate that the specified item is now selected
   
   - parameter index: An curretn index item
   */
  func onboardingDidTransitonToIndex(index: Int)
  
  /**
   Tells the delegate the PaperOnboarding is about to draw a item for a particular row. Use this method for configure items
   
   - parameter item:  A OnboardingContentViewItem object that PaperOnboarding is going to use when drawing the row.
   - parameter index: An curretn index item
   */
  func onboardingConfigurationItem(item: OnboardingContentViewItem, index: Int)
}

///An instance of PaperOnboarding which display collection of information.
public class PaperOnboarding: UIView {
  
  ///  The object that acts as the data source of the  PaperOnboardingDataSource.
  @IBOutlet public var dataSource: AnyObject? {
    didSet {
      commonInit()
    }
  }
  
  /// The object that acts as the delegate of the PaperOnboarding. PaperOnboardingDelegate protocol
  @IBOutlet public weak var delegate: AnyObject?
  
  /// current index item
  public private(set) var currentIndex: Int = 0
  var itemsCount: Int = 3
  
  private var itemsInfo: [OnboardingItemInfo]?
  
  var pageViewBottomConstant: CGFloat = 32
  var pageViewSelectedRadius: CGFloat = 22
  var pageViewRadius: CGFloat         = 8
  var pageBorderColor:UIColor     = .whiteColor()
  var pageSelectedBorderColor:UIColor = .whiteColor()
  
  private var fillAnimationView: FillAnimationView?
  private var pageView: PageView?
  private var gestureControl: GestureControl?
  private var contentView: OnboardingContentView?
  
  /**
   Initializes and returns a PaperOnboarding object with items count.
   
   - parameter itemsCount: The number of items in PaperOnboarding.
   
   - returns: Returns an initialized PaperOnboading object
   */
  public init(itemsCount: Int = 3) {
    super.init(frame: CGRect.zero)
    self.itemsCount = itemsCount
  }
    
    public init(itemCount: Int = 3, pageItemRadius:CGFloat, selectedRadius:CGFloat, pageBorderColor:UIColor = .whiteColor(), pageSelectedBorderColor:UIColor = .whiteColor()) {
        super.init(frame: CGRect.zero)
        self.pageViewRadius = pageItemRadius
        self.pageViewSelectedRadius = selectedRadius
        self.pageBorderColor = pageBorderColor
        self.pageSelectedBorderColor = pageSelectedBorderColor
        self.itemsCount = itemCount
    }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}

// MARK: methods

public extension PaperOnboarding {
  
  /**
   Scrolls through the PaperOnboarding until a index is at a particular location on the screen.
   
   - parameter index:    Scrolling to a curretn index item.
   - parameter animated: True if you want to animate the change in position; false if it should be immediate.
   */
  func currentIndex(index: Int, animated: Bool) {
    if 0 ..< itemsCount ~= index {
      (self.delegate as? PaperOnboardingDelegate)?.onboardingWillTransitonToIndex(index)
      currentIndex = index
      CATransaction.begin()
      
      
      CATransaction.setCompletionBlock({
        (self.delegate as? PaperOnboardingDelegate)?.onboardingDidTransitonToIndex(index)
      })
      
      
      if let postion = pageView?.positionItemIndex(index, onView: self) {
        fillAnimationView?.fillAnimation(bakcgroundColor(currentIndex), centerPosition: postion, duration: 0.5)
      }
      pageView?.currentIndex(index, animated: animated)
      contentView?.currentItem(index, animated: animated)
      CATransaction.commit()
    }
    
  }
}
// MARK: create

extension PaperOnboarding {
  
  private func commonInit() {
    if case let dataSource as PaperOnboardingDataSource = self.dataSource {
      itemsCount = dataSource.onboardingItemsCount()
    }
    
    itemsInfo = createItemsInfo()
    translatesAutoresizingMaskIntoConstraints = false
    fillAnimationView = FillAnimationView.animavtionViewOnView(self, color: bakcgroundColor(currentIndex))
    contentView = OnboardingContentView.contentViewOnView(self,
                                                          delegate: self,
                                                          itemsCount: itemsCount,
                                                          bottomConstant: pageViewBottomConstant * -1 - pageViewSelectedRadius)
    pageView = createPageView()
    gestureControl = GestureControl(view: self, delegate: self)
  }
  
  private func createPageView() -> PageView {
    let pageView = PageView.pageViewOnView(self,
                                           itemsCount: itemsCount,
                                           bottomConstant: pageViewBottomConstant * -1,
                                           radius:pageViewRadius,
                                           selectedRadius: pageViewSelectedRadius,
                                           borderColor: self.pageBorderColor,
                                           selectedBorderColor:  self.pageSelectedBorderColor
                                           )
    pageView.configuration = { item, index in
      if let iconName = self.itemsInfo?[index].iconName {
        item.imageView?.image = UIImage(named: iconName)
      }
    }
    return pageView
  }
  
  private func createItemsInfo() -> [OnboardingItemInfo] {
    guard case let dataSource as PaperOnboardingDataSource = self.dataSource else {
      fatalError("set dataSource")
    }
    
    var items = [OnboardingItemInfo]()
    for index in 0..<itemsCount {
      let info = dataSource.onboardingItemAtIndex(index)
      items.append(info)
    }
    return items
  }
  
}

// MARK: helpers

extension PaperOnboarding {
  
  private func bakcgroundColor(index: Int) -> UIColor {
    guard let color = itemsInfo?[index].color else {
      return .blackColor()
    }
    return color
  }
}

// MARK: GestureControlDelegate

extension PaperOnboarding: GestureControlDelegate {
  
  func gestureControlDidSwipe(direction: UISwipeGestureRecognizerDirection) {
    switch direction {
    case UISwipeGestureRecognizerDirection.Right:
      currentIndex(currentIndex - 1, animated: true)
    case UISwipeGestureRecognizerDirection.Left:
      currentIndex(currentIndex + 1, animated: true)
    default:
      fatalError()
    }
  }
}

// MARK: OnboardingDelegate

extension PaperOnboarding: OnboardingContentViewDelegate {
  
  func onboardingItemAtIndex(index: Int) -> OnboardingItemInfo? {
    return itemsInfo?[index]
  }
  
  func onboardingConfigurationItem(item: OnboardingContentViewItem, index: Int) {
    delegate?.onboardingConfigurationItem(item, index: index)
  }
  
}
