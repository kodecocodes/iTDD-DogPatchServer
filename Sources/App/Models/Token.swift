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
import Vapor

public struct Token: Codable {
  public var id: UUID?
  public var token: String
  public var userID: User.ID
  
  public init(id: UUID? = nil, token: String, userID: User.ID) {
    self.id = id
    self.token = token
    self.userID = userID
  }
}

extension Token: Content { }
extension Token: PostgreSQLUUIDModel { }

// MARK: - Authentication.Token
extension Token: Authentication.Token {
  public static let userIDKey: UserIDKey = \Token.userID
  public typealias UserType = User
}

// MARK: - BearerAuthenticatable
extension Token: BearerAuthenticatable {
  public static let tokenKey: TokenKey = \Token.token
}

// MARK: - Convenience Constructors
extension Token {
  public static func make(from user: User) throws -> Token {
    return try Token(
      token: try CryptoRandom().generateData(count: 16).base64EncodedString(),
      userID: user.requireID())
  }
}

// MARK: - Migration
extension Token: Migration {
  public static func prepare(on connection: PostgreSQLConnection) ->
    Future<Void> {
      return Database.create(self, on: connection) { builder in
        try addProperties(to: builder)
        builder.reference(from: \.userID, to: \User.id)
      }
  }
}

// MARK: - PublicConvertible
extension Token: PublicConvertible {
  public struct Public: Content, Equatable {
    public var token: String
    public var userID: User.ID
  }
  
  public func convertToPublic() throws -> Public {
    return Public(token: token, userID: userID)
  }
}
