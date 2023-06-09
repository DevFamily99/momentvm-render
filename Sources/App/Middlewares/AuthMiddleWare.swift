//
//  TokenMiddleWare.swift
//  App
//
//  Created by Benjamin Nassler on 30/05/2019.
//
import Vapor
//

/**
 Used for authenticating requests using basic auth
 */
struct AuthMiddleware: Middleware {
  func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
    guard request.authenticated else {
      let response = Response(status: .forbidden, version: request.version, headers: [:], body: "request not authenticated")
      return request.eventLoop.makeSucceededFuture(response)
    }
    return next.respond(to: request)
  }
}
