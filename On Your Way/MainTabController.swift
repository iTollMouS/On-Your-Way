//
//  ViewController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/10/20.
//

import UIKit


protocol MainTabControllerDelegate: class {
    func handleClearUnread(_ tabBar: MainTabController)
}

class MainTabController: UITabBarController, UITabBarControllerDelegate {
    
    weak var delegateClearUncounted: MainTabControllerDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()
        self.delegate = self
        self.tabBar.isTranslucent = true
        self.tabBar.barStyle = .black
        
    }
    
    
    // MARK: - configureViewControllers
    func configureViewControllers(){
        
        let tripsTimelineController = TripsTimelineController()
        let tripsTimelineControllerNavBar = templateNavController(image: UIImage(systemName: "car")!,
                                                                  rootViewController: tripsTimelineController,
                                                                  tabBarItemTitle: "Travelers")
        
        let ordersController = OrdersController()
        let ordersControllerNavBar = templateNavController(image: UIImage(systemName: "shippingbox")!,
                                                           rootViewController: ordersController,
                                                           tabBarItemTitle: "Orders")
        
        let notificationsController = NotificationsController()
        let notificationsControllerNavBar = templateNavController(image: UIImage(systemName: "bell")!,
                                                                  rootViewController: notificationsController,
                                                                  tabBarItemTitle: "Notifications")
        
        let recentController = RecentController()
        recentController.delegate = self
        let recentControllerNavBar = templateNavController(image: UIImage(systemName: "envelope")!,
                                                           rootViewController: recentController,
                                                           tabBarItemTitle: "Meesage")
        
        
        let profileController = ProfileController()
        let profileControllerNavBar = templateNavController(image: UIImage(systemName: "person")!,
                                                            rootViewController: profileController,
                                                            tabBarItemTitle: "Profile")
        
        viewControllers = [tripsTimelineControllerNavBar,
                           ordersControllerNavBar, notificationsControllerNavBar,
                           recentControllerNavBar, profileControllerNavBar]
        
    }
    
    // MARK: - tabBarController as modal
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        if index == 3 {
            let recentController = RecentController()
            recentController.delegate = self
            let navController = UINavigationController(rootViewController: recentController)
            navController.tabBarController?.hidesBottomBarWhenPushed = true
            navController.modalPresentationStyle = .custom
            navController.navigationBar.barStyle = .black
            navController.navigationBar.isTranslucent = true
            present(navController, animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
    
    // MARK: - templateNavController
    func templateNavController(image: UIImage, rootViewController: UIViewController, tabBarItemTitle: String) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = image
        navController.tabBarItem.title = tabBarItemTitle
        navController.navigationBar.barStyle = .black
        navController.navigationBar.isTranslucent = true
        navController.navigationBar.prefersLargeTitles = true
        return navController
    }
    
}

extension MainTabController: RecentControllerDelegate {
    func showUnreadCount(_ recent: RecentChat, cell: RecentCell) {
        
        delegateClearUncounted?.handleClearUnread(self)
        
        guard let messageBadge = self.tabBar.items?[3] else { return  }
                DispatchQueue.main.async {
                    if recent.unreadCounter != 0 {
                        cell.counterMessageLabel.text = "\(recent.unreadCounter)"
                        messageBadge.badgeValue = "\(recent.unreadCounter)"
                        messageBadge.badgeColor = .blueLightIcon
                        cell.counterMessageLabel.isHidden = false
                    } else {
                        cell.counterMessageLabel.isHidden = true
                        messageBadge.badgeValue = ""
                        messageBadge.badgeColor = .clear
                    }
                }
    }
}
