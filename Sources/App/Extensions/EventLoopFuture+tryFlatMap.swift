import NIO

/// Author: vzsg (Discord) - https://twitter.com/vzsg_dev
/// Source: https://discordapp.com/channels/431917998102675485/684159753189982218/684537099378098272
extension EventLoopFuture {
  
  /**
   Usually if an EventloopFuture is returned the function shouldnt throw.
   This is because we can just return a failed future.
   However this was possible in vapor 3 and instead of rewriting everything we can use tryFlatMap
   which brings back the old functionality
   */
  func tryFlatMap<NewValue>(
    file: StaticString = #file,
    line: UInt = #line,
    _ callback: @escaping (Value) throws -> EventLoopFuture<NewValue>
  ) -> EventLoopFuture<NewValue> {
    return flatMap(file: file, line: line) { result in
      do {
        return try callback(result)
      } catch {
        return self.eventLoop.makeFailedFuture(error, file: file, line: line)
      }
    }
  }
}
