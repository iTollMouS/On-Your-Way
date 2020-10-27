//
//  ViewController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/10/20.
//

import UIKit

class MainTabController: UITabBarController, UITabBarControllerDelegate {
    
   // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()
        self.delegate = self
        self.tabBar.isTranslucent = true
        self.tabBar.barStyle = .black
        fetchRecent()
    }
 
    func fetchRecent(){
        
        DispatchQueue.main.async { [weak self] in
            RecentChatService.shared.fetchRecentChatFromFirestore { [weak self] recents in
                var value = 0
                let totalCount =  recents.compactMap{$0.unreadCounter}
                totalCount.forEach { value += $0 }
                self?.configureTabBarBadge(recentCount: value)
            }
        }
    }
    
    func configureTabBarBadge(recentCount: Int){
        DispatchQueue.main.async {
            if recentCount != 0 {
                self.tabBar.items![3].badgeValue = recentCount.toString()
                self.tabBar.items![3].badgeColor = .blueLightIcon
            } else {
                self.tabBar.items![3].badgeValue = nil
                self.tabBar.items![3].badgeColor = nil
            }
        }
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

extension MainTabController : RecentControllerDelegate {
    func handleResetUnreadCounter(_ recentUnread: Int) {
        
        configureTabBarBadge(recentCount: recentUnread)

    }
}
