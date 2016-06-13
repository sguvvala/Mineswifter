//
//  Square.swift
//  Minesweeper
//
//  Created by Sruthi Guvvala on 4/12/16.
//  Copyright © 2016 Sruthi Guvvala. All rights reserved.
//

import Foundation

//------------------------------------------------------------------------------
// Defining each tile
//------------------------------------------------------------------------------

class Square
{
    let row:Int
    let col:Int
    // give these default values that we will re-assign later with each new game
    var numNeighboringMines = 0
    var isMineLocation = false
    var isRevealed = false
    var isFlagged = false
    init(row:Int, col:Int)
    {
        //store the row and column of the square in the grid
        self.row = row
        self.col = col
    }
}