//
//  TokenMiddleWare.swift
//  App
//
//  Created by Benjamin Nassler on 30/05/2019.
//
import Vapor

/**
 Makes sure that Client-ID and Client-Secret are set on the request header
 and makes sure a valid token exists
 */
struct TokenMiddleware: Middleware, TokenAccessor {
  
  func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
    guard let _ = request.headers.first(name: "Client-ID") else {
      let response = Response(status: .forbidden, version: request.version, headers: [:], body: "missing 'Client-ID' in header")
      return request.eventLoop.makeSucceededFuture(response)
    }
    guard request.clientID.isEmpty == false else {
      let response = Response(status: .forbidden, version: request.version, headers: [:], body: "missing 'Client-ID' in header is empty")
      return request.eventLoop.makeSucceededFuture(response)
    }
    guard let _ = request.headers.first(name: "Client-Secret") else {
      let response = Response(status: .forbidden, version: request.version, headers: [:], body: "missing 'Client-Secret' in header")
      return request.eventLoop.makeSucceededFuture(response)
    }
    return self.getToken(req: request).flatMap { _ in
      return next.respond(to: request)
    }
  }
}
