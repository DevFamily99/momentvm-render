//
//  TokenAccessor.swift
//  App
//
//  Created by Benjamin Nassler on 01/07/2019.
//

import Vapor
import Redis

protocol TokenAccessor: RedisAccessor {
}


extension TokenAccessor {
  
  ///   Main convenience function that handles expiry, refetching etc
  ///
  /// - Check if token was saved before
  /// - We use the last 4 digits of the client ID to store the token in redis
  /// - We use redis TTL feature to handle token expiry
  ///
  func getToken(req: Request) -> EventLoopFuture<Token> {
    print(":getToken(request:)")
    /// We need to create a new promise since we cannot return out of the async call
    let promise = req.eventLoop.makePromise(of: Token.self)
    
    let clientKey = RedisKey(req.clientIdLastDigits + "foo")
    let concurrentQueue = DispatchQueue(label: "com.momentvm.publish.gettoken",
                                        attributes: .concurrent)
    /// Making the concurrent queue serial because only one is allowed to fetch a new token at a time
    /// Worst case all request would try to fetch a new token at the same time
    concurrentQueue.async(flags: .barrier) {
      /// Try to retrieve from db
      req.redis.get(clientKey).whenComplete { readResult in
        switch readResult {
        /// Could read
        case .success(let readValue):
          /// try if does not exist or is stored in db
          guard let storedToken = readValue.string else {
            /// No, need to fetch a new one
            self.fetchNewToken(forRequest: req).whenComplete { fetchResult in
              switch fetchResult {
              case .success(let newToken):
                /// Persist token in redis then return it
                req.redis.setex(
                  clientKey,
                  to: newToken.token,
                  expirationInSeconds: Int(newToken.expiresIn.timeIntervalSinceNow)
                ).whenComplete { redisResult in
                  switch redisResult {
                  case .success():
                    promise.succeed(newToken)
                  case .failure(let redisError):
                    promise.fail(redisError)
                  }
                }
              case .failure(let error):
                promise.fail(error)
              }
            }
            return
          }
          promise.succeed(Token(client: req.clientID, token: storedToken, expiresIn: Date()))
        case .failure(let error):
          // Only if redis couldnt be read from db
          promise.fail(error)
        }
      }
      
    }
    /// The promise can be returned right away. In the async part we then resolve or fail the promise
    return promise.futureResult
  }
  
  
  
  func getStoredToken(request: Request) throws -> EventLoopFuture<Token> {
    print(":getStoredToken(request:)")
    let key = RedisKey(request.clientIdLastDigits)
    return request.redis.get(key).flatMapThrowing() { result -> Token in
      guard let tokenValue = result.string else {
        throw Abort(.failedDependency, reason: "Token wasn't found in storage")
      }
      let token = Token(client: request.clientIdLastDigits, token: tokenValue, expiresIn: Date())
      return token
    }
  }
  
  
  /**
   
   Fetches a new token for the clientID and secret attached to the `Request` and stores the token in redis
   
   Returns the `TokenResponse`
   
   */
  func fetchNewToken(forRequest req: Request) -> EventLoopFuture<Token> {
    print(":fetchNewToken(req:)")
    guard let clientID = req.headers.first(name: "Client-ID") else {
      return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "Client-ID missing"))
    }
    guard let secret = req.headers.first(name: "Client-Secret") else {
      return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "Client-Secret missing"))
    }
    let clientRedisKey = RedisKey(req.clientIdLastDigits)
    
    var headers = HTTPHeaders()
    headers.add(name: "Content-Type", value: "application/x-www-form-urlencoded")
    let b64Login = Data("\(clientID):\(secret)".utf8).base64EncodedString()
    headers.add(name: "Authorization", value: "Basic \(b64Login)")
    let grantType = Grant(grantType: "client_credentials")
    let url = "https://account.demandware.com/dw/oauth2/access_token"
    return req.client.post(URI(string: url), headers: headers) { req in
      return try req.content.encode(grantType, as: .urlEncodedForm)
    }.tryFlatMap { response -> EventLoopFuture<Token> in
      print("Token response from SFCC: \(response.status.code)")
      // print(response.content)
      // print(headers.debugDescription)
      // print(req.content)
      do {
        let tokenResp = try response.content.decode(TokenResponse.self)
        let token = Token(
          client: req.clientID,
          token: tokenResp.accessToken,
          expiresIn: Date(timeInterval: TimeInterval(tokenResp.expiresIn), since: Date())
        )
        return req.redis.setex(
          clientRedisKey,
          to: tokenResp.accessToken,
          expirationInSeconds: tokenResp.expiresIn
        ).map { void in
          return token
        }
      } catch {
        return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "Could not decode SFCC token response"))
      }
    }
  }
  
  
}

