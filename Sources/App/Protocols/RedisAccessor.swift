//
//  RedisHelper.swift
//  App
//
//  Created by Benjamin Nassler on 18/05/2019.
//

import Vapor
import Redis
/**
 
 Generic Redis Accessor Protocol.
 
 Low-level access to redis database
 
 */
protocol RedisAccessor {
}

extension RedisAccessor {
  
  func getRedisValue(forKey key: String, req: Request) throws -> EventLoopFuture<String> {
    return req.redis.get(RedisKey(key), as: String.self).map { $0 ?? "" }
  }
  
  func setRedisValue(forKey key: String, to: String, req: Request) throws -> EventLoopFuture<Void> {
    return req.redis.set(RedisKey(key), to: to)
  }
  
  
  
}

