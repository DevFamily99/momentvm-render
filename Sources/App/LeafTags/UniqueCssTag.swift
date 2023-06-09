//
//  File.swift
//  
//
//  Created by Benjamin Nassler on 15/03/2021.
//

import Foundation
import Leaf

/// module_selector("id", "awesomeid")
struct UniqueCssTag: LeafTag {
  
  func render(_ ctx: LeafContext) throws -> LeafData {
    
    var output = ""
    switch ctx.parameters.count {
    // case 0: throw UniqueCssTagError
    case 2:
      guard let category = ctx.parameters[0].string,
            let identifier = ctx.parameters[1].string,
            let moduleID = ctx.data["module_id"]?.string else {
        throw UniqueCssTagError()
      }
      guard category == "id" else {
        throw UniqueCssTagError()
      }
      output = "#\(identifier)-\(moduleID)"
    default:
      throw UniqueCssTagError()
    }
    
    return LeafData.string(output)
    
  }
}


struct UniqueCssTagError: Error {}
