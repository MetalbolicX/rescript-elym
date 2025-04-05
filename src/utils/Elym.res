type selection =
  | Single(option<Dom.element>)
  | Multiple(array<Dom.element>)

@val external document: Dom.document = "document"

@send @return(nullable)
external docQuerySelector: (Dom.document, string) => option<Dom.element> = "querySelector"
@send @return(nullable)
external querySelector: (Dom.element, string) => option<Dom.element> = "querySelector"
@send external docQuerySelectorAll: (Dom.document, string) => Dom.nodeList = "querySelectorAll"
@send external querySelectorAll: (Dom.element, string) => Dom.nodeList = "querySelectorAll"
@get external nodeListLength: Dom.nodeList => int = "length"
@send external item: (Dom.nodeList, int) => Nullable.t<Dom.element> = "item"

@send external setAttribute: (Dom.element, string, string) => unit = "setAttribute"
@send @return(nullable)
external getAttribute: (Dom.element, string) => option<string> = "getAttribute"

@get external classList: Dom.element => Dom.domTokenList = "classList"
@send external add: (Dom.domTokenList, string) => unit = "add"
@send external remove: (Dom.domTokenList, string) => unit = "remove"
@send external contains: (Dom.domTokenList, string) => option<bool> = "contains"

@get external getTextContent: Dom.element => option<string> = "textContent"
@set external setTextContent: (Dom.element, string) => unit = "textContent"

@send external removeAttribute: (Dom.element, string) => unit = "removeAttribute"

let select: string => selection = selector => Single(document->docQuerySelector(selector))

let selectAll: string => selection = selector => {
  let nodes = document->docQuerySelectorAll(selector)
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
  | Single(Some(element)) => Single(element->querySelector(selector))
  | Single(None) => Single(None)
  | Multiple(elements) =>
    let firstMatch = elements->Array.reduce(None, (acc, el) => {
      switch acc {
      | Some(_) => acc // Already found a match
      | None => el->querySelector(selector)
      }
    })
    Single(firstMatch)
  }
}

let selectChildren: (selection, string) => selection = (sel, selector) => {
  switch sel {
  | Single(Some(element)) =>
    let nodeList = element->querySelectorAll(selector)
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
      let nodeList = el->querySelectorAll(selector)
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
  | Single(Some(el)) => el->removeAttribute(attrName)
  | Single(None) => Console.error("Elym: removeAttribute - Single element is None.")
  | Multiple(elements) => elements->Array.forEach(el => el->removeAttribute(attrName))
  }
  sel
}

let addClass: (selection, string) => selection = (sel, className) => {
  switch sel {
  | Single(Some(el)) => el->classList->add(className)
  | Single(None) => Console.error("Elym: addClass - Single element is None.")
  | Multiple(elements) => elements->Array.forEach(el => el->classList->add(className))
  }
  sel
}

let removeClass: (selection, string) => selection = (sel, className) => {
  switch sel {
  | Single(Some(el)) => el->classList->remove(className)
  | Single(None) => Console.error("Elym: removeClass - Single element is None.")
  | Multiple(elements) => elements->Array.forEach(el => el->classList->remove(className))
  }
  sel
}

let isClassed: (selection, string) => option<bool> = (sel, className) => {
  switch sel {
  | Single(Some(el)) => el->classList->contains(className)
  | Single(None) => {
      Console.error("Elym: classed - Single element is None.")
      None
    }
  | Multiple(_) => {
      Console.error("Elym: classed - Multiple elements is None")
      None
    }
  }
}
