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
import Fluent
import Vapor

public struct DogsController: RouteCollection {
  
  // MARK: - Static Properties
  public static let rootURI = "api/v1/dogs/"
  
  // MARK: - Instance Properties
  internal let fileManager: DogImageManager
  
  // MARK: - Object Lifecycle
  public init(fileManager: DogImageManager = ImageFileManager.default) {
    self.fileManager = fileManager
  }
  
  public func boot(router: Router) throws {
    let routes = router.grouped(DogsController.rootURI)
    routes.get(use: getAllHandler)
    routes.get(Dog.parameter, "seller", use: getSellerHandler)
    
    let tokenAuthGroup = routes.grouped(User.tokenAuthMiddleware(), User.guardAuthMiddleware())
    tokenAuthGroup.post(Dog.Builder.self, use: createHandler)
  }
  
  // MARK: - Creating
  public func createHandler(_ req: Request, builder: Dog.Builder) throws -> Future<Dog.Public> {
    let seller = try req.requireAuthenticated(User.self)
    let dog = try Dog(id: nil,
                      sellerID: seller.requireID(),
                      about: builder.about,
                      breed: builder.breed,
                      breederRating: seller.reviewRatingAverage,
                      cost: builder.cost,
                      gender: builder.gender,
                      imageURL: builder.imageURL,
                      name: builder.name,
                      relativeBirthday: builder.relativeBirthday,
                      relativeCreation: builder.relativeCreation)
    return try dog.save(on: req).convertToPublic()
  }
  
  // MARK: - Getting
  public func getAllHandler(_ req: Request) throws -> Future<[Dog.Public]> {
    return try Dog.query(on: req).sort(\.created, .ascending).all().convertToPublic()
  }
  
  public func getSellerHandler(_ req: Request) throws -> Future<User.Public> {
    return try req.parameters.next(Dog.self).flatMap(to: User.Public.self) { dog in
      try dog.seller.get(on: req).convertToPublic()
    }
  }
}
