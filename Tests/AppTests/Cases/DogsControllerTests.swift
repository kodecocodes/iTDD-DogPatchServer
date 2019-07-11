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
import Vapor

// MARK: - Test Support
import XCTest

class DogsControllerTests: BaseTestCase {
  
  // MARK: - Instance Properties
  var builder: Dog.Builder!
  var seller: User { return defaultUser }
  
  // MARK: - Test Lifecycle
  override func tearDown() {
    builder = nil
    super.tearDown()
  }
  
  // MARK: - Given
  func givenDogsAPIPath(for subpaths: String...) -> String {
    return "\(DogsController.rootURI)\(subpaths.joined(separator: "/"))"
  }
  
  func givenDogsCreated(count: Int = 3) throws -> [Dog.Public] {
    return try (1...count).map { i in      
      let dog = try Dog(id: nil,
                        sellerID: seller.requireID(),
                        about: "about \(i)",
                        breed: "breed \(i)",
                        breederRating: seller.reviewRatingAverage,
                        cost: 42.42,
                        gender: .male,
                        image: "image \(i)",
                        name: "name \(i)",
                        relativeBirthday: TimeInterval(i).years,
                        relativeCreation: TimeInterval(i).days)
      
      return try dog.save(on: conn).wait().convertToPublic()
    }
  }
  
  // MARK: - When
  func whenPostDogBuilder(name: String = "Doggo",
                          relativeBirthday: TimeInterval = 1.year,
                          relativeCreation: TimeInterval = 3.days) throws -> Dog.Public {
    // given
    builder = Dog.Builder(about: "about",
                          breed: "breed",
                          cost: 42.42,
                          gender: .male,
                          image: givenImageFile(),
                          name: name,
                          relativeBirthday: relativeBirthday,
                          relativeCreation: relativeCreation)
    
    // when
    return try app.getResponse(to: DogsController.rootURI,
                               method: .POST,
                               body: builder,
                               decodeTo: Dog.Public.self,
                               loggedInUserTuple: defaultUserTuple)
  }
  
  // MARK: - Creating - Tests
  func testPOSTDogBuilder_createsDog() throws {
    // when
    let actual = try whenPostDogBuilder()
    
    // then
    XCTAssertNotNil(actual.id)
    XCTAssertEqual(actual.sellerID, try seller.requireID())
    XCTAssertEqual(actual.about, builder.about)
    XCTAssertEqual(actual.birthday.timeIntervalSinceNow, -1 * builder.relativeBirthday, accuracy: 5.0)
    XCTAssertEqual(actual.breederRating, defaultUser.reviewRatingAverage)
    XCTAssertEqual(actual.cost, builder.cost)
    XCTAssertEqual(actual.creation.timeIntervalSinceNow, -1 * builder.relativeCreation, accuracy: 5.0)
    XCTAssertEqual(actual.gender, builder.gender)
    let imageFullPath = directory.workDir.appending("public/\(actual.image)")
    XCTAssertTrue(fileManager.fileExists(atPath: imageFullPath))
    XCTAssertEqual(actual.name, builder.name)
  }
  
  // MARK: - Getting - Tests
  func testGETDogs_returnsAllDogsSortedByCreationDate() throws {
    // given
    let count = 3
    let expected = try givenDogsCreated(count: count).sorted { $0.creation > $1.creation }
    
    // when
    let actual = try app.getResponse(to: DogsController.rootURI, decodeTo: [Dog.Public].self)
    
    // then
    for i in (0 ..< count) {
      let actual = actual[i]
      let expected = expected[i]
      XCTAssertEqual(actual.id, expected.id)
    }
  }
  
  func testGETSeller_returnsExpectedSeller() throws {
    // given
    let dog = try givenDogsCreated(count: 1).first!
    let uri = givenDogsAPIPath(for: dog.id.uuidString, "seller")
    let expected = try seller.convertToPublic()
    
    // when
    let actual = try app.getResponse(to: uri, method: .GET, decodeTo: User.Public.self)
    
    // then
    XCTAssertEqual(actual, expected)
  }
}
