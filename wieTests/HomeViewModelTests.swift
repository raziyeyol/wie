import XCTest
@testable import wie

final class HomeViewModelTests: XCTestCase {
    func testToggleWordsListTogglesVisibility() {
        // Arrange
        let sut = makeSUT()
        sut.showWordsList = false
        
        // Act
        sut.toogleWordsList()
        
        // Assert
        XCTAssertTrue(sut.showWordsList)
    }
    
    func testShowNextSetUpdatesCurrentLevelAndWord() throws {
        // Arrange
        let secondLevel = TestDataFactory.makeWordLevel(name: "Second", words: ["one", "two"])
        let sut = makeSUT(wordLevels: [TestDataFactory.makeWordLevel(), secondLevel])
        sut.showWordsList = true
        
        // Act
        sut.showNextSet(wordLevel: secondLevel)
        
        // Assert
        XCTAssertEqual(sut.currentWordLevel.name, secondLevel.name)
        XCTAssertEqual(sut.currentWordModel.word, secondLevel.wordlist.first?.word)
        XCTAssertFalse(sut.showWordsList)
    }
    
    func testUpdateWordChangesCurrentWordModel() {
        // Arrange
        let sut = makeSUT()
        let newWord = WordModel.stub(id: 99, word: "updated")
        
        // Act
        sut.updateWord(wordModel: newWord)
        
        // Assert
        XCTAssertEqual(sut.currentWordModel.word, newWord.word)
    }
    
    func testNextButtonPressedReturnsNextWordWhenAvailable() {
        // Arrange
        let level = TestDataFactory.makeWordLevel(words: ["alpha", "beta", "gamma"])
        let sut = makeSUT(wordLevels: [level])
        sut.currentWordLevel = level
        sut.currentWordModel = level.wordlist[0]
        
        // Act
        let nextWord = sut.nextButtonPressed(word: "alpha")
        
        // Assert
        XCTAssertEqual(nextWord, "beta")
    }
    
    func testNextButtonPressedReturnsNilAtEndOfList() {
        // Arrange
        let level = TestDataFactory.makeWordLevel(words: ["alpha", "beta"])
        let sut = makeSUT(wordLevels: [level])
        sut.currentWordLevel = level
        
        // Act
        let result = sut.nextButtonPressed(word: "beta")
        
        // Assert
        XCTAssertNil(result)
    }
    
    func testNextButtonPressedReturnsNilWhenWordNotFound() {
        // Arrange
        let level = TestDataFactory.makeWordLevel(words: ["alpha", "beta"])
        let sut = makeSUT(wordLevels: [level])
        sut.currentWordLevel = level
        
        // Act
        let result = sut.nextButtonPressed(word: "unknown")
        
        // Assert
        XCTAssertNil(result)
    }
    
    func testResetGameKeepsSameWordsAfterShuffle() {
        // Arrange
        let level = TestDataFactory.makeWordLevel(words: ["alpha", "beta", "gamma", "delta"])
        let sut = makeSUT(wordLevels: [level])
        sut.currentWordLevel = level
        let originalWords = level.wordlist.map { $0.word }
        
        // Act
        sut.resetGame()
        let shuffledWords = sut.currentWordLevel.wordlist.map { $0.word }
        
        // Assert
        XCTAssertEqual(originalWords.sorted(), shuffledWords.sorted())
    }
    
    func testGenerateWordSearchGridFillsEntireGrid() {
        // Arrange
        let sut = makeSUT()
        let rows = 5
        let columns = 5
        
        // Act
        let grid = sut.generateWordSearchGrid(rows: rows, columns: columns, words: ["cat"])
        
        // Assert
        XCTAssertEqual(grid.count, rows)
        XCTAssertTrue(grid.allSatisfy { $0.count == columns })
        XCTAssertFalse(grid.flatMap { $0 }.contains(Character(" ")))
    }
    
    func testGenerateWordSearchGridPlacesAllWords() {
        // Arrange
        let sut = makeSUT()
        let words = ["cat", "dog", "owl"]
        
        // Act
        let grid = sut.generateWordSearchGrid(rows: 8, columns: 8, words: words)
        
        // Assert
        for word in words {
            XCTAssertTrue(containsWord(word, in: grid), "Missing word: \(word)")
        }
    }
}

// MARK: - Test helpers

private extension HomeViewModelTests {
    func makeSUT(wordLevels: [WordLevel]? = nil) -> HomeViewModel {
        let sut = HomeViewModel()
        if let wordLevels {
            sut.wordLevels = wordLevels
            sut.currentWordLevel = wordLevels.first ?? TestDataFactory.makeWordLevel(name: "Empty", words: [])
            sut.currentWordModel = sut.currentWordLevel.wordlist.first ?? WordModel.stub(id: -1, word: "placeholder")
        }
        return sut
    }
    
    func containsWord(_ word: String, in grid: [[Character]]) -> Bool {
        let target = Array(word)
        let rowCount = grid.count
        let columnCount = grid.first?.count ?? 0
        guard columnCount > 0 else { return false }
        
        for row in 0..<rowCount {
            for column in 0..<columnCount {
                if column + target.count <= columnCount {
                    let horizontalSlice = (0..<target.count).map { grid[row][column + $0] }
                    if horizontalSlice == target { return true }
                }
                if row + target.count <= rowCount {
                    let verticalSlice = (0..<target.count).map { grid[row + $0][column] }
                    if verticalSlice == target { return true }
                }
            }
        }
        return false
    }
}

// MARK: - Test doubles & factories

enum TestDataFactory {
    static func makeWordLevel(name: String = "Test Level", words: [String] = ["alpha", "beta"]) -> WordLevel {
        let models = words.enumerated().map { WordModel.stub(id: $0.offset, word: $0.element) }
        return WordLevel(name: name, wordlist: models)
    }
}

private extension WordModel {
    static func stub(id: Int, word: String) -> WordModel {
        WordModel(fromString: "\(id), \(word)")
    }
}
