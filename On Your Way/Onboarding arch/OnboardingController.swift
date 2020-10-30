//
//  SwipingController.swift
//  autolayout_lbta
//
//  Created by Brian Voong on 10/12/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//

import UIKit

private let reuseIdentifier = "OnboardingCell"



class OnboardingController: UIViewController {
    
    
    
    
   
    
    // MARK: - Properties
    private let previousButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("PREV", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1).withAlphaComponent(0.6)
        button.setDimensions(height: 50, width: 50)
        button.layer.cornerRadius = 50 / 2
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handlePrev), for: .touchUpInside)
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("NEXT", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.setDimensions(height: 50, width: 50)
        button.layer.cornerRadius = 50 / 2
        button.backgroundColor = #colorLiteral(red: 0.1803921569, green: 0.5215686275, blue: 0.431372549, alpha: 1)
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        return button
    }()
    
    
    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = 0
        pc.numberOfPages = OnboardingViewModel.allCases.count
        pc.currentPageIndicatorTintColor = .systemGreen
        pc.pageIndicatorTintColor =  #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1).withAlphaComponent(0.3)
        return pc
    }()
    
    
    private lazy var dismissalButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Okay", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1), for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1)
        button.alpha = 0
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleDismissalView), for: .touchUpInside)
        button.setDimensions(height: 50, width: 300)
        button.layer.cornerRadius = 50 / 2
        return button
    }()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [previousButton, pageControl, nextButton])
        stackView.distribution = .fill
        return stackView
    }()
    
    
    private let blurView : UIVisualEffectView = {
        let blurView = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurView)
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(OnboardingCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureUI()
        
    }
    
    
    // MARK: - configureCollectionView
    fileprivate func configureCollectionView(){
        
        view.addSubview(blurView)
        blurView.frame = view.frame
        view.addSubview(collectionView)
        collectionView.fillSuperview()
        
    }
    
    
    // MARK: - configureCollectionView
    fileprivate func configureUI() {
        view.addSubview(stackView)
        stackView.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor,
                         right: view.rightAnchor, paddingLeft: 40, paddingBottom: 20 , paddingRight: 40)
        view.addSubview(dismissalButton)
        dismissalButton.centerX(inView: view)
        dismissalButton.anchor(bottom: pageControl.topAnchor, paddingBottom: 20)
    }
    
    
    
    // MARK: -
    fileprivate func shouldShowDismissalButton(_ show: Bool){
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.dismissalButton.alpha = show ? 1 : 0
        }
        
    }
    
    // MARK: - handlePrev
    @objc private func handlePrev() {
        let nextIndex = max(pageControl.currentPage - 1, 0)
        let indexPath = IndexPath(item: nextIndex, section: 0)
        pageControl.currentPage = nextIndex
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        (indexPath.row + 1) == OnboardingViewModel.allCases.count ? shouldShowDismissalButton( true) : shouldShowDismissalButton(false)
    }
    
    
    // MARK: - handleNext
    @objc private func handleNext() {
        let nextIndex = min(pageControl.currentPage + 1, OnboardingViewModel.allCases.count - 1)
        let indexPath = IndexPath(item: nextIndex, section: 0)
        pageControl.currentPage = nextIndex
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        // reached to the last index
        (indexPath.row + 1) == OnboardingViewModel.allCases.count ? shouldShowDismissalButton(true) : shouldShowDismissalButton(false)
    }
    
    
    // MARK: - handleDismissalView
    @objc fileprivate func handleDismissalView(){
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - Extension
extension OnboardingController:  UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return OnboardingViewModel.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! OnboardingCell
        guard let viewModel = OnboardingViewModel(rawValue: indexPath.row) else { return cell }
        cell.viewModel = viewModel
        return cell
    }
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let x = targetContentOffset.pointee.x
        pageControl.currentPage = Int(x / view.frame.width)
        Int(x / view.frame.width) + 1 == OnboardingViewModel.allCases.count ? shouldShowDismissalButton(true) : shouldShowDismissalButton(false)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
}

