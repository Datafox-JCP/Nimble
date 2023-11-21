//
//  LoginViewModelTests.swift
//  NimbleTests
//
//  Created by Juan Hernandez Pazos on 21/11/23.
//

import XCTest
@testable import Nimble

class LoginViewModelTests: XCTestCase {

    var viewModel: LoginViewModel!

    override func setUp() {
        super.setUp()
        viewModel = LoginViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testValidInput() {
        viewModel.email = "your_email@example.com"
        viewModel.password = "12345678"

        let isValid = viewModel.isValidInput()

        // Assert that the input is valid
        XCTAssertTrue(isValid)
    }

    func testInvalidEmail() {
        viewModel.email = "invalidemail"
        viewModel.password = "12345678"

        let isValid = viewModel.isValidInput()

        XCTAssertFalse(isValid)
    }

    func testShortPassword() {
        viewModel.email = "your_email@example.com"
        viewModel.password = "short"

        let isValid = viewModel.isValidInput()

        XCTAssertFalse(isValid)
    }

    func testNoData() {
        viewModel.email = ""
        viewModel.password = ""

        let isValid = viewModel.isValidInput()

        XCTAssertFalse(isValid)
    }

    func testValidInputDoesNotShowError() {
        viewModel.email = "your_email@example.com"
        viewModel.password = "12345678"

        viewModel.performAuthentication()

        XCTAssertFalse(viewModel.showAlert)
        XCTAssertEqual(viewModel.errorMessage, "")
        XCTAssertFalse(viewModel.validatingUser)
    }
}
