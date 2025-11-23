import XCTest
@testable import wie

@MainActor
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
    
    func testShowNextSetUpdatesCurrentLevelAndWord() {
        // Arrange
        let secondLevel = TestDataFactory.makeWordLevel(name: "Second", words: ["one", "two"])
        let sut = makeSUT(wordLevels: [TestDataFactory.makeWordLevel(), secondLevel])
        sut.showWordsList = true
        
        // Act
        sut.showNextSet(wordLevel: secondLevel)
        
        // Assert
        XCTAssertEqual(sut.currentWordLevel.name, secondLevel.name)
        XCTAssertEqual(sut.currentWord.word, secondLevel.wordlist.first?.word)
        XCTAssertFalse(sut.showWordsList)
    }
    
    func testUpdateWordChangesCurrentWord() {
        // Arrange
        let sut = makeSUT()
        let newWord = Word.stub(id: 99, word: "updated")
        
        // Act
        sut.updateWord(newWord)
        
        // Assert
        XCTAssertEqual(sut.currentWord.word, newWord.word)
    }
    
    func testNextButtonPressedReturnsNextWordWhenAvailable() {
        // Arrange
        let level = TestDataFactory.makeWordLevel(words: ["alpha", "beta", "gamma"])
        let sut = makeSUT(wordLevels: [level])
        sut.currentWord = level.wordlist[0]
        
        // Act
        let nextWord = sut.nextButtonPressed(word: "alpha")
        
        // Assert
        XCTAssertEqual(nextWord, "beta")
    }
    
    func testNextButtonPressedReturnsNilAtEndOfList() {
        // Arrange
        let level = TestDataFactory.makeWordLevel(words: ["alpha", "beta"])
        let sut = makeSUT(wordLevels: [level])
        
        // Act
        let result = sut.nextButtonPressed(word: "beta")
        
        // Assert
        XCTAssertNil(result)
    }
    
    func testNextButtonPressedReturnsNilWhenWordNotFound() {
        // Arrange
        let level = TestDataFactory.makeWordLevel(words: ["alpha", "beta"])
        let sut = makeSUT(wordLevels: [level])
        
        // Act
        let result = sut.nextButtonPressed(word: "unknown")
        
        // Assert
        XCTAssertNil(result)
    }
    
    func testResetGameKeepsSameWordsAfterShuffle() {
        // Arrange
        let level = TestDataFactory.makeWordLevel(words: ["alpha", "beta", "gamma", "delta"])
        let sut = makeSUT(wordLevels: [level])
        let originalWords = level.wordlist.map { $0.word }
        
        // Act
        sut.resetGame()
        let shuffledWords = sut.currentWordLevel.wordlist.map { $0.word }
        
        // Assert
        XCTAssertEqual(originalWords.sorted(), shuffledWords.sorted())
    }
    
    func testGenerateWordSearchGridDelegatesToGenerator() {
        // Arrange
        let generator = StubWordSearchGenerator()
        generator.gridToReturn = [Array("cat")]
        let sut = makeSUT(wordSearchGenerator: generator)
        
        // Act
        let grid = sut.generateWordSearchGrid(rows: 1, columns: 3, words: ["cat"])
        
        // Assert
        XCTAssertEqual(generator.receivedArguments?.rows, 1)
        XCTAssertEqual(generator.receivedArguments?.columns, 3)
        XCTAssertEqual(generator.receivedArguments?.words, ["cat"])
        XCTAssertEqual(grid, generator.gridToReturn)
    }
    
    func testPlaySecondSoundUsesAudioService() {
        // Arrange
        let audioService = MockAudioService()
        let sut = makeSUT(audioService: audioService)
        
        // Act
        sut.playSecondSound(soundName: "ding")
        
        // Assert
        XCTAssertEqual(audioService.secondaryCalls, ["ding"])
    }
}

// MARK: - Test helpers

private extension HomeViewModelTests {
    func makeSUT(wordLevels: [WordLevel]? = nil,
                 audioService: AudioPlaying = MockAudioService(),
                 wordSearchGenerator: WordSearchGenerating = StubWordSearchGenerator()) -> HomeViewModel {
        let levels = wordLevels ?? [TestDataFactory.makeWordLevel()]
        let repository = MockWordRepository(wordLevels: levels)
        return HomeViewModel(wordRepository: repository,
                             audioService: audioService,
                             wordSearchGenerator: wordSearchGenerator,
                             initialWordLevels: levels)
    }
}

// MARK: - Test doubles & factories

enum TestDataFactory {
    static func makeWordLevel(name: String = "Test Level", words: [String] = ["alpha", "beta"]) -> WordLevel {
        let models = words.enumerated().map { Word.stub(id: $0.offset, word: $0.element) }
        return WordLevel(name: name, wordlist: models)
    }
}

private extension Word {
    static func stub(id: Int, word: String) -> Word {
        Word(fromString: "\(id), \(word)")
    }
}

// MARK: - Test doubles

private final class MockWordRepository: WordRepository {
    private let levels: [WordLevel]
    
    init(wordLevels: [WordLevel]) {
        self.levels = wordLevels
    }
    
    func fetchWordLevels(forceRefresh: Bool) async throws -> [WordLevel] {
        return levels
    }
}

private final class MockAudioService: AudioPlaying {
    private(set) var primaryCalls: [String] = []
    private(set) var primarySlowCalls: [String] = []
    private(set) var secondaryCalls: [String] = []
    private(set) var secondarySlowCalls: [String] = []
    
    func playPrimary(named soundName: String) {
        primaryCalls.append(soundName)
    }
    
    func playPrimarySlow(named soundName: String) {
        primarySlowCalls.append(soundName)
    }
    
    func playSecondary(named soundName: String) {
        secondaryCalls.append(soundName)
    }
    
    func playSecondarySlow(named soundName: String) {
        secondarySlowCalls.append(soundName)
    }
}

private final class StubWordSearchGenerator: WordSearchGenerating {
    var gridToReturn: [[Character]] = []
    private(set) var receivedArguments: (rows: Int, columns: Int, words: [String])?
    
    func makeGrid(rows: Int, columns: Int, words: [String]) -> [[Character]] {
        receivedArguments = (rows, columns, words)
        return gridToReturn
    }
}

// MARK: - Service implementation tests

final class DefaultWordSearchGeneratorTests: XCTestCase {
    func testMakeGridFillsEntireBoard() {
        // Arrange
        let generator = DefaultWordSearchGenerator()
        let rows = 5
        let columns = 5
        
        // Act
        let grid = generator.makeGrid(rows: rows, columns: columns, words: ["cat"])
        
        // Assert
        XCTAssertEqual(grid.count, rows)
        XCTAssertTrue(grid.allSatisfy { $0.count == columns })
        XCTAssertFalse(grid.flatMap { $0 }.contains(Character(" ")))
    }
    
    func testMakeGridPlacesAllWords() {
        // Arrange
        let generator = DefaultWordSearchGenerator()
        let words = ["cat", "dog", "owl"]
        
        // Act
        let grid = generator.makeGrid(rows: 8, columns: 8, words: words)
        
        // Assert
        for word in words {
            XCTAssertTrue(contains(word: word, in: grid), "Missing word: \(word)")
        }
    }
    
    private func contains(word: String, in grid: [[Character]]) -> Bool {
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
