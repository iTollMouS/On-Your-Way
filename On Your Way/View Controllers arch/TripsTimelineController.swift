//
//  TripsTimelineController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/10/20.
//

import UIKit
import Firebase

class TripsTimelineController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        checkIfUserLoggedIn()
        configureUI()
        
    }
    
    
    func configureUI(){
        view.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        
    }
    
    func logout(){
        do {
            try Auth.auth().signOut()
            presentLoggingController()
            self.tabBarController?.selectedIndex = 0
        } catch (let error){
            print("DEBUG: error happen while logging out \(error.localizedDescription)")
        }
    }
    
    
    func checkIfUserLoggedIn(){
        Auth.auth().currentUser?.uid == nil ? presentLoggingController() : print("")
    }
    
    
    func presentLoggingController(){
        DispatchQueue.main.async { [self] in
            let loginController = LoginController()
            let nav = UINavigationController(rootViewController: loginController)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        }
    }
    
}
