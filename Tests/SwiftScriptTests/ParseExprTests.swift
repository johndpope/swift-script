import XCTest
@testable import SwiftScript

class ParseExprTests: XCTestCase {
    func testExpr() {
        XCTAssertTrue(parseSuccess(
            expr, "a + try! b + try? c as C is C*12 + !X"))
        XCTAssertTrue(parseSuccess(
            expr, "[foo, x[12]]"))
    }
    
    func testExprSelf() {
        XCTAssertTrue(parseSuccess(
            exprSelf, "self"))
    }

    func testExprAssign() {
        XCTAssertTrue(parseSuccess(
            expr, "self.x = 1"))
    }
}