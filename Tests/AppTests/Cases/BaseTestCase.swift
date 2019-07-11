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

class BaseTestCase: XCTestCase {
  
  // MARK: - Instance Variables
  var app: Application!
  var conn: PostgreSQLConnection!
  var directory: DirectoryConfig!
  var fileManager: FileManager!
  
  var defaultRawPassword: String!
  var defaultUser: User!
  
  var defaultUserTuple: (User, String) {
    return (defaultUser, defaultRawPassword)
  }
  
  // MARK: - Test Lifecycle
  override func setUp() {
    super.setUp()
    try! Application.reset()
    
    app = try! Application.testable()
    conn = try! app.newConnection(to: .psql).wait()
    directory = DirectoryConfig.detect()
    fileManager = FileManager()
    
    defaultRawPassword = "pass"
    defaultUser = try! givenUser(about: "A fun-loving tester",
                                 email: "johnny.test@example.com",
                                 name: "Johnny Test",
                                 password: defaultRawPassword)
    defaultUser.reviewRatingAverage = Review.defaultReviewValue
  }
  
  override func tearDown() {
    deleteUserImages()
    
    conn.close()
    
    app = nil
    conn = nil
    directory = nil
    fileManager = nil
    
    defaultRawPassword = nil
    defaultUser = nil
    super.tearDown()
  }
  
  private func deleteUserImages() {
    let userDirectory = try! directory.workDir.appending("public/users/\(defaultUser.requireID())")
    try? fileManager.removeItem(atPath: userDirectory)
  }
  
  // MARK: - Given
  func givenUser(about: String? = nil,
                 email: String = "email@example.com",
                 name: String = "name",
                 password: String = "password") throws -> User {
    let password = try BCrypt.hash(password)
    let user = User(about: about, email: email, name: name, password: password)
    return try user.save(on: conn).wait()
  }
  
  func givenImageFile(named fileName: String = "joshua_greene.jpeg") -> File {
    let directory = DirectoryConfig.detect()
    let testResourcePath = directory.workDir.appending("Tests/AppTests/Resources/\(fileName)")
    
    let fileManager = FileManager()
    let data = fileManager.contents(atPath: testResourcePath)!
    
    return File(data: data, filename: fileName)
  }
}
