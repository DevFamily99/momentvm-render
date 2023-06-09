//
//  Decorator.swift
//  App
//
//  Created by Benjamin Nassler on 30.12.17.
//


import Foundation


/// Decorates content with velocity markup
// MARK: - Velocity -
class Decorator {
  
  /// Decorates a module with the html attributes that LiveEditor needs
  class func decorateRenderedModule(_ moduleString: String, withMarkersForModule module: ContentModule, template: ContentTemplate) -> String {
    return "<div class=\"cms-page-module\" data-template-id=\"\(module.template_id)\" data-template-name=\"\(template.name)\" data-page-module-id=\"\(module.id)\" rank=\"\(module.rank)\">\(moduleString)</div>"
  }
  
}

// MARK: - Date -

extension String {
  
  fileprivate func cleanDateString() -> String {
    return self.replacingOccurrences(of: "-", with: "")
  }
  
  
  /// Validates that a given date String is in format YYYY-MM-DD
  fileprivate func validDateString() -> Bool {
    let matches = self.regexMatches(for: "[0-9]{4}-[0-9]{2}-[0-9]{2}")
    if matches.count > 0 && self.count == 10 {
      return true
    } else {
      return false
    }
  }
  
}
