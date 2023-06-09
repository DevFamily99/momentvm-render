//
//  Extensions.swift
//  App
//
//  Created by Benjamin Nassler on 23.04.18.
//

import Foundation
import Vapor
// import Authentication

extension Request {
  
  /// Returns true if request is properly authenticated
  var authenticated: Bool {
    get {
      guard let basicAuthorization = self.headers.basicAuthorization else {
        return false
      }
      let user = Environment.get("OWNUSER") ?? "user"
      let password = Environment.get("OWNPASS") ?? "pass"
      if user == basicAuthorization.username && password == basicAuthorization.password {
        return true
      } else {
        return false
      }
    }
  }
  
  var hostExists: Bool {
    guard let _ = self.headers.first(name: "Target-Host") else {
      return false
    }
    return true
  }
  
  /// The host of the SFCC instance which should be published to
  /// Header: Target-Host
  var targetHost: String {
    guard let host = self.headers.first(name: "Target-Host") else {
      print("Error: Target-Host missing")
      return ""
    }
    return host
  }
  
  var defaultLibraryExists: Bool {
    guard let _ = self.headers.first(name: "Default-Library") else {
      return false
    }
    return true
  }
  
  /// A content library can exist per site, so this is the implementation for a shared one
  /// Header: Default-Library
  var defaultLibrary: String {
    guard let library = self.headers.first(name: "Default-Library") else {
      return ""
    }
    return library
  }
  
  /// OCAPI Client ID
  var clientID: String {
    guard let host = self.headers.first(name: "Client-ID") else {
      return ""
    }
    return host
  }
  
  var clientIDExists: Bool {
    guard let _ = self.headers.first(name: "Client-ID") else {
      return false
    }
    return true
  }
 
  /// OCAPI Client ID
  var clientIdLastDigits: String {
    guard let host = self.headers.first(name: "Client-ID") else {
      return ""
    }
    return String(host.suffix(4))
  }
  
}

