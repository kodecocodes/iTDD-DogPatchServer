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
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Fluent
import Vapor

public final class Dog: Model, Content {
  public static let schema = "dogs"
    
  // MARK: - Instance Properties
  @ID public var id: UUID?
  @Field(key: "about") public var about: String
  @Field(key: "birthday") public var birthday: Date
  @Field(key: "breed") public var breed: String
  @Field(key: "breederRating") public var breederRating: Double
  @Field(key: "cost") public var cost: Decimal
  @Field(key: "created") public var created: Date
  @Field(key: "gender") public var gender: Gender
  @Field(key: "imageURL") public var imageURL: String
  @Field(key: "name") public var name: String
  
  // MARK: - Relationships
  @Parent(key: "sellerID") var seller: User
  
  // MARK: - Object lifecycle
  public init() { }
  
  public init(id: UUID? = nil,
              sellerID: User.IDValue,
              about: String,
              breed: String,
              breederRating: Double,
              cost: Decimal,
              gender: Gender,
              imageURL: String,
              name: String,
              relativeBirthday: TimeInterval,
              relativeCreation: TimeInterval) {
    self.id = id
    self.$seller.id = sellerID
    
    self.about = about
    self.breed = breed
    self.breederRating = breederRating
    self.cost = cost
    self.gender = gender
    self.imageURL = imageURL
    self.name = name
    
    // Here, we cheat to make sure the birthday and creation are always "pretty recent" ;P
    self.birthday = Date(timeIntervalSinceNow: -1 * relativeBirthday)
    self.created = Date(timeIntervalSinceNow: -1 * relativeCreation)
  }
}

// MARK: - Builder
extension Dog {
  public struct Builder: Content {
    public let about: String
    public let breed: String
    public let cost: Decimal
    public let gender: Gender
    public let imageURL: String
    public let name: String
    public let relativeBirthday: TimeInterval
    public let relativeCreation: TimeInterval
  }
  
  public convenience init(builder: Dog.Builder, seller: User) throws {
    try self.init(sellerID: seller.requireID(),
                  about: builder.about,
                  breed: builder.breed,
                  breederRating: seller.reviewRatingAverage,
                  cost: builder.cost,
                  gender: builder.gender,
                  imageURL: builder.imageURL,
                  name: builder.name,
                  relativeBirthday: builder.relativeBirthday,
                  relativeCreation: builder.relativeCreation)
  }
}

// MARK: - Public
extension Dog: PublicConvertible {

  public final class Public: Content {
    // Instance Properties
    public var id: UUID?
    public var sellerID: UUID?
    
    public var about: String
    public var birthday: TimeInterval
    public var breed: String
    public var breederRating: Double
    public var cost: Decimal
    public var created: TimeInterval
    public var gender: Gender
    public var imageURL: String
    public var name: String
    
    public init(from dog: Dog) {
      self.id = dog.id
      self.sellerID = dog.$seller.id
      self.about = dog.about
      self.birthday = dog.birthday.timeIntervalSince1970
      self.breed = dog.breed
      self.breederRating = dog.breederRating
      self.cost = dog.cost
      self.created = dog.created.timeIntervalSince1970
      self.gender = dog.gender
      self.imageURL = dog.imageURL
      self.name = dog.name
    }
  }

  public func convertToPublic() -> Dog.Public {
    return Dog.Public(from: self)
  }
}
