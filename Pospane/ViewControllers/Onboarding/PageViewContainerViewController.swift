//
//  PageViewContainerViewController.swift
//  Pospane
//
//  Created by Karol Stępień on 25.03.2018.
//  Copyright © 2018 Carste IT. All rights reserved.
//

import UIKit

class PageViewContainerViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

//    @IBOutlet weak var pageControl: FXPageControl!
    var pageContainer: UIPageViewController!
    var pages = [UIViewController]()
    var currentIndex: Int?
    private var pendingIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let storyboard = UIStoryboard(name: StoryboardNames.Onboarding.rawValue, bundle: nil)
        pages = storyboard.instantiateViewControllersWith(identifiers: [ViewControllerStoryboardIdentifier.HealthKitOnbarding,
                                                                          ViewControllerStoryboardIdentifier.NotificationsOnboarding,
                                                                          ViewControllerStoryboardIdentifier.GetStartedOnboarding])
        pageContainer = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageContainer.delegate = self
        pageContainer.dataSource = self
        pageContainer.setViewControllers([pages.first!], direction: .forward, animated: false, completion: nil)
        
        view.addSubview(pageContainer.view)
//        view.bringSubviewToFront(pageControl)
//        pageControl.numberOfPages = pages.count
//        pageControl.currentPage = 0
//        pageControl.backgroundColor = UIColor.clearColor()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.index(of: viewController)!
        if currentIndex == 0 {
            return nil
        }
        let previousIndex = abs((currentIndex - 1) % pages.count)
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.index(of: viewController)!
        if currentIndex == pages.count - 1 {
            return nil
        }
        let nextIndex = abs((currentIndex + 1) % pages.count)
        return pages[nextIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        pendingIndex = pages.index(of: pendingViewControllers.first!)
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            currentIndex = pendingIndex
//            if let index = currentIndex {
//                pageControl.currentPage = index
//            }
        }
    }
    
}

extension UIStoryboard {
    
    func instantiateViewControllersWith(identifiers: [ViewControllerStoryboardIdentifier]) -> [UIViewController] {
        var vcs: [UIViewController] = []
        for identifier in identifiers {
            let vc = instantiateViewController(withIdentifier: identifier.rawValue)
            vcs.append(vc)
        }
        return vcs
    }
    
}

