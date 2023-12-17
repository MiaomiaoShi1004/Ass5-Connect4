//
//  BubbleViewController.swift
//  Connect4
//
//  Created by Miaomiao Shi on 12/12/2023.
//

import UIKit

class BubbleView: UIView {
    // Initialize the bubble view with a specific frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .red
        self.layer.cornerRadius = frame.size.width / 2.0
        self.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
