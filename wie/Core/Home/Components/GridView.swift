//
//  GridView.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 24/01/2024.
//

import SwiftUI

struct WordSelection: Identifiable {
    let id = UUID()
    let start: IndexPath
    let end: IndexPath
}

class WordSearchGame: ObservableObject {
    
    @Published var grid: [[Character]] = [[]]
    @Published var selectedIndices: Set<IndexPath> = []
    @Published var verifiedIndices: Set<IndexPath> = []
    @Published var matchedWords: [String] = []
    @Published var foundWordSelections: [WordSelection] = []
    var aimWords: [String] = []
    var selectedLetters: [(character: Character, position: IndexPath)] = []
    @Published var hintLetterPositions: Set<IndexPath> = []
    @Published var currentHintIndex: Int = 0  // Track which word we're showing
    @Published var showHints = false {
        didSet {
            objectWillChange.send()
        }
    }
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    private var orderedHintPositions: [(word: String, position: IndexPath)] = []  // Store hints in order
    private let hintDelay: TimeInterval = 30
    private var hintCountdownTask: DispatchWorkItem?
    
    init() {}

    deinit {
        cancelHintCountdown()
    }
    
    func setAimWords(_ words: [String], horizontalSizeClass: UserInterfaceSizeClass) {
        self.aimWords = words
        // Revert back to original grid size
        let columns = (horizontalSizeClass == .regular ? 12 : 9)
        
        // Don't clear hint positions here
        selectedIndices.removeAll()
        verifiedIndices.removeAll()
        matchedWords.removeAll()
        selectedLetters.removeAll()
        foundWordSelections.removeAll()
        
        generateWordSearchGrid(rows: 13, columns: columns, words: aimWords)
        startHintTimer()
    }
    
    func updateSelection(from position: CGPoint, in geometry: GeometryProxy) {
        let rowHeight = geometry.size.height / CGFloat(grid.count)
        let columnWidth = geometry.size.width / CGFloat(grid[0].count)
        
        let rowIndex = Int(position.y / rowHeight)
        let columnIndex = Int(position.x / columnWidth)
        
        guard rowIndex >= 0 && rowIndex < grid.count && columnIndex >= 0 && columnIndex < grid[0].count else {
            return
        }
        
        let indexPath = IndexPath(row: rowIndex, section: columnIndex)
        
        // If this is the first letter being selected
        if selectedLetters.isEmpty {
            selectedIndices.insert(indexPath)
            selectedLetters.append((character: grid[rowIndex][columnIndex], position: indexPath))
            return
        }
        
        // Get the first selected position
        guard let firstPosition = selectedLetters.first?.position else { return }
        
        // Calculate direction from first selected letter to current position
        let rowDiff = indexPath.row - firstPosition.row
        let colDiff = indexPath.section - firstPosition.section
        
        // Check if selection is in a straight line (horizontal, vertical, or diagonal)
        let isHorizontal = rowDiff == 0
        let isVertical = colDiff == 0
        let isDiagonal = abs(rowDiff) == abs(colDiff)
        
        if isHorizontal || isVertical || isDiagonal {
            // Keep verified indices (found words) and add new selection
            selectedIndices = verifiedIndices
            selectedLetters.removeAll()
            
            // Add first letter back
            selectedLetters.append((character: grid[firstPosition.row][firstPosition.section], 
                                  position: firstPosition))
            selectedIndices.insert(firstPosition)
            
            // Calculate step direction
            let stepRow = rowDiff == 0 ? 0 : rowDiff / abs(rowDiff)
            let stepCol = colDiff == 0 ? 0 : colDiff / abs(colDiff)
            
            // Add all letters in the line from first to current position
            var currentRow = firstPosition.row
            var currentCol = firstPosition.section
            
            while true {
                currentRow += stepRow
                currentCol += stepCol
                
                let currentPath = IndexPath(row: currentRow, section: currentCol)
                selectedIndices.insert(currentPath)
                selectedLetters.append((character: grid[currentRow][currentCol], 
                                      position: currentPath))
                
                if currentRow == indexPath.row && currentCol == indexPath.section {
                    break
                }
            }
        }
    }
    
    func getWordFromSelectedLetters() -> String {
        var word = ""
        for selected in selectedLetters {
            word.append(selected.character)
        }
        return word
    }
    
    func generateWordSearchGrid(rows: Int, columns: Int, words: [String]) {
        let letters = "abcdefghijklmnopqrstuvwxyz"
        var grid = Array(repeating: Array(repeating: Character(" "), count: columns), count: rows)
        
        resetHintStateForNewGrid()
        
        // Sort words by length (longest first)
        let sortedWords = words.sorted { $0.count > $1.count }
        
        for word in sortedWords {
            var placed = false
            let wordChars = Array(word.lowercased())
            var firstLetterPosition: IndexPath? = nil
            
            // Define all possible directions
            let directions = [
                (0, 1),   // horizontal
                (1, 0),   // vertical
                (1, 1),   // diagonal down-right
                (1, -1),  // diagonal down-left
            ]
            
            // Try each direction until word is placed
            for (dRow, dCol) in directions where !placed {
                let rowSequence = Array(0..<rows).shuffled()
                let colSequence = Array(0..<columns).shuffled()
                
                for row in rowSequence where !placed {
                    for col in colSequence {
                        let endRow = row + (dRow * (wordChars.count - 1))
                        let endCol = col + (dCol * (wordChars.count - 1))
                        
                        if endRow >= 0 && endRow < rows && endCol >= 0 && endCol < columns {
                            if canPlaceWordAt(word: wordChars, row: row, col: col, dRow: dRow, dCol: dCol, in: grid) {
                                placeWord(wordChars, at: row, col: col, dRow: dRow, dCol: dCol, in: &grid)
                                firstLetterPosition = IndexPath(row: row, section: col)  // Store position when placing
                                placed = true
                                break
                            }
                        }
                    }
                }
            }
            
            // Store hint position with word
            if let position = firstLetterPosition {
                orderedHintPositions.append((word: word, position: position))
            }
            
            if !placed {
                print("Warning: Could not place word: \(word). Consider increasing grid size.")
            }
        }
        
        // Fill remaining spaces with random letters
        for i in 0..<rows {
            for j in 0..<columns {
                if grid[i][j] == " " {
                    grid[i][j] = letters.randomElement()!
                }
            }
        }
        
        self.grid = grid
    }
    
    private func canPlaceWordAt(word: [Character], row: Int, col: Int, dRow: Int, dCol: Int, in grid: [[Character]]) -> Bool {
        let length = word.count
        let rows = grid.count
        let cols = grid[0].count
        
        // Check if the word fits with spacing
        for i in -1...length {  // Keep original padding of 1
            let newRow = row + (dRow * i)
            let newCol = col + (dCol * i)
            
            // Check main word placement area
            if i >= 0 && i < length {
                if newRow < 0 || newRow >= rows || newCol < 0 || newCol >= cols {
                    return false
                }
                let currentCell = grid[newRow][newCol]
                if currentCell != " " && currentCell != word[i] {
                    return false
                }
            }
            // Check spacing around word
            else if newRow >= 0 && newRow < rows && newCol >= 0 && newCol < cols {
                if grid[newRow][newCol] != " " {
                    return false
                }
            }
        }
        
        return true
    }
    
    private func placeWord(_ word: [Character], at row: Int, col: Int, dRow: Int, dCol: Int, in grid: inout [[Character]]) {
        for (index, char) in word.enumerated() {
            let newRow = row + (dRow * index)
            let newCol = col + (dCol * index)
            grid[newRow][newCol] = char
        }
    }
    
    func handleWordFound(_ word: String) {
        if aimWords.contains(word) && !matchedWords.contains(word) {
            matchedWords.append(word)
            verifiedIndices.formUnion(selectedIndices)
            
            if let first = selectedLetters.first, let last = selectedLetters.last {
                let selection = WordSelection(start: first.position, end: last.position)
                foundWordSelections.append(selection)
            }
            
            clearSelection()
            clearHintHighlight()
            refreshHintCursor()
            scheduleHintCountdown()
        } else {
            clearSelection()
        }
    }
    
    private func showNextHint() {
        refreshHintCursor()
        guard currentHintIndex < orderedHintPositions.count else { return }
        withAnimation(.easeInOut(duration: 0.6)) {
            self.hintLetterPositions = [self.orderedHintPositions[self.currentHintIndex].position]
            self.showHints = true
        }
        scheduleHintCountdown()
    }
    
    func clearSelection() {
        selectedIndices = verifiedIndices  // Keep verified indices
        selectedLetters.removeAll()
    }
    
    func startHintTimer() {
        clearHintHighlight()
        refreshHintCursor()
        scheduleHintCountdown()
    }

    private func resetHintStateForNewGrid() {
        cancelHintCountdown()
        clearHintHighlight()
        orderedHintPositions.removeAll()
        currentHintIndex = 0
    }

    private func clearHintHighlight() {
        hintLetterPositions.removeAll()
        showHints = false
    }

    private func refreshHintCursor() {
        if let nextIndex = orderedHintPositions.firstIndex(where: { !matchedWords.contains($0.word) }) {
            currentHintIndex = nextIndex
        } else {
            currentHintIndex = orderedHintPositions.count
        }
    }

    private func scheduleHintCountdown() {
        cancelHintCountdown()
        guard orderedHintPositions.contains(where: { !matchedWords.contains($0.word) }) else { return }
        let task = DispatchWorkItem { [weak self] in
            DispatchQueue.main.async {
                self?.showNextHint()
            }
        }
        hintCountdownTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + hintDelay, execute: task)
    }

    private func cancelHintCountdown() {
        hintCountdownTask?.cancel()
        hintCountdownTask = nil
    }
}

struct LetterCell: View {
    var letter: Character
    var isSelected: Bool
    var isHintLetter: Bool
    @ObservedObject var game: WordSearchGame
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        Text(String(letter))
            .font(.custom("ChalkboardSE-Regular", size: horizontalSizeClass == .regular ? 35: 29))
            .fixedSize()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundColor(.black)
            .background(
                Group {
                    if isSelected {
                        Color.theme.iconColor.opacity(0.6)
                    } else if isHintLetter && game.showHints {
                        Color.yellow.opacity(0.7)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Color.clear
                    }
                }
            )
            .animation(.easeInOut(duration: 0.6), value: game.showHints)
    }
}

struct GridView: View {
    
    @ObservedObject var game: WordSearchGame
    
    var onCompletion: () -> Void
    var onUpdateWord: ([String]) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    ForEach(game.grid.indices, id: \.self) { rowIndex in
                        HStack(spacing: 0) {
                            ForEach(game.grid[rowIndex].indices, id: \.self) { columnIndex in
                                let indexPath = IndexPath(row: rowIndex, section: columnIndex)
                                let isHint = game.hintLetterPositions.contains(indexPath)
                                
                                LetterCell(
                                    letter: game.grid[rowIndex][columnIndex],
                                    isSelected: game.selectedIndices.contains(indexPath),
                                    isHintLetter: isHint,
                                    game: game
                                )
                                .id("\(rowIndex)-\(columnIndex)-\(game.showHints)-\(isHint)")
                            }
                        }
                    }
                }
                ForEach(game.foundWordSelections) { selection in
                    wordBorder(start: selection.start, end: selection.end, in: geometry)
                }
                if let first = game.selectedLetters.first, let last = game.selectedLetters.last {
                    wordBorder(start: first.position, end: last.position, in: geometry)
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        game.updateSelection(from: value.location, in: geometry)
                    }
                    .onEnded { value in
                        handleGestureEnd()
                    }
            )
            .drawingGroup()
            .onAppear {
                game.showHints = false
                game.startHintTimer()
            }
        }
        
    }
    
    func handleGestureEnd() {
        let word = game.getWordFromSelectedLetters().lowercased()
        game.handleWordFound(word)
        
        if game.matchedWords.contains(word) {
            checkCompletion()
        }
    }
    
    func wordBorder(start: IndexPath, end: IndexPath, in geometry: GeometryProxy) -> some View {
        let startRow = start.row
        let startCol = start.section
        let endRow = end.row
        let endCol = end.section
        
        let cellWidth = geometry.size.width / CGFloat(game.grid[0].count)
        let cellHeight = geometry.size.height / CGFloat(game.grid.count)
        
        let xPosition = min(CGFloat(startCol), CGFloat(endCol)) * cellWidth
        let yPosition = min(CGFloat(startRow), CGFloat(endRow)) * cellHeight
        
        let width = (abs(CGFloat(endCol - startCol)) + 1) * cellWidth
        let height = (abs(CGFloat(endRow - startRow)) + 1) * cellHeight
        
        return RoundedRectangle(cornerRadius: 5)
            .stroke(Color.theme.iconColor, lineWidth: 3)
            .frame(width: width, height: height)
            .position(x: xPosition + width / 2, y: yPosition + height / 2)
    }
    
    func checkCompletion() {
        if game.matchedWords.count == game.aimWords.count {
            onCompletion()
        }else {
            onUpdateWord(game.matchedWords)
        }
    }
}

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        let game = WordSearchGame()
        game.setAimWords(["sample", "words", "for", "preview"], horizontalSizeClass: .compact)

        return GridView(game: game, onCompletion: {
            
        }, onUpdateWord: { matchedWords in
            
        })
        
    }
}
