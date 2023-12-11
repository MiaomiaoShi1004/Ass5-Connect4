//
//  ViewController.swift
//  Connect4
//
//  Created by Instructor on 29/09/2023.
//

import UIKit
import Alpha0C4

class ViewController: UIViewController {
    
    // UI components declared as private variables
    private var gameLabel: UILabel!
    private var columnInputTextField: UITextField!
    private var indicatorView: UIActivityIndicatorView!
    
    // Variables to determine bot's color and whether it plays first
    private var botColor: GameSession.DiscColor = Bool.random() ? .red : .yellow
    private var isBotFirst = Bool.random()
    // Instance of the game session
    private var gameSession = GameSession()

    // Called after the view controller's view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        newGameSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showFirstPlayerSelectionAlert()
    }
    
    // Sets up UI elements programmatically
    private func setupUI() {
        
        view.backgroundColor = .white
//        backgroundColor -- purple
//        view.backgroundColor = UIColor(red: 121/255, green: 69/255, blue: 255/255, alpha: 1)


        // Game Label
        gameLabel = UILabel()
        gameLabel.translatesAutoresizingMaskIntoConstraints = false
        gameLabel.textAlignment = .center
        gameLabel.numberOfLines = 0
        view.addSubview(gameLabel)

        // Setup for the Column Input Text Field
        columnInputTextField = UITextField()
        columnInputTextField.translatesAutoresizingMaskIntoConstraints = false
        columnInputTextField.placeholder = "Enter column number"
        columnInputTextField.borderStyle = .roundedRect
        columnInputTextField.keyboardType = .numberPad
        columnInputTextField.returnKeyType = .done
        columnInputTextField.delegate = self
        view.addSubview(columnInputTextField)

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

            // Constraints for Column Input Text Field
            columnInputTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            columnInputTextField.topAnchor.constraint(equalTo: gameLabel.bottomAnchor, constant: 20),
            columnInputTextField.widthAnchor.constraint(equalToConstant: 100), // Set a suitable width
        

            // Indicator View Constraints
            indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicatorView.topAnchor.constraint(equalTo: columnInputTextField.bottomAnchor, constant: 20)
        ])
    }
    
    // Starts a new game session with random bot parameters
    private func newGameSession() {
        botColor = Bool.random() ? .red : .yellow
        
        showFirstPlayerSelectionAlert()
    }
    
    // New method to show an alert for first player selection
    private func showFirstPlayerSelectionAlert() {
        let alertController = UIAlertController(title: "Who plays first?", message: nil, preferredStyle: .alert)

        let userAction = UIAlertAction(title: "You", style: .default) { [weak self] _ in
            self?.isBotFirst = false
            self?.continueGameSetup()
        }
        alertController.addAction(userAction)

        let botAction = UIAlertAction(title: "Bot", style: .default) { [weak self] _ in
            self?.isBotFirst = true
            self?.continueGameSetup()
        }
        alertController.addAction(botAction)

        present(alertController, animated: true)
    }
    
    // New method to continue game setup after player selection
    private func continueGameSetup() {
        print("CONNECT4 \(gameSession.boardLayout.rows) rows by \(gameSession.boardLayout.columns) columns")
        let initialMoves = [(row: 1, column: 4), (row: 2, column: 4)]
        self.gameSession.startGame(delegate: self, botPlays: botColor, first: isBotFirst, initialPositions: initialMoves)
    }
    
    // Action for dropping a disc in a random column when the button is pressed
    @objc private func dropDiscAction() {
        guard let inputText = columnInputTextField.text, !inputText.isEmpty,
              let column = Int(inputText), column >= 1 && column <= gameSession.boardLayout.columns,
              gameSession.isValidMove(column) else {
            // Handle invalid input
            // You might want to show an alert or a message to the user
            return
        }

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
            columnInputTextField.placeholder = "Enter an integer"
            columnInputTextField.isEnabled = true
            
        // Player evaluating position to play
        case .busy(_):
            // Disable text field while the game is processing
            columnInputTextField.isEnabled = false
            
        // Waiting for play action
        case .idle(let color):
            let isUserTurn = (color != botColor)
            // Enable text field for user if it's their turn
            columnInputTextField.isEnabled = isUserTurn
            if !isUserTurn {
                // Bot play
                gameSession.dropDisc()
            }
            
        // End of game, update UI with game result, start new game
        case .ended(let outcome):
            // Disable text field
            columnInputTextField.isEnabled = false
            
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

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Dismiss the keyboard
        dropDiscAction() // Call the modified drop disc action
        return true
    }
}

