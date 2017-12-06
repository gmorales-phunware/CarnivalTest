//
//  TurnByTurnCollectionViewCell.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/30/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit
import PWMapKit

class TurnByTurnCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var routeTitleLabel: UILabel!
    @IBOutlet weak var routeStepImageView: UIImageView!
    @IBOutlet weak var nextStepLabel: UILabel!
    @IBOutlet weak var nextStepImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
    }
    
    func configure(with step: StepInstruction) {
        routeTitleLabel.text = step.current
        routeStepImageView.image = step.directionImage
    }
    
    func configure(with step: PWRouteInstruction) {
        routeStepImageView.image = CommonSettings.imageFromDirection(direction: step.movementDirection)
        nextStepImageView.image = CommonSettings.imageFromDirection(direction: step.turnDirection)
        nextStepImageView.isHidden = step.isLastInstruction()
        routeTitleLabel.text = step.movement
        configureNextLabel(with: step)
    }
    
    func configureNextLabel(with step: PWRouteInstruction) {
        nextStepLabel.text = step.isLastInstruction() ? "" : "Next: " + step.turn
    }
}
