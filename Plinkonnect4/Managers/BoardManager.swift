//
//  BoardManager.swift
//  Plinkonnect4
//
//  Created by Sarju Thakkar on 4/25/25.
//

import SpriteKit

class BoardManager {
    enum Player {
        case red, yellow
    }

    var gameGrid: [[Player?]] = Array(repeating: Array(repeating: nil, count: 6), count: 7)

    func finalizeBallPositions(in scene: SKScene, columnWidth: CGFloat) {
        gameGrid = Array(repeating: Array(repeating: nil, count: 6), count: 7)

        for node in scene.children where node is BallNode {
            guard let body = node.physicsBody else { continue }
            let position = node.position

            let boardHeight = columnWidth * 6 * 0.8
            guard position.y <= boardHeight else { continue }

            let column = Int(position.x / columnWidth)
            let row = gameGrid[column].firstIndex(where: { $0 == nil }) ?? -1
            guard row >= 0 && column >= 0 && column < gameGrid.count && row < gameGrid[column].count else { continue }

            let player: Player = (node is BallNode && (node as! BallNode).fillColor == .red) ? .red : .yellow
            gameGrid[column][row] = player
        }
    }

    func checkForWin(showMessage: (String) -> Void) -> Bool {
        var redWins = false
        var yellowWins = false

        for col in 0..<gameGrid.count {
            for row in 0..<gameGrid[col].count {
                guard let player = gameGrid[col][row] else { continue }

                if checkDirection(player: player, col: col, row: row, deltaCol: 1, deltaRow: 0) ||
                   checkDirection(player: player, col: col, row: row, deltaCol: 0, deltaRow: 1) ||
                   checkDirection(player: player, col: col, row: row, deltaCol: 1, deltaRow: 1) ||
                   checkDirection(player: player, col: col, row: row, deltaCol: 1, deltaRow: -1) {
                    if player == .red {
                        redWins = true
                    } else {
                        yellowWins = true
                    }
                }
            }
        }

        if redWins && yellowWins {
            showMessage("🤝 You both win!")
            return true
        } else if redWins {
            showMessage("🎉 Red wins!")
            return true
        } else if yellowWins {
            showMessage("🎉 Yellow wins!")
            return true
        }

        let isTie = gameGrid.allSatisfy { column in
            column.allSatisfy { $0 != nil }
        }

        if isTie {
            showMessage("😐 It's a tie!")
            return true
        }

        return false
    }

    private func checkDirection(player: Player, col: Int, row: Int, deltaCol: Int, deltaRow: Int) -> Bool {
        let endCol = col + 3 * deltaCol
        let endRow = row + 3 * deltaRow

        if endCol < 0 || endCol >= gameGrid.count || endRow < 0 || endRow >= gameGrid[0].count {
            return false
        }

        for i in 1..<4 {
            let c = col + i * deltaCol
            let r = row + i * deltaRow
            if gameGrid[c][r] != player {
                return false
            }
        }
        return true
    }
}
