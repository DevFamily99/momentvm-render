//
//  SalesforceController.swift
//  App
//
//  Created by Benjamin Nassler on 16/08/2019.
//

import Vapor
import JSON

final class SalesforceController: TokenAccessor {
  
  func get(_ req: Request) throws -> EventLoopFuture<ClientResponse> {
    print("SalesforceController get(_:)")
    return self.getToken(req: req).tryFlatMap { token -> EventLoopFuture<ClientResponse> in
      print("from headers")
      let (path, targetHost) = try self.fromHeaders(req: req)
      print("url: \(path) targetHost: \(targetHost)")
      let url = try URI(withUnsafeString: (targetHost + path))
      return req.client.get(url, headers: ["Authorization" : "Bearer \(token.token)"])
    }
  }
  
  func post(_ req: Request) throws -> EventLoopFuture<ClientResponse> {
    return self.getToken(req: req).tryFlatMap { token in
      let request = try req.content.decode(JSON.self)
      let (path, targetHost) = try self.fromHeaders(req: req)
      let url = try URI(withUnsafeString: (targetHost + path))
      return req.client.post(url, headers: ["Authorization" : "Bearer \(token.token)"]) { requestBody in
        return try requestBody.content.encode(request)
      }
    }
  }
  
  func put(_ req: Request) throws -> EventLoopFuture<ClientResponse> {
    return self.getToken(req: req).tryFlatMap { token in
      let request = try req.content.decode(JSON.self)
      let (path, targetHost) = try self.fromHeaders(req: req)
      let response = try req.client.put(URI(withUnsafeString: targetHost + path),
                                        headers: ["Authorization" : "Bearer \(token.token)"]) { requestBody in
        return try requestBody.content.encode(request)
      }
      return response.map() { resp in
        // print(resp.content)
        // print(resp.debugDescription)
        print(resp.status.code)
        return resp
      }
      
    }
  }
  
  /**
   Parses request headers to extract path and targetHost, if fails will throw
   */
  private func fromHeaders(req: Request) throws -> (path: String, targetHost: String) {
    guard let path = req.headers.first(name: "Ressource-Path") else {
      throw Abort(.badRequest, reason: "Ressource-Path header missing")
    }
    guard var targetHost = req.headers.first(name: "Target-Host") else {
      throw Abort(.badRequest, reason: "target-Host header missing")
    }
    targetHost = "https://" + targetHost
    return (path, targetHost)
  }
}

extension JSON: Content {}
