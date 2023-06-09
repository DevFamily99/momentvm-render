//
//  CategoryLinkTag.swift
//  App
//
//  Created by Benjamin Nassler on 18/03/2020.
//

import Vapor
import Leaf


// TODO
//
//final class ProductLinkTag: TagRenderer {
//    init() { }
//
//    func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
//      guard tag.parameters.count == 1 else {
//        return tag.container.future(.string(""))
//      }
//      guard let target = tag.parameters[0].string else {
//        return tag.container.future(.string(""))
//      }
//      return tag.container.future(.string("$(\"Product-Show\", \"pid\", \"\(target)\")$"))
//    }
//}
//
//

