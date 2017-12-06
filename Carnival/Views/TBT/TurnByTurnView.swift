//
//  TurnByTurnView.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/30/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit
import PWMapKit

protocol TurnByTurnDelegate {
    func route(route: PWRoute, changeRouteInstruction instruction: PWRouteInstruction)
}

extension Notification.Name {
    static let PWRouteInstructionChangedNotificationName = Notification.Name(PWRouteInstructionChangedNotificationKey)
}

class TurnByTurnView: UIView {
    var route: PWRoute? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }
    var currentIndexPath: IndexPath!
    var delegate: TurnByTurnDelegate?
    var directions: [PWRouteInstruction]?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var contentView: UIView!
    
    fileprivate let itemWidth: CGFloat = 300
    fileprivate var itemHeight: CGFloat = 0
    fileprivate var currentIndex = 0
    
    init(withRoute route: PWRoute) {
        super.init(frame: .zero)
        self.route = route
        self.directions = route.routeInstructions as? [PWRouteInstruction]
        commonInit()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("TurnByTurnView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.register(UINib(nibName: String(describing: TurnByTurnCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: "cell")
        NotificationCenter.default.addObserver(self, selector: #selector(changeRouteInstruction(notification:)), name: Notification.Name.PWRouteInstructionChangedNotificationName, object: nil)
    }
}

extension TurnByTurnView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        itemHeight = indexPath.row == (self.route?.routeInstructions.count)! - 1 ? 56 : 90
        let itemSize = CGSize(width: collectionView.bounds.width, height: itemHeight)
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    }
}

extension TurnByTurnView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let route = route else { return 0 }
        return route.routeInstructions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let instruction = self.route?.routeInstructions?[indexPath.row] as? PWRouteInstruction
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TurnByTurnCollectionViewCell
        cell.configure(with: instruction!)
        return cell
    }
}

extension TurnByTurnView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentIndex: Int = Int(self.collectionView.contentOffset.x / self.collectionView.frame.size.width)
        updateForInstructionChange(with: currentIndex)
    }
}

extension TurnByTurnView {
    func updateForInstructionChange(with currentIndex: Int) {
        guard let count = route?.routeInstructions.count, count > currentIndex else { return }
        self.currentIndexPath = IndexPath(row: currentIndex, section: 0)
        guard let instruction = self.route?.routeInstructions[currentIndex] as? PWRouteInstruction, let route = self.route else { return }
        self.delegate?.route(route: route, changeRouteInstruction: instruction)
    }
    
    @objc func changeRouteInstruction(notification: Notification) {
        guard let routeInstruction = notification.object as? PWRouteInstruction, let route = route, let routeInstructions = route.routeInstructions as? [PWRouteInstruction], routeInstructions[self.currentIndex] != routeInstruction else {
            return
        }
        
        if let index = routeInstructions.index(of: routeInstruction) {
            let indexPath = IndexPath(row: index, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
}
