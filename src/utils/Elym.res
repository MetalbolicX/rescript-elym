type selection =
  | Single(option<Dom.element>)
  | Multiple(array<Dom.element>)

type listenerMap = WeakMap.t<Dom.element, Dict.t<array<(int, Dom.event => unit)>>>

let listeners: listenerMap = WeakMap.make()

let nextListenerId = ref(0)
let getNextListenerId = () => {
  nextListenerId := nextListenerId.contents + 1
  nextListenerId.contents
}
// Selectors
@val @scope("document") @return(nullable)
external docQuerySelector: string => option<Dom.element> = "querySelector"
@send @return(nullable)
external querySelector: (Dom.element, string) => option<Dom.element> = "querySelector"
@val @scope("document")
external docQuerySelectorAll: string => Dom.nodeList = "querySelectorAll"
@send external querySelectorAll: (Dom.element, string) => Dom.nodeList = "querySelectorAll"
@get external nodeListLength: Dom.nodeList => int = "length"
@send external item: (Dom.nodeList, int) => Nullable.t<Dom.element> = "item"

// Attributes
@send external setAttribute: (Dom.element, string, string) => unit = "setAttribute"
@send @return(nullable)
external getAttribute: (Dom.element, string) => option<string> = "getAttribute"
@send external removeAttribute: (Dom.element, string) => unit = "removeAttribute"
@send external hasAttribute: (Dom.element, string) => bool = "hasAttribute"
@send external toggleAttribute: (Dom.element, string) => unit = "toggleAttribute"

// Class getters and setters
@get external classList: Dom.element => Dom.domTokenList = "classList"
@send @variadic
external add: (Dom.domTokenList, array<string>) => unit = "add"
@send @variadic
external remove: (Dom.domTokenList, array<string>) => unit = "remove"
@send external contains: (Dom.domTokenList, string) => bool = "contains"
@send external toggle: (Dom.domTokenList, string, ~isForced: bool=?) => unit = "toggle"
@send external replace: (Dom.domTokenList, string, string) => unit = "replace"

// Text
@get external getTextContent: Dom.element => string = "textContent"
@set external setTextContent: (Dom.element, string) => unit = "textContent"

// Css properties
@val external getComputedStyle: Dom.element => Dom.cssStyleDeclaration = "getComputedStyle"
@send external getPropertyValue: (Dom.cssStyleDeclaration, string) => string = "getPropertyValue"

// Special tag properties
@get external getValue: Dom.element => string = "value"
@set external setValue: (Dom.element, string) => unit = "value"

// Event listeners
@send
external addEventListener: (Dom.element, string, Dom.event => unit) => unit = "addEventListener"
@send external removeEventListener: (Dom.element, string, Dom.event => unit) => unit = "removeEventListener"

let select: string => selection = selector => Single(docQuerySelector(selector))

let selectAll: string => selection = selector => {
  let nodes = selector->docQuerySelectorAll
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
  | Single(Some(el)) => el->getTextContent->Some
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

let hasAttr: (selection, string) => option<bool> = (sel, attrName) => {
  switch sel {
  | Single(Some(el)) => el->hasAttribute(attrName)->Some
  | Single(None) => {
      Console.error("Elym: hasAttr - Single element is None.")
      None
    }
  | Multiple(_) => {
      Console.error("Elym: hasAttr - getter is not supported for multiple elements")
      None
    }
  }
}

let toggleAttr: (selection, string) => selection = (sel, attrName) => {
  switch sel {
  | Single(Some(el)) => el->toggleAttribute(attrName)
  | Single(None) => Console.error("Elym: toggleAttr - Single element is None")
  | Multiple(elements) => elements->Array.forEach(el => el->toggleAttribute(attrName))
  }
  sel
}

let addClass: (selection, array<string>) => selection = (sel, className) => {
  switch sel {
  | Single(Some(el)) => el->classList->add(className)
  | Single(None) => Console.error("Elym: addClass - Single element is None.")
  | Multiple(elements) => elements->Array.forEach(el => el->classList->add(className))
  }
  sel
}

let removeClass: (selection, array<string>) => selection = (sel, className) => {
  switch sel {
  | Single(Some(el)) => el->classList->remove(className)
  | Single(None) => Console.error("Elym: removeClass - Single element is None.")
  | Multiple(elements) => elements->Array.forEach(el => el->classList->remove(className))
  }
  sel
}

let isClassed: (selection, string) => option<bool> = (sel, className) => {
  switch sel {
  | Single(Some(el)) => el->classList->contains(className)->Some
  | Single(None) => {
      Console.error("Elym: isClassed - Single element is None.")
      None
    }
  | Multiple(_) => {
      Console.error("Elym: isClassed - Multiple elements is None")
      None
    }
  }
}

let toggleClass: (selection, string, ~isForced: bool=?) => selection = (
  sel,
  className,
  ~isForced=?,
) => {
  switch sel {
  | Single(Some(el)) =>
    switch isForced {
    | Some(force) => el->classList->toggle(className, ~isForced=force)
    | None => el->classList->toggle(className)
    }
  | Single(None) => Console.error("Elym: toggleClass - Single element is None.")
  | Multiple(elements) =>
    elements->Array.forEach(el =>
      switch isForced {
      | Some(force) => el->classList->toggle(className, ~isForced=force)
      | None => el->classList->toggle(className)
      }
    )
  }
  sel
}

let replaceClass: (selection, string, string) => selection = (sel, oldClass, newClass) => {
  switch sel {
  | Single(Some(el)) => el->classList->replace(oldClass, newClass)
  | Single(None) => Console.error("Elym: replaceClass - Single element is None")
  | Multiple(elements) => elements->Array.forEach(el => el->classList->replace(oldClass, newClass))
  }
  sel
}

let getCssProperty: (selection, string) => option<string> = (sel, property) => {
  switch sel {
  | Single(Some(el)) =>
    let style = getComputedStyle(el)
    Some(style->getPropertyValue(property))
  | Single(None) =>
    Console.error("Elym: getProperty - Single element is None")
    None
  | Multiple(_) =>
    Console.error("Elym: getProperty - getter not supported on multiple elements")
    None
  }
}

let setValue: (selection, string) => selection = (sel, value) => {
  switch sel {
  | Single(Some(el)) => el->setValue(value)
  | Single(None) => Console.error("Elym: setValue - Single element is None.")
  | Multiple(elements) => elements->Array.forEach(el => el->setValue(value))
  }
  sel
}

let getValue: selection => option<string> = sel => {
  switch sel {
  | Single(Some(el)) => el->getValue->Some
  | Single(None) =>
    Console.error("Elym: getValue - Single element is None.")
    None
  | Multiple(_elements) =>
    Console.error("Elym: getValue - getter not supported on multiple elements.")
    None
  }
}

let on: (selection, string, Dom.event => unit) => selection = (sel, eventType, callback) => {
  let addListener = el => {
    let id = getNextListenerId()
    let listenersForElement = switch WeakMap.get(listeners, el) {
    | Some(dict) => dict
    | None => {
        let newDict = Dict.make()
        WeakMap.set(listeners, el, newDict)->ignore
        newDict
      }
    }
    let listenersForEvent = switch Dict.get(listenersForElement, eventType) {
    | Some(arr) => arr
    | None => []
    }
    Dict.set(listenersForElement, eventType, [(id, callback), ...listenersForEvent])
    el->addEventListener(eventType, callback)
  }

  switch sel {
  | Single(Some(el)) => addListener(el)
  | Single(None) => Console.error("Elym: on - Single element is None.")
  | Multiple(elements) => elements->Array.forEach(addListener)
  }
  sel
}

let off: (selection, string, Dom.event => unit) => selection = (sel, eventType, callback) => {
  let removeListener = el => {
    switch WeakMap.get(listeners, el) {
    | Some(dict) =>
      switch Dict.get(dict, eventType) {
      | Some(arr) => {
          let newArr = arr->Array.filter(((_, cb)) => cb !== callback)
          if Array.length(newArr) == 0 {
            Dict.delete(dict, eventType)
          } else {
            Dict.set(dict, eventType, newArr)
          }
          el->removeEventListener(eventType, callback)
        }
      | None => ()
      }
    | None => ()
    }
  }
  switch sel {
  | Single(Some(el)) => removeListener(el)
  | Single(None) => Console.error("Elym: off - Single element is None.")
  | Multiple(elements) => elements->Array.forEach(removeListener)
  }
  sel
}
