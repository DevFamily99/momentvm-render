import Foundation
import Leaf
import Redis

/// module_selector("id", "awesomeid")
struct NestedTemplateTag: LeafTag {
  
  func render(_ ctx: LeafContext) throws -> LeafData {
    guard var moduleId = ctx.parameters[0].string else {
      return ""
    }
    let startIndex = moduleId.index(moduleId.startIndex, offsetBy: 8)
    let endIndex = moduleId.index(moduleId.endIndex, offsetBy: -2)
    let range: Range = startIndex..<endIndex

    moduleId = String(moduleId[range])
    if let output = ctx.data[moduleId] {
      return output
    } else {
      return ""
    }
  }
}


struct NestedTemplateTagError: Error {}
