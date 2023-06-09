//
//  File.swift
//  
//
//  Created by Benjamin Nassler on 05/07/2021.
//

import Vapor


extension URI {
  
  /**
   
   When an URI is created with invalid input such as a space, it will still return a URI.
   If client then attempts a request it will crash the app. Here we throw instead
   
   */
  public init(withUnsafeString string: String) throws {
    guard URL(string: string) != nil else {
      throw Abort(.badRequest, reason: "Invalid URL")
    }
    self.init(string: string)
  }
}
