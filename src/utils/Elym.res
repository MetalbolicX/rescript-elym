@val @scope("document")
external querySelectorAll: string => Dom.nodeList = "querySelectorAll"
@val @scope("document") @return(nullable)
external querySelector: string => option<Dom.element> = "querySelector"
@val @scope("document")
external createRange: unit => Dom.range = "createRange"
@send
external createContextualFragment: (Dom.range, string) => Dom.documentFragment =
  "createContextualFragment"
@get external firstElementChild: Dom.documentFragment => Null.t<Dom.element> = "firstElementChild"
@send external appendChild: ('a, Dom.element) => unit = "appendChild"
@send
external addEventListener: (Dom.element, string, unit => unit) => unit = "addEventListener"
@send external removeAttribute: (Dom.element, string) => unit = "removeAttribute"
@send external setAttribute: (Dom.element, string, string) => unit = "setAttribute"
@get external nodeListLength: Dom.nodeList => int = "length"
// @send external item: (Dom.nodeList, int) => Dom.node = "item"
@send external item: (Dom.nodeList, int) => Nullable.t<Dom.element> = "item"
@send external getAttribute: (Dom.element, string) => option<string> = "getAttribute"
// @send external getTextContent: (Dom.element) => string = "textContent"
// @send external setTextContent: (Dom.element, string) => unit = "textContent"
@get external getInnerText: Dom.element => option<string> = "innerText"
@set external setInnerText: (Dom.element, string) => unit = "innerText"
@get external getValue: Dom.element => option<string> = "value"
@set external setValue: (Dom.element, string) => unit = "value"
@send
external elementQuerySelector: (Dom.element, string) => option<Dom.element> = "querySelector"
@send
external elementQuerySelectorAll: (Dom.element, string) => Dom.nodeList = "querySelectorAll"
@send external remove: (Dom.element) => unit = "remove"

type selection =
  | Single(option<Dom.element>)
  | Multiple(array<Dom.element>)

let select: string => selection = selector => Single(querySelector(selector))

let selectAll: string => selection = selector => {
  let nodeList = querySelectorAll(selector)
  let length = nodeList->nodeListLength

  if length === 0 {
    Multiple([])
  } else {
    // Create an array of indices first
    let indices = Array.fromInitializer(~length, i => i)

    // Map over the indices to get the DOM elements
    let elements = indices->Array.map(i => {
      Nullable.getExn(nodeList->item(i))
    })

    Multiple(elements)
  }
}

let createFromTemplate: string => selection = htmlTemplate => {
  let range = createRange()
  let fragment = createContextualFragment(range, String.trim(htmlTemplate))
  Single(
    switch fragment->firstElementChild {
    | Value(el) => Some(el)
    | Null => None
    },
  )
}

let setAttr: (selection, string, string) => selection = (sel, attrName, value) => {
  switch sel {
  | Single(Some(el)) => setAttribute(el, attrName, value)
  | Single(None) => Console.error("DomQuery: setAttr - Single element is None.")
  | Multiple(elements) => elements->Array.forEach(el => setAttribute(el, attrName, value))
  }
  sel
}

let getAttr: (selection, string) => option<string> = (sel, attrName) => {
  switch sel {
  | Single(Some(el)) => el->getAttribute(attrName)
  | Single(None) =>
    Console.error("DomQuery: getAttr - Single element is None.")
    None
  | Multiple(_elements) =>
    Console.error("DomQuery: getAttr - getter not supported on multiple elements.")
    None
  }
}

let rmAttr: (selection, string) => selection = (sel, attrName) => {
  switch sel {
  | Single(Some(el)) => removeAttribute(el, attrName)
  | Single(None) => Console.error("DomQuery: removeAttribute - Single element is None.")
  | Multiple(elements) => elements->Array.forEach(el => removeAttribute(el, attrName))
  }
  sel
}

let on: (selection, string, unit => unit) => selection = (sel, eventType, callback) => {
  switch sel {
  | Single(Some(el)) => addEventListener(el, eventType, callback)
  | Single(None) => Console.error("DomQuery: on - Single element is None.")
  | Multiple(elements) => elements->Array.forEach(el => addEventListener(el, eventType, callback))
  }
  sel
}

let appendChild: (selection, Dom.element) => selection = (sel, child) => {
  switch sel {
  | Single(Some(el)) => appendChild(el, child)
  | Single(None) => Console.error("DomQuery: appendChild - Single element is None.")
  | Multiple(elements) => elements->Array.forEach(el => appendChild(el, child))
  }
  sel
}

let setText: (selection, string) => selection = (sel, text) => {
  switch sel {
  | Single(Some(el)) => el->setInnerText(text)
  | Single(None) => Js.Console.error("DomQuery: setText - Single element is None.")
  | Multiple(elements) => elements->Array.forEach(el => el->setInnerText(text))
  }
  sel
}

let getText: selection => option<string> = sel => {
  switch sel {
  | Single(Some(el)) => el->getInnerText
  | Single(None) =>
    Js.Console.error("DomQuery: getText - Single element is None.")
    None
  | Multiple(_elements) =>
    Js.Console.error("DomQuery: getText - getter not supported on multiple elements.")
    None
  }
}

let setValue: (selection, string) => selection = (sel, value) => {
  switch sel {
  | Single(Some(el)) => el->setValue(value)
  | Single(None) => Console.error("DomQuery: setValue - Single element is None.")
  | Multiple(elements) => elements->Array.forEach(el => el->setValue(value))
  }
  sel
}

let getValue: selection => option<string> = sel => {
  switch sel {
  | Single(Some(el)) => el->getValue
  | Single(None) =>
    Console.error("DomQuery: getValue - Single element is None.")
    None
  | Multiple(_elements) =>
    Console.error("DomQuery: getValue - getter not supported on multiple elements.")
    None
  }
}

let selectChild: (selection, string) => selection = (sel, selector) => {
  switch sel {
  | Single(Some(el)) => // Find the first matching child element using elementQuerySelector
    Single(el->elementQuerySelector(selector))
  | Single(None) => {
      Console.error("DomQuery: selectChild - Single element is None.")
      Single(None)
    }
  | Multiple(elements) => {
      // Try to find the first matching child in any of the elements
      let firstMatch = elements->Array.reduce(None, (acc, el) => {
        switch acc {
        | Some(_) => acc // Already found a match
        | None => el->elementQuerySelector(selector)
        }
      })
      Single(firstMatch)
    }
  }
}

let selectChildren: (selection, string) => selection = (sel, selector) => {
  switch sel {
  | Single(Some(el)) => {
      let nodeList = el->elementQuerySelectorAll(selector)
      let length = nodeList->nodeListLength

      if length === 0 {
        Multiple([])
      } else {
        let indices = Array.fromInitializer(~length, i => i)
        let elements = indices->Array.map(i => {
          Nullable.getExn(nodeList->item(i))
        })
        Multiple(elements)
      }
    }
  | Single(None) => {
      Console.error("DomQuery: selectChildren - Single element is None.")
      Multiple([])
    }
  | Multiple(elements) => {
      let allMatches = elements->Array.reduce([], (acc, el) => {
        let nodeList = el->elementQuerySelectorAll(selector)
        let length = nodeList->nodeListLength

        if length === 0 {
          acc
        } else {
          let indices = Array.fromInitializer(~length, i => i)
          let matches = indices->Array.map(i => {
            Nullable.getExn(nodeList->item(i))
          })
          Array.concat(acc, matches)
        }
      })

      Multiple(allMatches)
    }
  }
}

let remove: selection => unit = sel => {
  switch sel {
  | Single(Some(el)) => remove(el)
  | Single(None) => Console.error("DomQuery: remove - Single element is None.")
  | Multiple(elements) => elements->Array.forEach(el => remove(el))
  }
}