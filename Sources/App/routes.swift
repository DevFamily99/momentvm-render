import Vapor
import Redis
import Leaf
import JSON


/// Register your application's routes here.
@available(macOS 12, *)
public func routes(_ app: Application) throws {

  /// All those are protected, since we use a auth middleware

  app.get("version") { req in
    return [ "version" : "6.2.0" ]
  }
  
  app.get("hello", ":template") { req async throws -> View in
    let templateName = req.parameters.get("template")!
    // let random = Int.random(in: 0 ... 10)
    //let templateName = "foo"
    let templateBody = "Hello #(foo)"
    //app.leaf.dynamicSource.insert(templateName: "bar", value: "Bar")
    // ! Cannot use mutating member on immutable value: 'leaf' is a get-only property
    // Singleton
    app.dynamicSource.insert(templateName: templateName, value: templateBody)
    return try await req.view.render(templateName, ["foo": templateName]).get()
  }
  
  let renderController = RenderController()
  app.post("preview", use: renderController.preview)
  app.post("find_images", use: renderController.findImages)
  let publishController = PublishController()
  let salesforceController = SalesforceController()
  
  let group = app.grouped(TokenMiddleware())
  group.post("publish_modules", use: publishController.publishModule)
  group.post("publish_manifest", use:publishController.publishManifest)
  group.post("update_category", use: publishController.updateCategory)
  group.post("publish_content_slot", use: publishController.publishContentSlot)
  group.get("salesforce", use: salesforceController.get)
  group.post("salesforce", use: salesforceController.post)
  group.put("salesforce", use: salesforceController.put)
  group.get("auth_version") { req in
    return [ "version" : "6.2.0" ]
  }
  
  
  app.get("inforedis") { req -> EventLoopFuture<String> in
    guard req.authenticated else {
      throw Abort(.forbidden, reason: "Not authenticated")
    }
    return req.client.eventLoop.future("redis up and running")
  }
  /*
  app.get("getredis") { req -> EventLoopFuture<String> in
    return req.redis.get("token").map() { tokenOpt in
      guard let token = tokenOpt.string else {
        print("no token found")
        return "not found"
      }
      return token
    }
  }
  
  app.get("setredis") { req -> EventLoopFuture<HTTPStatus> in
    guard req.authenticated else {
      throw Abort(.forbidden, reason: "Not authenticated")
    }
    return req.redis.setex("token", to: "token123", expirationInSeconds: 30).map() {
      return .accepted
    }
  }
  */
  
  
  /*
   app.post("foo") { req -> EventLoopFuture<HTTPStatus> in
   return try req.content.decode(RenderRequest.self).map(to: HTTPStatus.self) { renderRequest in
   //print(renderRequest.modules)
   return .ok
   }
   }
   
   return req.withNewConnection(to: .redis) { redis in
   return redis.command("INFO")
   // map the resulting RedisData to a String
   .map { $0.string ?? "" }
   }
   }
   */

  
}
