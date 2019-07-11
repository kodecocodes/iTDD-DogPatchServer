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

import Crypto
import Multipart
import Vapor

public struct UsersController: RouteCollection {
  
  // MARK: - Static Properties
  public static let rootURI = "api/v1/users/"
  
  // MARK: - Instance Properties
  internal let fileManager: UserProfileImageManager
  
  // MARK: - Object Lifecycle
  public init(fileManager: UserProfileImageManager = ImageFileManager.default) {
    self.fileManager = fileManager
  }
  
  public func boot(router: Router) throws {
    let routes = router.grouped(UsersController.rootURI)
    routes.get(User.parameter, use: getHandler)
    routes.get("search", use: searchHandler)    
    routes.post(User.self, use: createHandler)
    
    let tokenAuthGroup = routes.grouped(User.tokenAuthMiddleware(), User.guardAuthMiddleware())
    tokenAuthGroup.put(User.Builder.self, use: updateHandler)
    tokenAuthGroup.post(Review.Builder.self, at: User.parameter, "reviews", use: createReview)
  }
  
  // MARK: - Creating
  public func createHandler(_ req: Request, user: User) throws -> Future<User.Public> {
    var user = user
    do {
      try user.validate()
    } catch {
      throw Abort(.badRequest, reason: "Email, name and password are required")
    }
    user.email = user.email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    user.password = try BCrypt.hash(user.password)
    
    return userExistsForEmail(user.email, req).flatMap(to: User.Public.self) { emailAlreadyTaken in
      guard !emailAlreadyTaken else { throw Abort(.conflict, reason: "Email is already registered") }
      return try user.save(on: req).convertToPublic()
    }
  }
  
  // MARK: - Reviewing
  public func createReview(_ req: Request, builder: Review.Builder) throws -> Future<Review> {
    let creatorID = try req.requireAuthenticated(User.self).requireID()
    
    return try req.parameters.next(User.self).flatMap(to: Review.self) { seller in
      let review = try Review(id: nil,
                              creatorID: creatorID,
                              sellerID: seller.requireID(),
                              details: builder.details,
                              rating: builder.rating,
                              title: builder.title)
      return try map(to: Review.self,
                     self.updateSellerReviewRatingAverage(seller, builder.rating, req),
                     review.save(on: req)) { _, review in return review }
    }
  }
  
  private func updateSellerReviewRatingAverage(_ seller: User, _ rating: Double, _ req: Request) throws -> Future<User> {
    var seller = seller
    if seller.reviewCount == 0 {
      seller.reviewRatingAverage = 0 // defaults to "5" for users with no reviews, so here, this must be reset
    }
    seller.reviewCount += 1
    let count = Double(seller.reviewCount)
    
    let average = seller.reviewRatingAverage + ((rating - seller.reviewRatingAverage) / count)
    seller.reviewRatingAverage = average
    
    return try map(updateSellerDogsBreedRating(seller, average, req),
                   seller.save(on: req)) { _, seller in return seller}
  }
  
  private func updateSellerDogsBreedRating(_ seller: User, _ average: Double, _ req: Request) throws -> Future<[Dog]> {
    return try seller.dogs.query(on: req).all().flatMap(to: [Dog].self) { dogs in            
      var saveResults: [Future<Dog>] = []
      for var dog in dogs {
        dog.breederRating = average
        saveResults.append(dog.save(on: req))
      }
      return saveResults.flatten(on: req)
    }
  }
  
  // MARK: - Searching
  public func getHandler(_ req: Request) throws -> Future<User.Public> {
    return try req.parameters.next(User.self).convertToPublic()
  }
  
  public func searchHandler(_ req: Request) throws -> Future<User.Public> {
    guard let email = req.query[String.self, at: "email"] else {
      throw Abort(.badRequest, reason: "Email query parameter is required")
    }
    return User.query(on: req).filter(\User.email, .equal, email).first().map(to: User.Public.self) { user in
      guard let user = user else {
        throw Abort(.notFound)
      }
      return try user.convertToPublic()
    }
  }
  
  // MARK: - Updating
  public func updateHandler(_ req: Request, update: User.Builder) throws -> Future<User.Public> {
    var user = try req.requireAuthenticated(User.self)
    
    var update = update
    if let password = update.password {
      update.password = try BCrypt.hash(password)
    }
    
    update.email = update.email?.lowercased()
    guard let email = update.email else {
      return try updateUserDetails(&user, update, req)
    }
    
    return userExistsForEmail(email, req).flatMap(to: User.Public.self) { emailAlreadyTaken in
      guard !emailAlreadyTaken else {
        throw Abort(.conflict, reason: "Email is already registered")
      }
      return try self.updateUserDetails(&user, update, req)
    }
  }
  
  private func updateUserDetails(_ user: inout User,
                                 _ update: User.Builder,
                                 _ req: Request) throws -> Future<User.Public> {
    if let about = update.about {
      user.about = about
    }
    if let email = update.email {
      user.email = email
    }
    if let name = update.name {
      user.name = name
    }
    if let password = update.password {
      user.password = password
    }
    if let profileImage = update.profileImage {
      user.profileImageURL = try fileManager.saveProfileImage(for: user, with: profileImage)
    }
    return try user.save(on: req).convertToPublic()
  }
  
  private func userExistsForEmail(_ email: String, _ req: Request) -> Future<Bool> {
    return User.query(on: req).filter(\User.email, .equal, email).first().map(to: Bool.self) { $0 != nil }
  }
}
