//
//  WidgetHelper.swift
//  App
//
//  Created by Anna Poth on 13.07.18.
//

import Foundation
import Vapor

/// Interacts with the Main App
///
///
struct WidgetHelper {
  
  var request: Request
  
  init(request: Request) {
    self.request = request
  }
  
  /// Iterates through previously found placeholders and replaces them
  /// Placeholder has this format: "\'Widget-Product\', \'pid\', \'1001\'"
  func replaceWidgetPlaceholders(_ body: String, placeholders: Array<String>, locale: String, req: Request) throws -> EventLoopFuture<String> {
    /// An array of futures which will then be requested at the same time
    var futures: Array<EventLoopFuture<String>> = []
    for placeholder in placeholders {
      let widgetSplitted = placeholder.replacingOccurrences(of: "'", with: "").split(separator: ",")
      let widgetName = String(widgetSplitted[0])
      if widgetSplitted.count != 3 {
        continue
      }
      let pid = widgetSplitted[2].trimmingCharacters(in: NSCharacterSet.whitespaces)
      switch widgetName {
      case "Widget-Product":
        futures.append(try rendered(product: pid, locale: locale, req: req))
      default:
        continue
      }
    }
    /// Perform all futures together
    return futures.flatten(on: request.eventLoop).map { replacements in
      var renderedBody = body
      for i in 0..<futures.count {
        let placeholder = placeholders[i]
        let replacement = replacements[i]
        renderedBody = renderedBody.replacingOccurrences(of: "$include(\(placeholder))$", with: replacement)
      }
      return renderedBody
    }
  }
  
  /// Renders a product widget
  func rendered(product pid: String, locale: String, req: Request) throws -> EventLoopFuture<String> {
    return req.eventLoop.future("foo")
    /*
    return HTTPClient.connect(scheme: .https, hostname: "staging-web-stokke.demandware.net", on: request).flatMap(to: String.self) { client in
      let request = HTTPRequest(method: .GET, url: "/on/demandware.store/Sites-DEU-Site/\(locale)/Widget-ProductPreview?pid=\(pid)")
      return client.send(request).map { response in
        _ = client.close()
        guard response.status == .ok else { throw Abort(.internalServerError) }
        guard !response.body.description.isEmpty else { throw Abort(.internalServerError) }
        return response.body.description
      }
    }
     */
  }
 
}

