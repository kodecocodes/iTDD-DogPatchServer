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

class UsersControllerTests: BaseControllerTestCase {
  let rootURI = "api/v1/users"
  
  // MARK: - When
  func whenPutUserUpdate(_ updateData: User.Update) throws -> User.Public {
    var receivedUser: User.Public!
    
    try app.test(.PUT, rootURI, loginCredentials: (user.email, rawPassword),
                 beforeRequest: { try $0.content.encode(updateData) })
    
    try app.test(.GET, "\(rootURI)/\(user.requireID())", afterResponse: { response in
      receivedUser = try response.content.decode(User.Public.self)
    })
   
    return receivedUser
  }
  
  // MARK: - GET - Tests
  func test_getHandler_returnsUserGivenID() throws {
    // given
    let expected = try User.create(on: app.db)
    let id = try expected.requireID()
    
    // when
    try app.test(.GET, "\(rootURI)/\(id)", afterResponse: { response in
      // then
      XCTAssertEqual(response.status, .ok)
      let actual = try response.content.decode(User.Public.self)
      XCTAssertEqual(actual.id, expected.id)
      XCTAssertEqual(actual.about, expected.about)
      XCTAssertEqual(actual.email, expected.email)
      XCTAssertEqual(actual.name, expected.name)
      XCTAssertEqual(actual.profileImageURL, expected.profileImageURL)
      XCTAssertEqual(actual.reviewCount, expected.reviewCount)
      XCTAssertEqual(actual.reviewRatingAverage, expected.reviewRatingAverage)
    })
  }
  
  func test_getSearchByEmailHandler_givenMissingEmailField_returnsBadRequestResponse() throws {
    try app.test(.GET, "\(rootURI)/search", afterResponse: { response in
      XCTAssertEqual(response.status, .badRequest)
    })
  }
  
  func test_getSearchByEmailHandler_givenUserNotFound_returnsNotFoundResponse() throws {
    let email = "notfound@example.com"
    
    try app.test(.GET, "\(rootURI)/search?email=\(email)", afterResponse: { response in
      XCTAssertEqual(response.status, .notFound)
    })
  }
  
  func test_getSearchByEmailHandler_givenEmailMatchesCaseInsensitive_returnsPublicUser() throws {
    try app.test(.GET, "\(rootURI)/search?email=\(user.email.capitalized)", afterResponse: { response in
      XCTAssertEqual(response.status, .ok)
      
      let receivedUser = try response.content.decode(User.Public.self)
      XCTAssertEqual(receivedUser.about, user.about)
      XCTAssertEqual(receivedUser.email, user.email)
      XCTAssertEqual(receivedUser.name, user.name)
      XCTAssertEqual(receivedUser.profileImageURL, user.profileImageURL)
      XCTAssertEqual(receivedUser.reviewCount, user.reviewCount)
      XCTAssertEqual(receivedUser.reviewRatingAverage, user.reviewRatingAverage)
    })
  }
  
  // MARK: - POST - Tests
  func test_postHandler_createsUser() throws {
    // given
    let builder = User.Builder(about: "about",
                               email: "email@example.com",
                               name: "name",
                               password: "password",
                               profileImageURL: "https://example.com/image.png")
    
    // when
    try app.test(.POST, rootURI, beforeRequest: { req in
      try req.content.encode(builder)
    
    }, afterResponse: { response in
    
      // then
      XCTAssertEqual(response.status, .ok)
      
      let receivedUser = try response.content.decode(User.Public.self)
      XCTAssertNotNil(receivedUser.id)
      XCTAssertEqual(receivedUser.about, builder.about)
      XCTAssertEqual(receivedUser.email, builder.email)
      XCTAssertEqual(receivedUser.name, builder.name)
      XCTAssertEqual(receivedUser.profileImageURL, builder.profileImageURL)
      XCTAssertEqual(receivedUser.reviewCount, 0)
      XCTAssertEqual(receivedUser.reviewRatingAverage, 0)
    })
  }
  
  func test_postLoginHandler_createsToken() throws {
    // when
    let token = try app.login(email: user.email,
                              password: rawPassword)
    
    // then
    XCTAssertFalse(token.value.isEmpty)
    XCTAssertEqual(token.$user.id, user.id)
  }
  
  // MARK: - PUT - Tests
  func test_putHandler_givenNotAuthenticated_returnsError() throws {
    try app.test(.PUT, rootURI, afterResponse: { response in
      XCTAssertEqual(response.status, .unauthorized)
    })
  }
  
  func test_putHandler_givenAuthenticated_updatesAbout() throws {
    // given
    let updateData = User.Update(about: "new about")
    
    // when
    let receivedUser = try whenPutUserUpdate(updateData)
    
    // then
    XCTAssertEqual(receivedUser.about, updateData.about)
  }
  
  func test_putHandler_givenAuthenticated_updatesEmail() throws {
    // given
    let updateData = User.Update(email: "new_email@example.com")
    
    // when
    let receivedUser = try whenPutUserUpdate(updateData)
    
    // then
    XCTAssertEqual(receivedUser.email, updateData.email)
  }
  
  func test_putHandler_givenAuthenticated_updatesPassword() throws {
    // given
    let updateData = User.Update(password: "new_password")

    // when
    _ = try whenPutUserUpdate(updateData)

    // then
    let receivedUser = try User.find(user.id, on: app.db).unwrap(or: Abort(.notFound)).wait()
    try XCTAssertTrue(Bcrypt.verify(updateData.password!, created: receivedUser.password))
  }
  
  func test_putHandler_givenAuthenticated_updatesName() throws {
    // given
    let updateData = User.Update(name: "new name")
    
    // when
    let receivedUser = try whenPutUserUpdate(updateData)
    
    // then
    XCTAssertEqual(receivedUser.name, updateData.name)
  }
  
  func test_putHandler_givenAuthenticated_updatesProfileImageURL() throws {
    // given
    let updateData = User.Update(profileImageURL: "https://example.com/new_profile_image.png")
    
    // when
    let receivedUser = try whenPutUserUpdate(updateData)
    
    // then
    XCTAssertEqual(receivedUser.profileImageURL, updateData.profileImageURL)
  }
}
