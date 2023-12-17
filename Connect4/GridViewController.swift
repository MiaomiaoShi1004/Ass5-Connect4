//
//  GridViewController.swift
//  Connect4
//
//  Created by Miaomiao Shi on 12/12/2023.
//

import UIKit

class GridView: UIView {
    let columns: Int = 6
    let rows: Int = 7

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear // Ensure background is clear to see lines and border
        self.layer.borderWidth = 3 // Set the border width
        self.layer.borderColor = UIColor.blue.cgColor // Set the border color to blue
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = .clear
        self.layer.borderWidth = 3
        self.layer.borderColor = UIColor.blue.cgColor
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.beginPath()
        context.setStrokeColor(UIColor.black.cgColor) // Set line color to black
        context.setLineWidth(1) // Set line width

        let cellWidth = rect.width / CGFloat(columns)
        let cellHeight = rect.height / CGFloat(rows)

        // Draw vertical lines
        for column in 1..<columns {
            let x = CGFloat(column) * cellWidth
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: rect.height))
        }
        
        // Draw horizontal lines
        for row in 1..<rows {
            let y = CGFloat(row) * cellHeight
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: rect.width, y: y))
        }

        context.strokePath() // Draw the lines
    }
    
    var cellSize: CGSize {
        return CGSize(width: self.bounds.width / CGFloat(columns), height: self.bounds.height / CGFloat(rows))
    }
    
}

