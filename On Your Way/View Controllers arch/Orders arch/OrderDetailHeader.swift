//
//  OrderDetailHeader.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/13/20.
//

import UIKit


private let reuseIdentifier = "PetAdoptionProfileHeaderCell"

class OrderDetailHeader: UIView {
    
    private var package: Package
    private lazy var viewModel = PackageViewModel(package: package)
    
    private lazy var collectionView: UICollectionView = {
        let collectionViewFrame = CGRect(x: 0, y: 0, width: frame.width , height: frame.height)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = true
        collectionView.register(OrderDetailHeaderCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        return collectionView
    }()
    
    
    init(package: Package) {
        self.package = package
        super.init(frame: .zero)
        addSubview(collectionView)
        collectionView.fillSuperview()
    
    }
 
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension OrderDetailHeader: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return package.packageImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! OrderDetailHeaderCell
        cell.imageView.sd_setImage(with: viewModel.packageImages[indexPath.row])
        return cell
    }
    
}

extension OrderDetailHeader: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width, height: frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
