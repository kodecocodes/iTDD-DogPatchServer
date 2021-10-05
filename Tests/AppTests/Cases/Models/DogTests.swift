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

final class DogTests: BaseTestCase {
  var about: String!
  var breed: String!
  var breederRating: Double!
  var cost: Decimal!
  var gender: Gender!
  var imageURL: String!
  var dogName: String!
  var relativeBirthday: TimeInterval!
  var relativeCreation: TimeInterval!
  var seller: User!
  var sut: Dog!
  
  var birthday: Date {
    return Date(timeIntervalSinceNow: -1 * relativeBirthday)
  }

  var created: Date {
    return Date(timeIntervalSinceNow: -1 * relativeCreation)
  }
  
  // MARK: - Test lifecycle
  override func setUpWithError() throws {
    try super.setUpWithError()
    
    about = "about"
    breed = "breed"
    breederRating = 4.5
    cost = Decimal(42.99)
    gender = .female
    imageURL = "https://example.com/dog.png"
    dogName = "name"
    relativeBirthday = 1.year
    relativeCreation = 8.months
    seller = try User.create(on: app.db)
        
    sut = try Dog(sellerID: seller.requireID(),
                  about: about,
                  breed: breed,
                  breederRating: breederRating,
                  cost: cost,
                  gender: gender,
                  imageURL: imageURL,
                  name: dogName,
                  relativeBirthday: relativeBirthday,
                  relativeCreation: relativeCreation)
    try sut.save(on: app.db).wait()    
  }
  
  override func tearDownWithError() throws {
    about = nil
    breed = nil
    breederRating = nil
    cost = nil
    gender = nil
    imageURL = nil
    dogName = nil
    relativeBirthday = nil
    relativeCreation = nil
    seller = nil
    sut = nil
    try super.tearDownWithError()
  }
  
  // MARK: - Model - Tests
  func test_schema_setToDogs() {
    XCTAssertEqual(Dog.schema, "dogs")
  }
  
  // MARK: - Object lifecycle - Tests
  func test_init_setsSellerId() {
    try XCTAssertEqual(sut.$seller.id, seller.requireID())
  }
  
  func test_init_setsAbout() {
    XCTAssertEqual(sut.about, about)
  }
  
  func test_init_setsBreed() {
    XCTAssertEqual(sut.breed, breed)
  }
  
  func test_init_setsBreederRating() {
    XCTAssertEqual(sut.breederRating, breederRating)
  }
  
  func test_init_setsCost() {
    XCTAssertEqual(sut.cost, cost)
  }
  
  func test_init_setsGender() {
    XCTAssertEqual(sut.gender, gender)
  }
  
  func test_init_setsImageURL() {
    XCTAssertEqual(sut.imageURL, imageURL)
  }
  
  func test_init_setsName() {
    XCTAssertEqual(sut.name, dogName)
  }
  
  func test_init_setsCreated() {
    XCTAssertEqual(sut.created.timeIntervalSince1970,
                   created.timeIntervalSince1970,
                   accuracy: 1.0)
  }
  
  func test_init_setsBirthday() {
    XCTAssertEqual(sut.birthday.timeIntervalSince1970,
                   birthday.timeIntervalSince1970,
                   accuracy: 1.0)
  }
  
  func test_save_setsId() {
    XCTAssertNotNil(sut.id)
  }
  
  // MARK: - Builder - Tests
  func test_initBuilderSeller_createsExpectedDog() throws {
    let builder = Dog.Builder(about: about,
                              breed: breed,
                              cost: cost,
                              gender: gender,
                              imageURL: imageURL,
                              name: dogName,
                              relativeBirthday: relativeBirthday,
                              relativeCreation: relativeCreation)
    
    let dog = try Dog(builder: builder, seller: seller)
        
    try XCTAssertEqual(dog.$seller.id, seller.requireID())
    XCTAssertEqual(dog.about, about)
    XCTAssertEqual(dog.birthday.timeIntervalSince1970, birthday.timeIntervalSince1970, accuracy: 1.0)
    XCTAssertEqual(dog.breed, breed)
    XCTAssertEqual(dog.breederRating, breederRating)
    XCTAssertEqual(dog.cost, cost)
    XCTAssertEqual(dog.created.timeIntervalSince1970, created.timeIntervalSince1970, accuracy: 1.0)
    XCTAssertEqual(dog.gender, gender)
    XCTAssertEqual(dog.imageURL, imageURL)
    XCTAssertEqual(dog.name, dogName)
  }
  
  // MARK: - Public - Tests
  func test_DogPublic_init_createsExpectedDogPublic() {
    let publicDog = Dog.Public(from: sut)
    
    XCTAssertEqual(publicDog.id, sut.id)
    XCTAssertEqual(publicDog.sellerID, sut.$seller.id)
    XCTAssertEqual(publicDog.about, sut.about)
    XCTAssertEqual(publicDog.birthday, sut.birthday.timeIntervalSince1970)
    XCTAssertEqual(publicDog.breed, sut.breed)
    XCTAssertEqual(publicDog.breederRating, sut.breederRating)
    XCTAssertEqual(publicDog.cost, sut.cost)
    XCTAssertEqual(publicDog.created, sut.created.timeIntervalSince1970)
    XCTAssertEqual(publicDog.gender, sut.gender)
    XCTAssertEqual(publicDog.imageURL, sut.imageURL)
    XCTAssertEqual(publicDog.name, sut.name)
  }
  
  func test_convertToPublic_createsExpectedDogPublic() {
    let publicDog = sut.convertToPublic()
    
    XCTAssertEqual(publicDog.id, sut.id)
    XCTAssertEqual(publicDog.sellerID, sut.$seller.id)
    XCTAssertEqual(publicDog.about, sut.about)
    XCTAssertEqual(publicDog.birthday, sut.birthday.timeIntervalSince1970)
    XCTAssertEqual(publicDog.breed, sut.breed)
    XCTAssertEqual(publicDog.breederRating, sut.breederRating)
    XCTAssertEqual(publicDog.cost, sut.cost)
    XCTAssertEqual(publicDog.created, sut.created.timeIntervalSince1970)
    XCTAssertEqual(publicDog.gender, sut.gender)
    XCTAssertEqual(publicDog.imageURL, sut.imageURL)
    XCTAssertEqual(publicDog.name, sut.name)
  }
}
