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

public final class Review: Codable {
  
  // MARK: - Static Properties
  public static let minReviewValue = 1.0
  public static let maxReviewValue = 5.0
  public static let defaultReviewValue = (maxReviewValue - 0.5)
  
  // MARK: - Identifier Properties
  public var id: UUID?
  public var creatorID: User.ID
  public var sellerID: User.ID
  
  // MARK: - Instance Properties
  public var details: String
  public var rating: Double
  public var title: String
  
  // MARK: - Object Lifecycle
  public init(id: UUID? = nil,
              creatorID: User.ID,
              sellerID: User.ID,
              details: String,
              rating: Double,
              title: String) {
    self.id = id
    self.creatorID = creatorID
    self.sellerID = sellerID
    self.details = details
    self.rating = rating
    self.title = title
  }
}

extension Review: Content { }
extension Review: Parameter { }
extension Review: PostgreSQLUUIDModel { }

// MARK: - Buildable
extension Review {
  public struct Builder: Content {
    public let title: String
    public let details: String
    public let rating: Double
  }
}

// MARK: - Migration
extension Review: Migration {
  public static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    return Database.create(self, on: connection) { builder in
      try addProperties(to: builder)
      builder.reference(from: \.creatorID, to: \User.id)
      builder.reference(from: \.sellerID, to: \User.id)
    }
  }
}

// MARK: - Validation
extension Review: Validatable {
  public static func validations() throws -> Validations<Review> {
    var validations = Validations(Review.self)
    try validations.add(\.rating, .range(Review.minReviewValue...Review.maxReviewValue))
    return validations
  }
}
