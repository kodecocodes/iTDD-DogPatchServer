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

public final class User: Model, Content {  
  public static let schema = "users"
    
  // MARK: - Fields
  @ID public var id: UUID?
  @Field(key: "about") public var about: String?
  @Field(key: "email") public var email: String
  @Field(key: "name") public var name: String
  @Field(key: "password") public var password: String
  @Field(key: "profileImageURL") public var profileImageURL: String?
  @Field(key: "reviewCount") public var reviewCount: Int
  @Field(key: "reviewRatingAverage") public var reviewRatingAverage: Double
  
  // MARK: - Relationships
  @Children(for: \.$seller) var dogs: [Dog]  
  
  // MARK: - Object Lifecycle
  public init() { }
  
  public init(id: UUID? = nil,
              about: String? = nil,
              email: String,
              name: String,
              password: String,
              profileImageURL: String? = nil,
              reviewCount: Int = 0,
              reviewRatingAverage: Double = 0) {
    self.id = id
    self.about = about
    self.email = email
    self.name = name
    self.password = password      
    self.profileImageURL = profileImageURL
    self.reviewCount = reviewCount
    self.reviewRatingAverage = reviewRatingAverage
  }
}

// MARK: - Builder
extension User {
  public final class Builder: Content {
    public let about: String?
    public let email: String
    public let name: String
    public let password: String
    public let profileImageURL: String?
    
    public init(about: String? = nil,
                email: String,
                name: String,
                password: String,
                profileImageURL: String? = nil) {
      self.about = about
      self.email = email
      self.password = password
      self.name = name
      self.profileImageURL = profileImageURL
    }
  }
  
  public convenience init(builder: User.Builder) throws {
    let password = try Bcrypt.hash(builder.password)
    self.init(about: builder.about,
              email: builder.email,
              name: builder.name,
              password: password,
              profileImageURL: builder.profileImageURL,
              reviewCount: 0,
              reviewRatingAverage: 0)
  }
}

// MARK: - ModelAuthenticatable
extension User: ModelAuthenticatable {
  public static let usernameKey = \User.$email
  public static let passwordHashKey = \User.$password
  
  public func verify(password: String) throws -> Bool {
    return try Bcrypt.verify(password, created: self.password)
  }
}

// MARK: - PublicConvertible
extension User: PublicConvertible {
  
  public final class Public: Content {    
    public let id: UUID?
    public let about: String?
    public let email: String
    public let name: String
    public let profileImageURL: String?
    public let reviewCount: Int
    public let reviewRatingAverage: Double
    
    public init(from user: User) {
      self.id = user.id
      self.about = user.about
      self.email = user.email
      self.name = user.name
      self.profileImageURL = user.profileImageURL
      self.reviewCount = user.reviewCount
      self.reviewRatingAverage = user.reviewRatingAverage
    }
  }
  
  public func convertToPublic() -> User.Public {
    return User.Public(from: self)
  }
}

// MARK: - Update
extension User {
  
  public final class Update: Content {
    public let about: String?
    public let email: String?
    public let password: String?
    public let name: String?
    public let profileImageURL: String?
    
    public init(about: String? = nil,
                email: String? = nil,
                password: String? = nil,
                name: String? = nil,
                profileImageURL: String? = nil) {
      self.about = about
      self.email = email
      self.password = password
      self.name = name
      self.profileImageURL = profileImageURL
    }
  }
}
