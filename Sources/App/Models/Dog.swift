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

import FluentPostgreSQL
import Vapor

public struct Dog: Codable {
  
  // MARK: - Identifier Properties
  public var id: UUID?
  public var sellerID: User.ID
  
  // MARK: - Instance Properties
  public var about: String
  public var birthday: Date
  public var breed: String
  public var breederRating: Double
  public var cost: Decimal
  public var created: Date
  public var gender: Gender
  public var imageURL: URL
  public var name: String
  
  init(id: UUID? = nil,
       sellerID: User.ID,
       about: String,
       breed: String,
       breederRating: Double,
       cost: Decimal,
       gender: Gender,
       imageURL: URL,
       name: String,
       relativeBirthday: TimeInterval,
       relativeCreation: TimeInterval) {
    self.id = id
    self.sellerID = sellerID
    self.about = about
    self.birthday = Date(timeIntervalSinceNow: -1 * relativeBirthday)
    self.breed = breed
    self.breederRating = breederRating
    self.cost = cost
    self.created = Date(timeIntervalSinceNow: -1 * relativeCreation)
    self.gender = gender
    self.imageURL = imageURL
    self.name = name
  }
}

extension Dog: Content { }
extension Dog: Parameter { }
extension Dog: PostgreSQLUUIDModel { }

// MARK: - Builder
extension Dog {
  public struct Builder: Content {
    public let about: String
    public let breed: String
    public let cost: Decimal
    public let gender: Gender
    public let imageURL: URL
    public let name: String
    public let relativeBirthday: TimeInterval
    public let relativeCreation: TimeInterval
  }
}

// MARK: - Migration
extension Dog: Migration {
  public static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    return Database.create(self, on: connection) { builder in
      try addProperties(to: builder)
      builder.reference(from: \.sellerID, to: \User.id)
    }
  }
}

// MARK: - Public
extension Dog: PublicConvertible {
  
  public struct Public: Content, Equatable {    
    // Identifier Properties
    public var id: UUID
    public var sellerID: User.ID
    
    // Instance Properties
    public var about: String
    public var birthday: TimeInterval
    public var breed: String
    public var breederRating: Double
    public var cost: Decimal
    public var created: TimeInterval
    public var gender: Gender
    public var imageURL: URL
    public var name: String
  }
  
  public func convertToPublic() throws -> Dog.Public {        
    return try Dog.Public(id: requireID(),
                          sellerID: sellerID,
                          about: about,
                          birthday: floor(birthday.timeIntervalSinceReferenceDate),
                          breed: breed,
                          breederRating: breederRating,
                          cost: cost,
                          created: floor(created.timeIntervalSinceReferenceDate),
                          gender: gender,
                          imageURL: imageURL,
                          name: name)
  }
}

// MARK: - Relationships
extension Dog {
  var seller: Parent<Dog, User> {
    return parent(\.sellerID)
  }
}
