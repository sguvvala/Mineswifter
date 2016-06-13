//
//  ViewController.swift
//  Minesweeper
//
//  Created by Sruthi Guvvala on 4/18/16.
//  Copyright © 2016 Sruthi Guvvala. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var boardView: UIView!
    @IBOutlet weak var movesLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    let BOARD_SIZE:Int = 16
    var board:Board
    var squareButtons:[SquareButton] = []
    var countCells: Int = 0
    var minescount : Int = 0
    var minesRow = [Int]()
    var minesCol:[Int] = []
    let tapSingle = UITapGestureRecognizer()
    let tapDouble = UITapGestureRecognizer()
    var longPress = UILongPressGestureRecognizer()
    var tapCount : Int = 0 
    var moves:Int = 0
    {
        didSet
        {
            self.movesLabel.text = "Moves: \(moves)"
            self.movesLabel.sizeToFit()
        }
    }
    var timeTaken:Int = 0
    {
        didSet
        {
            self.timeLabel.text = "Time: \(timeTaken)"
            self.timeLabel.sizeToFit()
        }
    }
    var oneSecondTimer:NSTimer?
    
    //MARK: Initialization
    
    required init?(coder aDecoder: NSCoder)
    {
        self.board = Board(size: BOARD_SIZE)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.initializeBoard()
        self.startNewGame()
        self.mineLocations()
        minescount = minesCol.count
        print("col is ",minesCol)
        print("row is ",minesRow)
        print("colcount is ",minesCol.count)
         print("rowcount is ",minesRow.count)
        print("number of mines = ", minescount)
        tapDouble.addTarget(self, action: #selector(ViewController.tapDoubleHandler(_:)))
        tapDouble.numberOfTapsRequired = 2
        longPress = UILongPressGestureRecognizer( target: self, action: #selector(ViewController.tapSingleHandler(_:)))
        longPress.minimumPressDuration = 0.09          // must hold for 1 second
        longPress.allowableMovement = 15
        boardView.addGestureRecognizer(tapDouble)
        boardView.addGestureRecognizer(longPress)
    }
    
    //------------------------------------------------------------------------------
    // Initializing the board
    //------------------------------------------------------------------------------
    
    func initializeBoard()
    {
        for row in 0 ..< board.size
        {
            for col in 0 ..< board.size
            {
                let square = board.squares[row][col]
                let squareSize:CGFloat = self.boardView.frame.width / CGFloat(BOARD_SIZE)
                let squareButton = SquareButton(squareModel: square, squareSize: squareSize);
                squareButton.setTitle("⏹", forState: .Normal)
                squareButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
                self.boardView.addSubview(squareButton)
                self.squareButtons.append(squareButton)
            }
        }
        self.view.bringSubviewToFront(self.boardView)
    }
    
    func ExecUno(loc: CGPoint)
    {
        let tile = self.boardView.frame.width / CGFloat(BOARD_SIZE)
        let tileRow = Int(loc.y / tile)
        
        let tileCol = Int(loc.x / tile)
        print("Row : \(tileRow)\t Col : \(tileCol)")
        squareButtonPressedOnce(tileRow, pointX : tileCol)
    }
    
    //------------------------------------------------------------------------------
    // Action when single tapped
    //------------------------------------------------------------------------------
    
    func squareButtonPressedOnce(pointY : Int, pointX: Int)
    {
        let check : Int = (pointX)+(pointY*16)
        if self.squareButtons[check].square.isRevealed
        {
            self.moves += 1
            print ("Tap on Revealed Sqaure")
            return
        }
        if self.squareButtons[check].square.isFlagged
        {
            self.moves += 1
            print ("Flagged Square")
            self.squareButtons[check].square.isFlagged = false
            self.squareButtons[check].setTitle("⏹", forState: .Normal)    
        }
        else
        {
            print ("Un-Flagged Square")
            self.squareButtons[check].square.isFlagged = true
            self.squareButtons[check].setTitle("🚩", forState: .Normal)
        }
    }
    
    //------------------------------------------------------------------------------
    // UITapGesture handler
    //------------------------------------------------------------------------------
    
    func tapSingleHandler(sender: UITapGestureRecognizer)
    {
        if ( sender.state == UIGestureRecognizerState.Ended )
        {
            print( "(single tap recognized)" )
            ExecUno(sender.locationInView(boardView))
        }
    }
    
    func ExecDuo(loc: CGPoint)
    {
        let tile = self.boardView.frame.width / CGFloat(BOARD_SIZE)
        let tileRow = Int(loc.y / tile)
        let tileCol = Int(loc.x / tile)
        print("Row : \(tileRow)\t Col : \(tileCol)")
        squareButtonPressedTwice(tileRow, pointX: tileCol)
    }
    
    
    //------------------------------------------------------------------------------
    // Action when double tapped
    //------------------------------------------------------------------------------
    
    func squareButtonPressedTwice(pointY : Int, pointX : Int)
    {
        let check : Int = (pointX)+(pointY*16)
        print(squareButtons.count)
        if self.squareButtons[check].square.isRevealed
        {
            self.moves += 1
            print ("Tap on Revealed Sqaure")
        }
        if !self.squareButtons[check].square.isRevealed
        {
            self.moves += 1
            self.squareButtons[check].square.isRevealed = true
            countCells += 1
            self.countRevealed()
            print ("Tap on a non - Revealed Sqaure")
            
            if self.squareButtons[check].square.isMineLocation
            {
                self.minePressed()
            }
            else
            {
                print ("Double tap on a square which is not mine")
                self.squareButtons[check].square.isRevealed = true
                self.squareButtons[check].setTitle(String(self.squareButtons[check].square.numNeighboringMines), forState: .Normal)
            }
        }
    }
    
    
    //------------------------------------------------------------------------------
    // UITapGesture handler
    //------------------------------------------------------------------------------
    
    func tapDoubleHandler(sender: UITapGestureRecognizer )
    {
        print("Double Tap")
        ExecDuo(sender.locationInView(self.boardView))
    }
    
    
    //------------------------------------------------------------------------------
    // Function to get all the locations of the mines
    //------------------------------------------------------------------------------

    func mineLocations()
    {
        
        for row in 0 ..< board.size
        {
            for col in 0 ..< board.size
            {
                let square = board.squares[row][col]
                if square.isMineLocation
                {
                    minesRow.append(square.row)
                    minesCol.append(square.col)
                }
            }
        }
    }
    
    //------------------------------------------------------------------------------
    // Function to reset the board
    //------------------------------------------------------------------------------

        func resetBoard()
        {
        // resets the board with new mine locations & sets isRevealed to false for each square
        self.board.resetBoard()
        // iterates through each button and resets the text to the default value
        for squareButton in self.squareButtons
        {
            squareButton.setTitle("⏹", forState: .Normal)
        }
    }
    
    //------------------------------------------------------------------------------
    // Starts new game
    //------------------------------------------------------------------------------

    func startNewGame()
    {
        //start new game
        self.resetBoard()
        self.timeTaken = 0
        self.moves = 0
        self.oneSecondTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ViewController.oneSecond), userInfo: nil, repeats: true)
    }
    
    func oneSecond()
    {
        self.timeTaken += 1
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Button Actions
    //------------------------------------------------------------------------------
    // New Game button
    //------------------------------------------------------------------------------

    @IBAction func newGamePressed()
    {
        print("new game")
        self.endCurrentGame()
        self.startNewGame()
    }
  
    
    func countRevealed()
    {
        let cells : Int = (board.size * board.size) - countCells
        if (minescount == cells)
        {
            print(countCells)
             self.wonGame()
        }
        
    }
    
    //------------------------------------------------------------------------------
    // To display that the player has won the game
    //------------------------------------------------------------------------------

    func wonGame()
    {
        let alertView = UIAlertView()
        alertView.addButtonWithTitle("New Game")
        alertView.title = "YAYY!!"
        alertView.message = "WINNER!!!"
        alertView.show()
        alertView.delegate = self
        
    }
    
    //------------------------------------------------------------------------------
    // Action when a mine has been pressed
    //------------------------------------------------------------------------------

    func minePressed()
    {
        for squareButton in self.squareButtons
        {
            if squareButton.square.isMineLocation
            {
                squareButton.setTitle("\(squareButton.getLabelText())", forState: .Normal)
            }
        }
        self.endCurrentGame()
               // show an alert when you tap on a mine
        let alertView = UIAlertView()
        alertView.addButtonWithTitle("New Game")
        alertView.title = "OOPS!!"
        alertView.message = "GAME LOST"
        alertView.show()
        alertView.delegate = self
    }

    
    func alertView(View: /*UIAlertController*/UIAlertView!, clickedButtonAtIndex buttonIndex: Int)
    {
        //start new game when the alert is dismissed
        self.startNewGame()
    }
    
    func endCurrentGame()
    {
        self.oneSecondTimer!.invalidate()
        self.oneSecondTimer = nil
    }
    
}






