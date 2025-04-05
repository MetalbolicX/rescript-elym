type element =
  | Doc(Dom.document)
  | Element(Dom.element)

type selection =
  | Single(option<Dom.element>)
  | Multiple(array<Dom.element>)

@val external document: element = "document"

@send @return(nullable)
external querySelector: (element, string) => option<Dom.element> = "querySelector"

@send external querySelectorAll: (element, string) => Dom.nodeList = "querySelectorAll"
@get external nodeListLength: Dom.nodeList => int = "length"
@send external item: (Dom.nodeList, int) => Nullable.t<Dom.element> = "item"

@send external setAttribute: (Dom.element, string, string) => unit = "setAttribute"
@send external getAttribute: (Dom.element, string) => option<string> = "getAttribute"

@get external getTextContent: Dom.element => option<string> = "textContent"
@set external setTextContent: (Dom.element, string) => unit = "textContent"

@send external removeAttribute: (Dom.element, string) => unit = "removeAttribute"

let select: string => selection = selector => Single(document->querySelector(selector))

let selectAll: string => selection = selector => {
  let nodes = document->querySelectorAll(selector)
  let length = nodeListLength(nodes)

  if length == 0 {
    Multiple([])
  } else {
    let indices = Array.fromInitializer(~length, i => i)
    let elements = indices->Array.map(i => Nullable.getExn(nodes->item(i)))
    Multiple(elements)
  }
}

let selectChild: (selection, string) => selection = (sel, selector) => {
  switch sel {
  | Single(Some(element)) => Single(Element(element)->querySelector(selector))
  | Single(None) => Single(None)
  | Multiple(elements) =>
    let firstMatch = elements->Array.reduce(None, (acc, el) => {
      switch acc {
      | Some(_) => acc // Already found a match
      | None => Element(el)->querySelector(selector)
      }
    })
    Single(firstMatch)
  }
}

let selectChildren: (selection, string) => selection = (sel, selector) => {
  switch sel {
  | Single(Some(element)) =>
    let nodeList = Element(element)->querySelectorAll(selector)
    let length = nodeListLength(nodeList)

    if length == 0 {
      Multiple([])
    } else {
      let indices = Array.fromInitializer(~length, i => i)
      let elements = indices->Array.map(i => Nullable.getExn(nodeList->item(i)))
      Multiple(elements)
    }
  | Single(None) => Multiple([])
  | Multiple(elements) =>
    let allMatches = elements->Array.reduce([], (acc, el) => {
      let nodeList = Element(el)->querySelectorAll(selector)
      let length = nodeListLength(nodeList)

      if length == 0 {
        acc
      } else {
        let indices = Array.fromInitializer(~length, i => i)
        let matches = indices->Array.map(i => Nullable.getExn(nodeList->item(i)))
        // Array.concat(acc, matches)
        [...acc, ...matches]
      }
    })
    Multiple(allMatches)
  }
}

let setAttr: (selection, string, string) => selection = (sel, attrName, value) => {
  switch sel {
  | Single(Some(el)) => setAttribute(el, attrName, value)
  | Single(None) => Console.error("Elym: setAttr - Single element is None.")
  | Multiple(elements) => elements->Array.forEach(el => setAttribute(el, attrName, value))
  }
  sel
}

let getAttr: (selection, string) => option<string> = (sel, attrName) => {
  switch sel {
  | Single(Some(el)) => el->getAttribute(attrName)
  | Single(None) =>
    Console.error("Elym: getAttr - Single element is None.")
    None
  | Multiple(_) => {
      Console.error("Elym: getAttr - getter not supported on multiple elements.")
      None
    }
  }
}
let setText: (selection, string) => selection = (sel, text) => {
  switch sel {
  | Single(Some(el)) => el->setTextContent(text)
  | Single(None) => Console.error("Elym: setText - Single element is None.")
  | Multiple(elements) => elements->Array.forEach(el => el->setTextContent(text))
  }
  sel
}

let getText: selection => option<string> = sel => {
  switch sel {
  | Single(Some(el)) => el->getTextContent
  | Single(None) =>
    Console.error("Elym: getText - Single element is None.")
    None
  | Multiple(_) =>
    Console.error("Elym: getText - getter not supported on multiple elements.")
    None
  }
}
// let createFromTemplate: string => selection = template => {
//   let parser = new Dom.DOMParser()
//   let doc = parser->parseFromString(template, "text/html")
//   let body = doc->querySelector("body")
//   let element = body->querySelector("*")
//   Single(Some(element))
// }

let removeAttr: (selection, string) => selection = (sel, attrName) => {
  switch sel {
  | Single(Some(el)) => removeAttribute(el, attrName)
  | Single(None) => Console.error("Elym: removeAttribute - Single element is None.")
  | Multiple(elements) => elements->Array.forEach(el => removeAttribute(el, attrName))
  }
  sel
}