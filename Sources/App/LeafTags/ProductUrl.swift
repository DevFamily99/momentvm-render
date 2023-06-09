//
//  ProductUrl.swift
//  
//
//  Created by Benjamin Nassler on 15/03/2021.
//

import Foundation
import Leaf

/// module_selector("id", "awesomeid")
struct ContentUrl: LeafTag {
  
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
      return LeafData.string(#"$url('Page-Show', 'cid', '\#(identifier)')$"#)
    default:
      return LeafData.string(nil)
    }
  }
}

