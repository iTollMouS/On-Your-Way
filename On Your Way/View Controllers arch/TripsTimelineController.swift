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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureTapBarController()
    }
    
    
    func configureTapBarController(){
        let newTripController = NewTripController()
        newTripController.delegate = self
        newTripController.popupItem.title = "Design your trip"
        newTripController.popupBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        newTripController.popupItem.subtitle = "show people what packages you can take"
        newTripController.popupItem.progress = 0.34
        tabBarController?.popupBar.titleTextAttributes = [ .foregroundColor: UIColor.white ]
        tabBarController?.popupBar.subtitleTextAttributes = [ .foregroundColor: UIColor.gray ]
        tabBarController?.presentPopupBar(withContentViewController: newTripController, animated: true, completion: nil)
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

extension TripsTimelineController: NewTripControllerDelegate {
    func dismissNewTripView(_ view: NewTripController) {
        tabBarController?.closePopup(animated: true, completion: { [self] in
            let safetyControllerGuidelines = SafetyControllerGuidelines()
            safetyControllerGuidelines.modalPresentationStyle = .custom
            present(safetyControllerGuidelines, animated: true, completion: nil)
        })
    }
}
