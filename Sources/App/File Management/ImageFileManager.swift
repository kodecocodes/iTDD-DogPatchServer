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

import Foundation
import Vapor

public class ImageFileManager {
  
  // MARK: - Static Properties
  public static let `default` = ImageFileManager()
  
  // MARK: - Instance Properties
  public let directory: DirectoryConfig
  public let fileManager: FileManager
  
  // MARK: - Object Lifecycle
  public init(directory: DirectoryConfig = .detect(), fileManager: FileManager = FileManager()) {
    self.directory = directory
    self.fileManager = fileManager
  }
  
  // MARK: - Saving
  public func imageURL(forPublicPath publicPath: String) -> URL {
    let host = Environment.get("DOMAIN_URL") ?? "http://localhost:8080"
    let baseURL = URL(string: host)!
    let url = URL(string: publicPath, relativeTo: baseURL)!
    return url
  }
  
  public func saveImage(for user: User, file: File, inSubdirectory subdirectoryName: String) throws -> URL {
    
    var publicPath = try publicDirectory(for: user).appending("\(subdirectoryName)/")
    var fullPath = directory.workDir.appending("public/\(publicPath)")
    
    if !fileManager.fileExists(atPath: fullPath) {
      try fileManager.createDirectory(atPath: fullPath, withIntermediateDirectories: true, attributes: nil)
    }
    guard let fileExtension = file.ext else {
      throw Abort(.badRequest, reason: "Image is missing a path extension")
    }
    let fileName = "\(UUID().uuidString).\(fileExtension)"
    publicPath.append(fileName)
    fullPath.append(fileName)
    
    let fileURL = URL(fileURLWithPath: fullPath)
    try file.data.write(to: fileURL)
    
    return imageURL(forPublicPath: publicPath)
  }
  
  public func publicDirectory(for user: User) throws -> String {
    return try "users/\(user.requireID().uuidString)/"
  }
}

// MARK: - DogImageFileManager
extension ImageFileManager: DogImageManager {
  public func saveDogImage(for user: User, file: File) throws -> URL {
    return try saveImage(for: user, file: file, inSubdirectory: "images")
  }
}

// MARK: - UserProfileImageManager
extension ImageFileManager: UserProfileImageManager {
  
  public func saveProfileImage(for user: User, with file: File) throws -> URL {
    return try saveImage(for: user, file: file, inSubdirectory: "profile-images")
  }
}
