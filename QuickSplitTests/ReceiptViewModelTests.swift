import XCTest
@testable import QuickSplit

@MainActor
final class ReceiptViewModelTests: XCTestCase {
    var viewModel: ReceiptViewModel!
    
    override func setUp() async throws {
        try await super.setUp()
        viewModel = ReceiptViewModel()
    }
    
    override func tearDown() async throws {
        viewModel = nil
        try await super.tearDown()
    }
    
    func testAddItem() async throws {
        // Given
        let item = ReceiptItem(name: "Test Item", price: 10.0)
        
        // When
        viewModel.addItem(item)
        
        // Then
        XCTAssertNotNil(viewModel.currentReceipt)
        XCTAssertEqual(viewModel.currentReceipt?.items.count, 1)
        XCTAssertEqual(viewModel.currentReceipt?.items.first?.name, "Test Item")
        XCTAssertEqual(viewModel.currentReceipt?.items.first?.price, 10.0)
    }
    
    func testCalculateTotals() async throws {
        // Given
        let item1 = ReceiptItem(name: "Item 1", price: 10.0)
        let item2 = ReceiptItem(name: "Item 2", price: 15.0)
        viewModel.addItem(item1)
        viewModel.addItem(item2)
        viewModel.tipPercentage = 20.0
        viewModel.includeTax = true
        
        // When
        viewModel.calculateTotals()
        
        // Then
        XCTAssertEqual(viewModel.currentReceipt?.subtotal, 25.0)
        XCTAssertEqual(viewModel.currentReceipt?.tax, 2.0) // 8% tax
        XCTAssertEqual(viewModel.currentReceipt?.tip, 5.0) // 20% tip
        XCTAssertEqual(viewModel.currentReceipt?.total, 32.0) // subtotal + tax + tip
    }
    
    func testRemoveItem() async throws {
        // Given
        let item1 = ReceiptItem(name: "Item 1", price: 10.0)
        let item2 = ReceiptItem(name: "Item 2", price: 15.0)
        viewModel.addItem(item1)
        viewModel.addItem(item2)
        
        // When
        viewModel.removeItem(at: 0)
        
        // Then
        XCTAssertEqual(viewModel.currentReceipt?.items.count, 1)
        XCTAssertEqual(viewModel.currentReceipt?.items.first?.name, "Item 2")
    }
    
    func testTipPercentageChange() async throws {
        // Given
        let item = ReceiptItem(name: "Test Item", price: 100.0)
        viewModel.addItem(item)
        
        // When
        viewModel.tipPercentage = 15.0
        viewModel.calculateTotals()
        
        // Then
        XCTAssertEqual(viewModel.currentReceipt?.tip, 15.0)
        
        // When
        viewModel.tipPercentage = 20.0
        viewModel.calculateTotals()
        
        // Then
        XCTAssertEqual(viewModel.currentReceipt?.tip, 20.0)
    }
    
    func testTaxInclusion() async throws {
        // Given
        let item = ReceiptItem(name: "Test Item", price: 100.0)
        viewModel.addItem(item)
        
        // When
        viewModel.includeTax = true
        viewModel.calculateTotals()
        
        // Then
        XCTAssertEqual(viewModel.currentReceipt?.tax, 8.0) // 8% tax
        
        // When
        viewModel.includeTax = false
        viewModel.calculateTotals()
        
        // Then
        XCTAssertEqual(viewModel.currentReceipt?.tax, 0.0)
    }
} 