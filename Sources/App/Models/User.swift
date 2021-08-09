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

import Authentication
import FluentPostgreSQL
import Foundation
import Validation
import Vapor

public struct User: Codable {
  
  // MARK: - Identifier Properties
  public var id: UUID?
  
  // MARK: - Instance Properties
  public var about: String?
  public var email: String
  public var name: String
  public var password: String
  public var profileImageURL: URL?
  public var reviewCount: UInt
  public var reviewRatingAverage: Double
  
  // MARK: - Object Lifecycle
  public init(id: UUID? = nil,
              about: String? = nil,
              email: String,
              name: String,
              password: String,
              profileImageURL: URL? = nil) {
    self.id = id
    self.about = about
    self.email = email
    self.name = name
    self.password = password
    self.profileImageURL = profileImageURL
    self.reviewCount = 0
    self.reviewRatingAverage = Review.defaultReviewValue
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: User.CodingKeys.self)
    self.id = try container.decodeIfPresent(UUID.self, forKey: .id)
    self.about = try container.decodeIfPresent(String.self, forKey: .about)
    self.email = try container.decode(String.self, forKey: .email)
    self.name = try container.decode(String.self, forKey: .name)
    self.password = try container.decode(String.self, forKey: .password)
    self.profileImageURL = try container.decodeIfPresent(URL.self, forKey: .profileImageURL)
    self.reviewCount = try container.decodeIfPresent(UInt.self, forKey: .reviewCount) ?? 0
    self.reviewRatingAverage = try container.decodeIfPresent(Double.self, forKey: .reviewRatingAverage) ?? Review.defaultReviewValue
  }
}

extension User: Content { }
extension User: Parameter { }
extension User: PostgreSQLUUIDModel { }

// MARK: - Authentication
extension User: BasicAuthenticatable {
  public static let usernameKey: UsernameKey = \User.email
  public static let passwordKey: PasswordKey = \User.password
}

// MARK: - Buildable
extension User {
  public struct Builder: Content {
    var about: String?
    var email: String?
    var name: String?
    var password: String?
    var profileImage: File?
  }
}

// MARK: - Equatable
extension User: Equatable {
  public static func ==(lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id &&
      lhs.email == rhs.email &&
      lhs.name == rhs.name &&
      lhs.password == rhs.password
  }
}

// MARK: - PostgreSQLMigration
extension User: PostgreSQLMigration {
  
  public static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    return Database.create(self, on: connection) { builder in
      try addProperties(to: builder)
      builder.unique(on: \.email)    
    }
  }    
}

// MARK: - PublicConvertible
extension User: PublicConvertible {
  
  public struct Public: Content, Equatable {
    public let id: UUID
    public let about: String?
    public let email: String
    public let name: String
    public let profileImageURL: URL?
    public let reviewCount: UInt
    public let reviewRatingAverage: Double
  }
  
  public func convertToPublic() throws -> User.Public {
    return try User.Public(id: requireID(),
                           about: about,
                           email: email,
                           name: name,
                           profileImageURL: profileImageURL,
                           reviewCount: reviewCount,
                           reviewRatingAverage: reviewRatingAverage)
  }
}

// MARK: - Relationships
extension User {
  public var sellerReviews: Children<User, Review> {
    return children(\.sellerID)
  }
  
  public var dogs: Children<User, Dog> {
    return children(\.sellerID)
  }
}

// MARK: - TokenAuthenticatable
extension User: TokenAuthenticatable {
  public typealias TokenType = Token
}

// MARK: - Validation
extension User: Validatable {
  public static func validations() throws -> Validations<User> {
    var validations = Validations(User.self)
    try validations.add(\.email, .email)
    try validations.add(\.name, .count(1...))
    try validations.add(\.password, .count(1...))
    return validations
  }
}
