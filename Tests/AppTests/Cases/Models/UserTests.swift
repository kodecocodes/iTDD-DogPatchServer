/// Copyright (c) 2021 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

@testable import App
import XCTVapor

final class UserTests: BaseTestCase {
  var about: String!
  var email: String!
  var userName: String!
  var password: String!
  var profileImageURL: String!
  var reviewCount: Int!
  var reviewRatingAverage: Double!
  
  var sut: User!
  
  // MARK: - Test lifecycle
  override func setUpWithError() throws {
    try super.setUpWithError()
    about = "about"
    email = "email@example.com"
    userName = "name"
    password = "password"
    profileImageURL = "https://example.com/image.png"
    reviewCount = 42
    reviewRatingAverage = 5.0
    
    sut = User(about: about,
                   email: email,
                   name: userName,
                   password: password,
                   profileImageURL: profileImageURL,
                   reviewCount: reviewCount,
                   reviewRatingAverage: reviewRatingAverage)
    try sut.save(on: app.db).wait()
  }
  
  override func tearDownWithError() throws {
    sut = nil
    try super.tearDownWithError()
  }
  
  // MARK: - Model - Tests
  func test_schema_setToUsers() {
    XCTAssertEqual(User.schema, "users")
  }
  
  // MARK: - Object lifecycle - Tests
  func test_init_setsAbout() {
    XCTAssertEqual(sut.about, about)
  }
  
  func test_init_setsEmail() {
    XCTAssertEqual(sut.email, email)
  }
  
  func test_init_setsName() {
    XCTAssertEqual(sut.name, userName)
  }
  
  func test_init_setsPassword() throws {
    XCTAssertEqual(sut.password, password)
  }
  
  func test_init_setsProfileImageURL() {
    XCTAssertEqual(sut.profileImageURL, profileImageURL)
  }
  
  func test_init_setsReviewCount() {
    XCTAssertEqual(sut.reviewCount, reviewCount)
  }
  
  func test_init_setsReviewRatingAverage() {
    XCTAssertEqual(sut.reviewRatingAverage, reviewRatingAverage)
  }
  
  func test_save_setsId() throws {
    XCTAssertNotNil(sut.id)
  }
  
  // MARK: - ModelAuthenticatable - Tests
  
  func test_userNameKey_setToEmail() {
    XCTAssertEqual(User.usernameKey, \User.$email)
  }
  
  func test_passwordHashKey_setToPassword() {
    XCTAssertEqual(User.passwordHashKey, \User.$password)
  }
  
  func test_verify_givenBcryptVerifies_returnsTrue() throws {
    password = try Bcrypt.hash("password")
    sut.password = password
    try XCTAssertTrue(sut.verify(password: "password"))
  }
  
  // MARK: - PublicConvertible
  func test_UserPublic_init_createsExpectedUser() {
    let publicUser = User.Public(from: sut)
    XCTAssertEqual(publicUser.id, sut.id)
    XCTAssertEqual(publicUser.about, sut.about)
    XCTAssertEqual(publicUser.email, sut.email)
    XCTAssertEqual(publicUser.name, sut.name)
    XCTAssertEqual(publicUser.profileImageURL, sut.profileImageURL)
    XCTAssertEqual(publicUser.reviewCount, sut.reviewCount)
    XCTAssertEqual(publicUser.reviewRatingAverage, sut.reviewRatingAverage)
  }
  
  func test_convertToPublic_returnsPublicUser() {
    let publicUser = sut.convertToPublic()
    XCTAssertEqual(publicUser.id, sut.id)
    XCTAssertEqual(publicUser.about, sut.about)
    XCTAssertEqual(publicUser.email, sut.email)
    XCTAssertEqual(publicUser.name, sut.name)
    XCTAssertEqual(publicUser.profileImageURL, sut.profileImageURL)
    XCTAssertEqual(publicUser.reviewCount, sut.reviewCount)
    XCTAssertEqual(publicUser.reviewRatingAverage, sut.reviewRatingAverage)
  }
}
