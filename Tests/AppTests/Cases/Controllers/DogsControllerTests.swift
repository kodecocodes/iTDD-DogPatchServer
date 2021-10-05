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

class DogsControllerTests: BaseControllerTestCase {
  let rootURI = "api/v1/dogs"
  
  // MARK: - GET - Tests
  func test_getAllHandler_returnsAllDogs() throws {
    // given
    let dogs = try [
      Dog(sellerID: user.requireID(),
          about: "about dog 1",
          breed: "breed 1",
          breederRating: 1.0,
          cost: 100.0,
          gender: .male,
          imageURL: "https://example.com/dog1.png",
          name: "dog 1",
          relativeBirthday: 1.year,
          relativeCreation: 10.days),
      
      Dog(sellerID: user.requireID(),
          about: "about dog 2",
          breed: "breed 2",
          breederRating: 2.0,
          cost: 200.0,
          gender: .female,
          imageURL: "https://example.com/dog2.png",
          name: "dog 2",
          relativeBirthday: 2.year,
          relativeCreation: 20.days),
      
      Dog(sellerID: user.requireID(),
          about: "about dog 3",
          breed: "breed 3",
          breederRating: 3.0,
          cost: 300.0,
          gender: .male,
          imageURL: "https://example.com/dog3.png",
          name: "dog 3",
          relativeBirthday: 3.year,
          relativeCreation: 30.days)
    ]
    try dogs.create(on: app.db).wait()    
    let expected = dogs.sorted(by: { $0.created < $1.created }).convertToPublic()
    
    // when
    try app.test(.GET, rootURI, afterResponse: { response in
      
      // then
      XCTAssertEqual(response.status, .ok)
      let actual = try response.content.decode([Dog.Public].self)
      
      guard actual.count == expected.count else {
        XCTFail("Count of actual dogs returned don't match expected count")
        return
      }
      for i in (0 ..< actual.count) {
        let actualDog = actual[i]
        let expectedDog = expected[i]
        XCTAssertEqual(actualDog.about, expectedDog.about)
        XCTAssertEqual(actualDog.birthday, expectedDog.birthday, accuracy: 1.0)
        XCTAssertEqual(actualDog.breed, expectedDog.breed)
        XCTAssertEqual(actualDog.breederRating, expectedDog.breederRating)
        XCTAssertEqual(actualDog.cost, expectedDog.cost)
        XCTAssertEqual(actualDog.created, expectedDog.created, accuracy: 1.0)
        XCTAssertEqual(actualDog.gender, expectedDog.gender)
        XCTAssertEqual(actualDog.imageURL, expectedDog.imageURL)
        XCTAssertEqual(actualDog.name, expectedDog.name)
      }
    })
  }
  
  // MARK: - POST - Tests
//  func test_postHandler_createsDog() throws {
//    // given
//    let builder = Dog.Builder(about: "about",
//                              breed: "breed",
//                              cost: 100.0,
//                              gender: .female,
//                              imageURL: "https://example.com/dog1.png",
//                              name: "name",
//                              relativeBirthday: 5.years,
//                              relativeCreation: 6.months)
//    let birthday = Date(timeIntervalSinceNow: -1 * builder.relativeBirthday)
//    let created = Date(timeIntervalSinceNow: -1 * builder.relativeCreation)
//    
//    // when
//    try app.test(.POST, rootURI, loginCredentials: (user.email, rawPassword), beforeRequest: { request in
//      try request.content.encode(builder)
//      
//    }, afterResponse: { response in
//      
//      // then
//      XCTAssertEqual(response.status, .ok)
//      
//      let actual = try response.content.decode(Dog.Public.self)
//      XCTAssertEqual(actual.about, builder.about)
//      XCTAssertEqual(actual.breed, builder.breed)
//      XCTAssertEqual(actual.cost, builder.cost)
//      XCTAssertEqual(actual.gender, builder.gender)
//      XCTAssertEqual(actual.imageURL, builder.imageURL)
//      XCTAssertEqual(actual.name, builder.name)
//      XCTAssertEqual(actual.birthday, birthday.timeIntervalSince1970, accuracy: 1.0)
//      XCTAssertEqual(actual.created, created.timeIntervalSince1970, accuracy: 1.0)
//      
//      let dogs = try Dog.query(on: app.db).all().wait()
//      XCTAssertEqual(dogs.count, 1)
//    })
//  }
}
