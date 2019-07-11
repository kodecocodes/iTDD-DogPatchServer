/// Copyright (c) 2019 Razeware LLC
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
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

// MARK: - Test Module
@testable import App

// MARK: - Collaborators
import Crypto
import FluentPostgreSQL
import Vapor
import XCTest

// MARK: - Test Support
import XCTest

class UsersControllerTests: BaseTestCase {
  
  // MARK: - Instance Properties
  var reviewBuilder: Review.Builder!
  var seller: User!
  var userBuilder: User.Builder!
  
  // MARK: - Test Lifecycle
  override func tearDown() {
    reviewBuilder = nil
    seller = nil
    userBuilder = nil
    super.tearDown()
  }
  
  // MARK: - Given
  private func givenUserBuilder(about: String? = nil,
                                email: String? = nil,
                                name: String? = nil,
                                password: String? = nil,
                                profileImage: File? = nil) {
    userBuilder = User.Builder(about: about,
                               email: email,
                               name: name,
                               password: password,
                               profileImage: profileImage)
  }
  
  func givenUsersAPIPath(for subpaths: String...) -> String {
    return "\(UsersController.rootURI)\(subpaths.joined(separator: "/"))"
  }
  
  // MARK: - Creating - Tests
  func testPOSTUser_createsUser() throws {
    // given
    var user = User(about: "about",
                    email: "a_new_user@example.com",
                    name: "name",
                    password: "password")
    
    // when
    let actual = try app.getResponse(to: UsersController.rootURI,
                                     method: .POST,
                                     body: user,
                                     decodeTo: User.Public.self)
    
    user.id = actual.id // Only set when `User` is saved to the database
    let expected = try user.convertToPublic()
    
    // then
    XCTAssertEqual(actual, expected)
  }
  
  // MARK: - Reviewing - Tests
  func testPOSTReview_createsReview() throws {
    // given
    try givenSellerAndReviewBuilder()
    
    // when
    let actual = try app.getResponse(to: givenUsersAPIPath(for: seller.requireID().uuidString, "reviews"),
                                     method: .POST,
                                     body: reviewBuilder,
                                     decodeTo: Review.self,
                                     loggedInUserTuple: defaultUserTuple)
    
    // then
    XCTAssertNotNil(actual.id)
  }
  
  func testPOSTReview_updatesUserReviewStats() throws {
    // given
    try givenSellerAndReviewBuilder()
    
    // when
    _ = try app.getResponse(to: givenUsersAPIPath(for: seller.requireID().uuidString, "reviews"),
                            method: .POST,
                            body: reviewBuilder,
                            decodeTo: Review.self,
                            loggedInUserTuple: defaultUserTuple)
    
    // then
    let updatedSeller = try User.query(on: conn).filter(\User.id, .equal, seller.requireID()).first().wait()!    
    XCTAssertEqual(updatedSeller.reviewCount, 1)
    XCTAssertEqual(updatedSeller.reviewRatingAverage, reviewBuilder.rating)
  }
  
  func givenSellerAndReviewBuilder() throws {
    seller = try givenUser(email: "seller@example.com", name: "Seller")
    reviewBuilder = Review.Builder(title: "title", details: "details", rating: 5.0)
  }
  
  // MARK: - Searching - Tests
  func testGETUserByID_returnsUser() throws {
    // given
    let uri = givenUsersAPIPath(for: defaultUser.id!.uuidString)
    
    // when
    let actualUser = try app.getResponse(to: uri, decodeTo: User.Public.self)
    
    // then
    try XCTAssertEqual(actualUser, defaultUser.convertToPublic())
  }
  
  func testGETUserByEmail_returnsUser() throws {
    // given
    let expected = try defaultUser.convertToPublic()
    let uri = givenUsersAPIPath(for: "search") + "?email=\(expected.email)"
    
    // when
    let actual = try app.getResponse(to: uri, decodeTo: User.Public.self)
    
    // then
    XCTAssertEqual(actual, expected)
  }
  
  // MARK: - Update - Tests
  func testPUTUser_givenAbout_updatesUser() throws {
    
    // given
    givenUserBuilder(about: "new about")
    
    var user = defaultUser!
    user.about = userBuilder.about
    let expected = try user.convertToPublic()
    
    // when
    let actual = try app.getResponse(to: UsersController.rootURI,
                                     method: .PUT,
                                     body: userBuilder,
                                     decodeTo: User.Public.self,
                                     loggedInUserTuple: defaultUserTuple)
    
    // then
    XCTAssertEqual(actual, expected)
  }
  
  func testPUTUser_givenEmail_updatesUser() throws {
    // given
    givenUserBuilder(email: "new_email@example.com")
    
    var user = defaultUser!
    user.email = userBuilder.email!
    let expected = try user.convertToPublic()
    
    // when
    let actual = try app.getResponse(to: UsersController.rootURI,
                                     method: .PUT,
                                     body: userBuilder,
                                     decodeTo: User.Public.self,
                                     loggedInUserTuple: defaultUserTuple)
    
    // then
    XCTAssertEqual(actual, expected)
  }
  
  func testPUTUser_givenUpdateEmailIsTaken_responseIndicatesError() throws {
    let email = "existing_email@example.com"
    _ = try givenUser(email: email)
    
    // given
    givenUserBuilder(email: email)
    
    // when
    let response = try app.sendRequest(to: UsersController.rootURI,
                                       method: .PUT,
                                       body: userBuilder,
                                       loggedInUserTuple: defaultUserTuple)
    
    // then
    XCTAssertEqual(response.http.status, .conflict)
  }
  
  func testPUTUser_givenName_updatesUser() throws {
    // given
    givenUserBuilder(name: "new name")
    
    var user = defaultUser!
    user.name = userBuilder.name!
    let expected = try user.convertToPublic()
    
    // when
    let actual = try app.getResponse(to: UsersController.rootURI,
                                     method: .PUT,
                                     body: userBuilder,
                                     decodeTo: User.Public.self,
                                     loggedInUserTuple: defaultUserTuple)
    
    // then
    XCTAssertEqual(actual, expected)
  }
  
  func testPUTUser_givenPassword_updatesUser() throws {
    // given
    givenUserBuilder(password: "new name")
    
    var user = defaultUser!
    user.password = try BCrypt.hash(userBuilder.password!)
    let expected = try user.convertToPublic()
    
    // when
    let actual = try app.getResponse(to: UsersController.rootURI,
                                     method: .PUT,
                                     body: userBuilder,
                                     decodeTo: User.Public.self,
                                     loggedInUserTuple: defaultUserTuple)
    
    // then
    XCTAssertEqual(actual, expected)
  }
  
  func testPUTUser_givenProfileImage_updatesUser() throws {
    // given
    givenUserBuilder(profileImage: givenImageFile())
    
    // when
    let actual = try app.getResponse(to: UsersController.rootURI,
                                     method: .PUT,
                                     body: userBuilder,
                                     decodeTo: User.Public.self,
                                     loggedInUserTuple: defaultUserTuple)
    defaultUser.profileImage = actual.profileImage
    
    // then
    guard let publicPath = actual.profileImage else {
      XCTFail("Profile image path was unexpectedly empty!")
      return
    }
    let profileImageFullPath = directory.workDir.appending("public/\(publicPath)")
    XCTAssertTrue(fileManager.fileExists(atPath: profileImageFullPath))
  }
}
