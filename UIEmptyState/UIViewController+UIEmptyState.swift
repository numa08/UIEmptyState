//
//  UIViewController+UIEmptyState
//  UIEmptyState
//
//  Created by Luis Padron on 1/31/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

/// Extension on UIViewController which adds method and computed properties in order to allow empty view creation
extension UIViewController {
    /// Private struct of keys to be used with objective-c associated objects
    private struct Keys {
        static var emptyStateView = "com.luispadron.emptyStateView"
        static var emptyStateDataSource = "com.luispadron.emptyStateDataSource"
        static var emptyStateDelegate = "com.luispadron.emptyStateDelegate"
    }
    
    /// The data source for the Empty View
    ///
    /// Default conformance for UIViewController is provided,
    /// however feel free to implement these methods to customize your view.
    public weak var emptyStateDataSource: UIEmptyStateDataSource? {
        get { return objc_getAssociatedObject(self, &Keys.emptyStateDataSource)  as? UIEmptyStateDataSource }
        set { objc_setAssociatedObject(self, &Keys.emptyStateDataSource, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    /// The delegate for UIEmptyStateView
    ///
    /// **Important:** this delegate and its functions are only used when using UIEmptyStateView.
    /// If you will provide a custom view in the UIEmptyStateDataSource you must handle how this delegate operates
    public weak var emptyStateDelegate: UIEmptyStateDelegate? {
        get { return objc_getAssociatedObject(self, &Keys.emptyStateDelegate) as? UIEmptyStateDelegate }
        set { objc_setAssociatedObject(self, &Keys.emptyStateDelegate, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    /// The empty state view associated to the ViewController
    ///
    /// **Note:** this view corresponds and is created from the UIEmptyDataSource method: `func viewForEmptyState() -> UIView`
    /// 
    /// By default this view is of type `UIEmptyStateView`
    public var emptyStateView: UIView? {
        get { return objc_getAssociatedObject(self, &Keys.emptyStateView) as? UIView }
        set {
            objc_setAssociatedObject(self, &Keys.emptyStateView, newValue, .OBJC_ASSOCIATION_RETAIN)
            // Set the views delegate
            if let view = emptyStateView as? UIEmptyStateView { view.delegate = emptyStateDelegate }
        }
    }
    
    /// The method responsible for show and hiding the `UIEmptyStateDataSource.viewForEmptyState` view
    /// 
    /// **Important:** This should be called whenever changes are made to the tableview data source or after reloading the tableview
    public func reloadEmptyState(forTableView tableView: UITableView) {
        guard let source = emptyStateDataSource, source.shouldShowEmptyStateView(forTableView: tableView) else {
            if let presentedView = emptyStateView {
                presentedView.isHidden = true
                tableView.isScrollEnabled = true
            }
            return
        }
        
        // Check whether scrolling for tableview is allowed or not
        tableView.isScrollEnabled = source.emptyStateViewAllowsScrolling()
        // Toggle or create the view if not created yet
        if let createdView = emptyStateView {
            // View was already created we can go ahead and just show it again
            createdView.isHidden = false
        } else {
            // We can create the view now
            let newView = source.viewForEmptyState()
            // Add to emptyStateView property
            emptyStateView = newView
            // Add as a subView, bring it infront of the tableView
            self.view.addSubview(newView)
            self.view.bringSubview(toFront: newView)
        }
        
    }
    
    public func reloadEmptyState(forCollectionView collectionView: UICollectionView) {
        guard let source = emptyStateDataSource else {
            return
        }
    }
    
}
