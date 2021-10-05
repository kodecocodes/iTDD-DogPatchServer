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

import Vapor

struct UsersController: RouteCollection {
    
  // MARK: - RouteCollection
  func boot(routes: RoutesBuilder) throws {
    let usersRoute = routes.grouped("api", "v1", "users")
    usersRoute.get(":userID", use: getHandler)
    usersRoute.get("search", use: getSearchByEmailHandler)
    usersRoute.post(use: postHandler)

    let basicAuthGroup = usersRoute.grouped(User.authenticator())
    basicAuthGroup.post("login", use: postLoginHandler)
    
    let tokenAuthGroup = usersRoute.grouped(Token.authenticator())
    tokenAuthGroup.put(use: putHandler)
  }
  
  // MARK: - GET
  func getHandler(_ req: Request) -> EventLoopFuture<User.Public> {
    let id = req.parameters.get("userID") as UUID?
    return User.find(id, on: req.db)
      .unwrap(or: Abort(.notFound))
      .convertToPublic()
  }
  
  func getSearchByEmailHandler(_ req: Request) throws -> EventLoopFuture<User.Public> {
    guard let searchTerm = req.query[String.self, at: "email"] else {
      throw Abort(.badRequest)
    }
    return User.query(on: req.db)
      .filter(\.$email, .custom("ilike"), searchTerm)
      .first()
      .unwrap(or: Abort(.notFound))
      .convertToPublic()
  }
  
  // MARK: - POST
  func postHandler(_ req: Request) throws -> EventLoopFuture<User.Public> {
    let builder = try req.content.decode(User.Builder.self)
    let user = try User(builder: builder)
    return user.save(on: req.db).map { user.convertToPublic() }
  }
  
  func postLoginHandler(_ req: Request) throws -> EventLoopFuture<Token> {
    let user = try req.auth.require(User.self)
    let token = try Token.generate(for: user)
    return token.save(on: req.db).map { token }
  }
  
  // MARK: - PUT
  func putHandler(_ req: Request) throws -> EventLoopFuture<User.Public> {
    let userID = try req.auth.require(User.self).requireID()
    let updateData = try req.content.decode(User.Update.self)
    return User.find(userID, on: req.db)
      .unwrap(or: Abort(.notFound))
      .flatMapThrowing { user -> User in
        if let about = updateData.about {
          user.about = about
        }
        if let email = updateData.email {
          user.email = email
        }
        if let password = updateData.password {
          user.password = try Bcrypt.hash(password)
        }
        if let name = updateData.name {
          user.name = name
        }
        if let profileImageURL = updateData.profileImageURL {
          user.profileImageURL = profileImageURL
        }
        return user
      }
      .flatMap { user in
        user.save(on: req.db).map { user.convertToPublic() }
    }
  }
}
