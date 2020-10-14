//
//  ViewController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/10/20.
//

import UIKit

class MainTabController: UITabBarController, UITabBarControllerDelegate {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()
        self.delegate = self
        self.tabBar.isTranslucent = true
        self.tabBar.barStyle = .black
    }
    
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
        let recentControllerNavBar = templateNavController(image: UIImage(systemName: "envelope")!,
                                                           rootViewController: recentController,
                                                           tabBarItemTitle: "Meesage")
        
        
        let profileController = ProfileController()
        let profileControllerNavBar = templateNavController(image: UIImage(systemName: "person")!,
                                                            rootViewController: profileController,
                                                            tabBarItemTitle: "Profile")
        
        viewControllers = [tripsTimelineControllerNavBar, ordersControllerNavBar,notificationsControllerNavBar ,recentControllerNavBar, profileControllerNavBar]
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        if index == 3 {
            let recentController = RecentController()
            let navController = UINavigationController(rootViewController: recentController)
            navController.modalPresentationStyle = .fullScreen
            navController.navigationBar.barStyle = .black
            navController.navigationBar.isTranslucent = true
            present(navController, animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
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
