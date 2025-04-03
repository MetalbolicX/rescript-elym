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
@send external item: (Dom.nodeList, int) => Nullable.t<Dom.element> = "item"
@send external getAttribute: (Dom.element, string) => option<string> = "getAttribute"
@get external getInnerText: Dom.element => option<string> = "innerText"
@set external setInnerText: (Dom.element, string) => unit = "innerText"
@get external getValue: Dom.element => option<string> = "value"
@set external setValue: (Dom.element, string) => unit = "value"
@send
external elementQuerySelector: (Dom.element, string) => option<Dom.element> = "querySelector"
@send
external elementQuerySelectorAll: (Dom.element, string) => Dom.nodeList = "querySelectorAll"
@send external remove: Dom.element => unit = "remove"
@send external off: (Dom.element, string, unit => unit) => unit = "removeEventListener"

// New type to track event listeners
type eventListener = {
  eventType: string,
  callback: unit => unit
}

// Extend selection type to include event listener tracking
type selection = {
  elements: option<Dom.element>,
  multiElements: array<Dom.element>,
  eventListeners: array<(Dom.element, eventListener)>
}

// Utility function to create an empty selection
let emptySelection = {
  elements: None,
  multiElements: [],
  eventListeners: []
}

// Updated select function
let select: string => selection = selector => {
  let element = querySelector(selector)
  {
    elements: element,
    multiElements: [],
    eventListeners: []
  }
}

// Updated selectAll function
let selectAll: string => selection = selector => {
  let nodeList = querySelectorAll(selector)
  let length = nodeList->nodeListLength

  if length === 0 {
    {
      elements: None,
      multiElements: [],
      eventListeners: []
    }
  } else {
    let indices = Array.fromInitializer(~length, i => i)
    let elements = indices->Array.map(i => {
      Nullable.getExn(nodeList->item(i))
    })

    {
      elements: elements[0],
      multiElements: elements,
      eventListeners: []
    }
  }
}

// Updated createFromTemplate function
let createFromTemplate: string => selection = htmlTemplate => {
  let range = createRange()
  let fragment = createContextualFragment(range, String.trim(htmlTemplate))
  let element = switch fragment->firstElementChild {
  | Value(el) => Some(el)
  | Null => None
  }

  {
    elements: element,
    multiElements: [],
    eventListeners: []
  }
}

// Enhanced on function with event listener tracking
let on: (selection, string, unit => unit) => selection = (sel, eventType, callback) => {
  let updatedListeners = switch sel.elements {
  | Some(el) => {
      addEventListener(el, eventType, callback)
      Array.concat(sel.eventListeners, [(el, {eventType: eventType, callback: callback})])
    }
  | None => sel.eventListeners
  }

  let multiUpdatedListeners = sel.multiElements->Array.reduce(updatedListeners, (acc, el) => {
    addEventListener(el, eventType, callback)
    Array.concat(acc, [(el, {eventType: eventType, callback: callback})])
  })

  {
    ...sel,
    eventListeners: multiUpdatedListeners
  }
}

// Function to remove all tracked event listeners before removing an element
let removeAllListeners: selection => unit = sel => {
  sel.eventListeners->Array.forEach(((el, listener)) => {
    off(el, listener.eventType, listener.callback)
  })
}

// Enhanced remove function that first removes all tracked listeners
let remove: selection => unit = sel => {
  // First remove all tracked event listeners
  removeAllListeners(sel)

  // Then remove the elements
  switch sel.elements {
  | Some(el) => remove(el)
  | None => ()
  }

  sel.multiElements->Array.forEach(remove)
}

// Rest of the previous functions remain the same, just update their return type to the new selection type
let setAttr: (selection, string, string) => selection = (sel, attrName, value) => {
  switch sel.elements {
  | Some(el) => setAttribute(el, attrName, value)
  | None => Console.error("DomQuery: setAttr - Single element is None.")
  }

  sel.multiElements->Array.forEach(el => setAttribute(el, attrName, value))
  sel
}

let selectChild: (selection, string) => selection = (sel, selector) => {
  let childElement = switch sel.elements {
  | Some(el) => el->elementQuerySelector(selector)
  | None => {
      Console.error("DomQuery: selectChild - Single element is None.")
      None
    }
  }

  let multiChildElements = sel.multiElements->Array.reduce(None, (acc, el) => {
    switch acc {
    | Some(_) => acc // Already found a match
    | None => el->elementQuerySelector(selector)
    }
  })

  {
    elements: childElement,
    multiElements: [],
    eventListeners: sel.eventListeners
  }
}

let selectChildren: (selection, string) => selection = (sel, selector) => {
  let childElements = switch sel.elements {
  | Some(el) => {
      let nodeList = el->elementQuerySelectorAll(selector)
      let length = nodeList->nodeListLength

      if length === 0 {
        []
      } else {
        let indices = Array.fromInitializer(~length, i => i)
        indices->Array.map(i => {
          Nullable.getExn(nodeList->item(i))
        })
      }
    }
  | None => {
      Console.error("DomQuery: selectChildren - Single element is None.")
      []
    }
  }

  let allMultiChildElements = sel.multiElements->Array.reduce([], (acc, el) => {
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

  {
    elements: childElements->Array.get(0),
    multiElements: childElements,
    eventListeners: sel.eventListeners
  }
}