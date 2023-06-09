//
//  CategoryUrl.swift
//  
//
//  Created by Benjamin Nassler on 15/03/2021.
//

import Foundation
import Leaf

/// module_selector("id", "awesomeid")
struct CategoryUrl: LeafTag {
  
  func render(_ ctx: LeafContext) throws -> LeafData {
    
    
    switch ctx.parameters.count {
    // case 0: throw UniqueCssTagError
    case 1:
      guard let identifier = ctx.parameters[0].string else {
        return LeafData.string(nil)
      }
      guard identifier != "" else {
        return LeafData.string(nil)
      }
      return LeafData.string(#"$url('Search-Show', 'cgid', '\#(identifier)')$"#)
    case 3:
      guard let identifier = ctx.parameters[0].string,
            let paramKey = ctx.parameters[1].string,
            let paramValue = ctx.parameters[2].string else {
        return LeafData.string(nil)
      }
      guard identifier != "",
            paramKey != "",
            paramValue != "" else {
        return LeafData.string(nil)
      }
      return LeafData.string(#"$url('Search-Show', 'cgid', '\#(identifier)', '\#(paramKey)', '\#(paramValue)')$"#)
    default:
      return LeafData.string(nil)
    }
  }
}


struct CategoryTagError: Error {}
