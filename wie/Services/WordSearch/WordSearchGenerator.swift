import Foundation

protocol WordSearchGenerating {
    func makeGrid(rows: Int, columns: Int, words: [String]) -> [[Character]]
}

final class DefaultWordSearchGenerator: WordSearchGenerating {
    func makeGrid(rows: Int, columns: Int, words: [String]) -> [[Character]] {
        let letters = Array("abcdefghijklmnopqrstuvwxyz")
        var grid = Array(repeating: Array(repeating: Character(" "), count: columns), count: rows)
        
        for word in words {
            place(word: word, in: &grid, rows: rows, columns: columns)
        }
        
        for row in 0..<rows {
            for column in 0..<columns where grid[row][column] == " " {
                grid[row][column] = letters.randomElement() ?? Character("a")
            }
        }
        
        return grid
    }
    
    private func place(word: String, in grid: inout [[Character]], rows: Int, columns: Int) {
        guard !word.isEmpty else { return }
        var placed = false
        
        while !placed {
            let horizontal = Bool.random()
            let startRow = Int.random(in: 0..<rows)
            let startCol = Int.random(in: 0..<columns)
            
            if horizontal {
                placed = placeHorizontally(word: word, in: &grid, startRow: startRow, startCol: startCol, columns: columns)
            } else {
                placed = placeVertically(word: word, in: &grid, startRow: startRow, startCol: startCol, rows: rows)
            }
        }
    }
    
    private func placeHorizontally(word: String, in grid: inout [[Character]], startRow: Int, startCol: Int, columns: Int) -> Bool {
        guard startCol + word.count <= columns else { return false }
        for offset in 0..<word.count where grid[startRow][startCol + offset] != " " {
            return false
        }
        for (index, char) in word.enumerated() {
            grid[startRow][startCol + index] = char
        }
        return true
    }
    
    private func placeVertically(word: String, in grid: inout [[Character]], startRow: Int, startCol: Int, rows: Int) -> Bool {
        guard startRow + word.count <= rows else { return false }
        for offset in 0..<word.count where grid[startRow + offset][startCol] != " " {
            return false
        }
        for (index, char) in word.enumerated() {
            grid[startRow + index][startCol] = char
        }
        return true
    }
}
