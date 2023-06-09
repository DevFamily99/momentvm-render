import Fluent
import Vapor
import Redis
import LeafKit
import Leaf

/// Called before your application initializes.
public func configure(_ app: Application) throws {
  
  DynamicSource.shared.templates["bar"] = "Bar"
  
  /// Not sure how high we should set this…
  app.routes.defaultMaxBodySize = "10mb"
  
  
  if Environment.get("REDIS_TLS_URL") != nil {
    // heroku
    let redisURL = Environment.get("REDIS_URL") ?? "redis_url_not_set"
    print("Booting with heroku database configuration. URL: \(redisURL)")
    app.redis.configuration = try RedisConfiguration(url: redisURL, pool: .init())
  } else {
    // local
    print("Booting with local database configuration")
    app.redis.configuration = try RedisConfiguration(
      hostname: Environment.get("REDIS_URL") ?? "localhost",
      port: 6379,
      password: nil,
      database: nil,
      pool: .init()
    )
  }
  app.views.use(.leaf)
  app.leaf.cache.isEnabled = true
  app.middleware.use(AuthMiddleware())
  app.leaf.tags["now"] = NowTag()
  app.leaf.tags["moduleselector"] = UniqueCssTag()
  app.leaf.tags["categoryurl"] = CategoryUrl()
  app.leaf.tags["producturl"] = ProductUrl()
  app.leaf.tags["nestedTemplateSlot"] = NestedTemplateTag()
  app.leaf.tags["contenturl"] = ContentUrl()
  app.leaf.sources = .singleSource(app.dynamicSource)
  try app.leaf.sources.register(source: "dynamicSource", using: app.dynamicSource, searchable: true)
  // DynamicSource.shared.templates["bar"] = "Bar"
  
  try routes(app)
}
