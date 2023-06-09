//
//  JSONTemplateDataExtension
//  App
//
//  Created by Benjamin Nassler on 05.05.18.
//

import Foundation
import Leaf
import JSON

extension String {
  var asJSON: JSON? {
    get {
      guard let dataFromString = self.data(using: .utf8, allowLossyConversion: false) else {
        return nil
      }
      return dataFromString.asJSON
    }
  }
}

extension Data {
  var asJSON: JSON? {
    get {
      do {
        let json = try JSON(data: self)
        return json
      } catch {
        return nil
      }
    }
  }
}

/*
extension JSON {
  
  /// Returns the JSON as a TemplateData
  var asTemplateData: TemplateData {
    get {
      if let dict = self.object {
        var dicts = [String: TemplateData]()
        for (key,subJson):(String, JSON) in dict {
          dicts[key] = subJson.asTemplateData
        }
        return(.dictionary(dicts))
      }
      /// String
      if let stringValue = self.string {
        return .string(stringValue)
      }
      /// Int
      if let integerValue = self.int {
        return .int(integerValue)
      }
      /// Array
      if let array = self.array {
        var list = [TemplateData]()
        for item in array {
          list.append(item.asTemplateData)
        }
        return .array(list)
      }
      /// Bool
      if let boolValue = self.bool {
        return .bool(boolValue)
      }
      /// Neither of these
      return .string("")
    }
  }
  
}



*/
