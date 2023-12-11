//
//  ViewController.swift
//  Connect4
//
//  Created by Instructor on 29/09/2023.
//

import UIKit
import Alpha0C4

class ViewController: UIViewController {
    private var gameLabel: UILabel!
    private var dropDiscButton: UIButton!
    private var indicatorView: UIActivityIndicatorView!

    private var botColor: GameSession.DiscColor = Bool.random() ? .red : .yellow
    private var isBotFirst = Bool.random()
    private var gameSession = GameSession()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        newGameSession()
    }

    private func setupUI() {
        view.backgroundColor = .white

        // Game Label
        gameLabel = UILabel()
        gameLabel.translatesAutoresizingMaskIntoConstraints = false
        gameLabel.textAlignment = .center
        gameLabel.numberOfLines = 0
        view.addSubview(gameLabel)

        // Drop Disc Button
        dropDiscButton = UIButton(type: .system)
        dropDiscButton.translatesAutoresizingMaskIntoConstraints = false
        dropDiscButton.setTitle("Drop Disc Randomly", for: .normal)
        dropDiscButton.addTarget(self, action: #selector(dropDiscAction), for: .touchUpInside)
        view.addSubview(dropDiscButton)

        // Indicator View
        indicatorView = UIActivityIndicatorView(style: .medium)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.hidesWhenStopped = true
        view.addSubview(indicatorView)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Game Label Constraints
            gameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gameLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            gameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            gameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Drop Disc Button Constraints
            dropDiscButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dropDiscButton.topAnchor.constraint(equalTo: gameLabel.bottomAnchor, constant: 20),

            // Indicator View Constraints
            indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicatorView.topAnchor.constraint(equalTo: dropDiscButton.bottomAnchor, constant: 20)
        ])
    }

    private func newGameSession() {
        botColor = Bool.random() ? .red : .yellow
        isBotFirst = Bool.random()

        print("CONNECT4 \(gameSession.boardLayout.rows) rows by \(gameSession.boardLayout.columns) columns")
        let initialMoves = [(row: 1, column: 4), (row: 2, column: 4)]
        self.gameSession.startGame(delegate: self, botPlays: botColor, first: isBotFirst, initialPositions: initialMoves)
    }

    @objc private func dropDiscAction() {
        var column: Int
        repeat { column = Int.random(in: 1...gameSession.boardLayout.columns) }
        while !gameSession.isValidMove(column)

        gameSession.dropDisc(atColumn: column)
    }
}

// MARK: - GameSessionDelegate

extension ViewController: GameSessionDelegate
{
    // GameSessionDelegate update for game state changes
    func stateChanged(_ gameSession: GameSession, state: SessionState, textLog: String) {
        // Handle state transition
        switch state
        {
        // Inital state
        case .cleared:
            gameLabel.text = textLog
            dropDiscButton.titleLabel?.text = "Drop Disc Randomly"
            
        // Player evaluating position to play
        case .busy(_):
            // Disable button while thinking
            dropDiscButton.isEnabled = false
            
        // Waiting for play action
        case .idle(let color):
            let isUserTurn = (color != botColor)
            // Enable button for user
            dropDiscButton.isEnabled = isUserTurn
            if !isUserTurn {
                // Bot play
                gameSession.dropDisc()
            }
            
        // End of game, update UI with game result, start new game
        case .ended(let outcome):
            // Disable button
            dropDiscButton.isEnabled = false
            
            // Display game result
            var gameResult: String
            switch outcome {
            case botColor:
                gameResult = "Bot (\(botColor)) wins!"
            case !botColor:
                gameResult = "User (\(!botColor)) wins!"
            default:
                gameResult = "Draw!"
            }
            gameLabel.text! = textLog + "\n" + gameResult
            
            // Wait a while and start a new session automatically
            indicatorView.startAnimating()
            Task {
                try await Task.sleep(nanoseconds: 3_000_000_000)
                await MainActor.run {
                    indicatorView.stopAnimating()
                    newGameSession()
                }
            }
        @unknown default:
            break
        }
    }
    
    
    // GameSessionDelegate notifying of the result of a player action
    // textLog provides some string visualization of the game board for debug purposes
    func didDropDisc(_ gameSession: GameSession, color: DiscColor, at location: (row: Int, column: Int), index: Int, textLog: String) {
        print("\(color) drops at \(location)")
        self.gameLabel.text = textLog
    }

        
    // GameSessionDelegate notification of end of game
    func didEnd(_ gameSession: GameSession, color: DiscColor?, winningActions: [(row: Int, column: Int)]) {
        // Display winning disc positions
        print("Winning actions: " + winningActions.map({"\($0)"}).joined(separator: " "))
    }

}
