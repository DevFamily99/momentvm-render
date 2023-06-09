//
//  XMLParser.swift
//  App
//
//  Created by Benjamin Nassler on 30/04/2020.
//

import Vapor


/**
 
 A Promise-based wrapper around XMLParser
 
 */
final class XMLPromiseParser: NSObject, XMLParserDelegate {
  struct ParserError: Error { }
  
  var promise: Promise<String>
  var currentElementName: String = ""
  var elementsToListenFor: [String] = []
  var content = ""
  
  init(req: Request, elementsToListenFor: [String]) {
    self.promise = req.eventLoop.newPromise(String.self)
    super.init()
  }
  
  /// Here we just return a promise. Which will be completed once parsing is done
  func localize(content: String) throws -> EventLoopFuture<String> {
    guard let data = content.data(using: .utf8) else {
      throw ParserError()
    }
    /// Wrapping around the standard XMLParser
    let parser = XMLParser(data: data)
    parser.delegate = self
    parser.parse()
    return promise.futureResult
  }
  
  func parserDidEndDocument(_ parser: XMLParser) {
    print("done")
    self.promise.succeed(result: "foo")
  }
  
  func parser(_ parser: XMLParser, foundCharacters string: String) {
    content = content + string
  }
    
  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    guard self.elementsToListenFor.contains(elementName) else {
      return
    }
    content = ""
    print(elementName)
    print(attributeDict.debugDescription)
  
  }
  
  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    currentElementName = elementName
    print(content)
    content = ""
  }
  
}

