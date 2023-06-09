//
//  File.swift
//  
//
//  Created by Benjamin Nassler on 10/07/2020.
//

import Vapor
import LeafKit

/**
 A dynamic LeafSource singleton to store dynamic templates.
 */
class DynamicSource: LeafSource {
  var templates: [String: String]
  var lock: Lock
  static var shared = DynamicSource()
  
  private init() {
    templates = [:]
    lock = .init()
  }
  
  /**
   Inserts or overwrites a new template body for a given key.
   Cached in-memory.
   */
  func insert(templateName: String, value: String) {
    lock.withLock { templates[templateName] = value }
  }
  
  public func file(template: String, escape: Bool = false, on eventLoop: EventLoop) -> EventLoopFuture<ByteBuffer> {
    let path = template
    self.lock.lock()
    defer { self.lock.unlock() }
    if let file = self.templates[path] {
      var buffer = ByteBufferAllocator().buffer(capacity: file.count)
      buffer.writeString(file)
      return eventLoop.makeSucceededFuture(buffer)
    } else {
      return eventLoop.makeFailedFuture(LeafError(.noTemplateExists(template)))
    }
  }
}


extension Application {
  var dynamicSource: DynamicSource {
    get {
      DynamicSource.shared
    }
    set {
      DynamicSource.shared = newValue
    }
  }
}
