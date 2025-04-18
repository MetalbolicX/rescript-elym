type selection =
  | Single(option<Dom.element>)
  | Multiple(array<Dom.element>)

type listenerMap = WeakMap.t<Dom.element, Dict.t<array<(int, Dom.event => unit)>>>

type selector =
  | Selector(string)
  | Dom(Dom.element)

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
external removeToken: (Dom.domTokenList, array<string>) => unit = "remove"
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
@send
external removeEventListener: (Dom.element, string, Dom.event => unit) => unit =
  "removeEventListener"

@send external removeElement: Dom.element => unit = "remove"

// let select: string => selection = selector => Single(docQuerySelector(selector))
let select: selector => selection = selector => {
  switch selector {
    | Selector(str) => Single(str->docQuerySelector)
    | Dom(el) => Single(Some(el))
  }
}

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

let text: (selection, ~content: string=?) => (selection, option<string>) = (sel, ~content=?) => {
  let result = switch (sel, content) {
  | (Single(Some(el)), Some(text)) =>
    el->setTextContent(text)
    None
  | (Single(Some(el)), None) =>
    Some(el->getTextContent)
  | (Single(None), _) =>
    Console.error("Elym: text - Single element is None.")
    None
  | (Multiple(elements), Some(text)) =>
    elements->Array.forEach(el => el->setTextContent(text))
    None
  | (Multiple(_), None) =>
    Console.error("Elym: text - getter not supported on multiple elements.")
    None
  }
  (sel, result)
}

let value: (selection, ~newValue: string=?) => (selection, option<string>) = (sel, ~newValue=?) => {
  let result = switch (sel, newValue) {
  | (Single(Some(el)), Some(value)) =>
    el->setValue(value)
    None
  | (Single(Some(el)), None) =>
    Some(el->getValue)
  | (Single(None), _) =>
    Console.error("Elym: value - Single element is None.")
    None
  | (Multiple(elements), Some(value)) =>
    elements->Array.forEach(el => el->setValue(value))
    None
  | (Multiple(_), None) =>
    Console.error("Elym: value - getter not supported on multiple elements.")
    None
  }
  (sel, result)
}

let attr: (selection, string, ~value: string=?) => (selection, option<string>) = (sel, attrName, ~value=?) => {
  let result = switch (sel, value) {
  | (Single(Some(el)), Some(v)) =>
    setAttribute(el, attrName, v)
    None
  | (Single(Some(el)), None) =>el->getAttribute(attrName)
  | (Single(None), _) =>
    Console.error("Elym: attr - Single element is None.")
    None
  | (Multiple(elements), Some(v)) =>
    elements->Array.forEach(el => setAttribute(el, attrName, v))
    None
  | (Multiple(_), None) =>
    Console.error("Elym: attr - getter not supported on multiple elements.")
    None
  }
  (sel, result)
}

// let style: (selection, string, ~value: option<string>=?) => (selection, option<string>) = (sel, property, ~value=?) => {
//   let setStyle = (el, prop, val) => {
//     el->Js.Dom.setStyle(prop, val)
//   }

//   let getStyle = (el, prop) => {
//     el->Js.Dom.getStyle(prop)
//   }

//   let removeStyle = (el, prop) => {
//     el->Js.Dom.setStyle(prop, "")
//   }

//   let result = switch (sel, value) {
//   | (Single(Some(el)), Some(v)) =>
//     setStyle(el, property, v)
//     None
//   | (Single(Some(el)), None) when value === Some(None) =>
//     removeStyle(el, property)
//     None
//   | (Single(Some(el)), None) =>
//     Some(getStyle(el, property))
//   | (Single(None), _) =>
//     Console.error("Elym: style - Single element is None.")
//     None
//   | (Multiple(elements), Some(v)) =>
//     elements->Array.forEach(el => setStyle(el, property, v))
//     None
//   | (Multiple(elements), None) when value === Some(None) =>
//     elements->Array.forEach(el => removeStyle(el, property))
//     None
//   | (Multiple(_), None) =>
//     Console.error("Elym: style - getter not supported on multiple elements.")
//     None
//   }
//   (sel, result)
// }
let attributed: (selection, string, ~exists: bool=?) => (selection, option<bool>) = (sel, attrName, ~exists=?) => {
  let result = switch (sel, exists) {
  | (Single(Some(el)), Some(true)) =>
    el->setAttribute(attrName, "")
    None
  | (Single(Some(el)), Some(false)) =>
    el->removeAttribute(attrName)
    None
  | (Single(Some(el)), None) =>
    Some(el->hasAttribute(attrName))
  | (Single(None), _) =>
    Console.error("Elym: attributed - Single element is None.")
    None
  | (Multiple(elements), Some(true)) =>
    elements->Array.forEach(el => el->setAttribute(attrName, ""))
    None
  | (Multiple(elements), Some(false)) =>
    elements->Array.forEach(el => el->removeAttribute(attrName))
    None
  | (Multiple(_), None) =>
    Console.error("Elym: attributed - getter not supported on multiple elements.")
    None
  }
  (sel, result)
}

let classed: (selection, string, ~exists: bool=?) => (selection, option<bool>) = (sel, className, ~exists=?) => {
  let result = switch (sel, exists) {
  | (Single(Some(el)), Some(true)) =>
    el->classList->add([className])
    None
  | (Single(Some(el)), Some(false)) =>
    el->classList->removeToken([className])
    None
  | (Single(Some(el)), None) =>
    Some(el->classList->contains(className))
  | (Single(None), _) =>
    Console.error("Elym: classed - Single element is None.")
    None
  | (Multiple(elements), Some(true)) =>
    elements->Array.forEach(el => el->classList->add([className]))
    None
  | (Multiple(elements), Some(false)) =>
    elements->Array.forEach(el => el->classList->removeToken([className]))
    None
  | (Multiple(_), None) =>
    Console.error("Elym: classed - getter not supported on multiple elements.")
    None
  }
  (sel, result)
}

let replaceClass: (selection, string, string) => selection = (sel, oldClass, newClass) => {
  switch sel {
  | Single(Some(el)) => el->classList->replace(oldClass, newClass)
  | Single(None) => Console.error("Elym: replaceClass - Single element is None")
  | Multiple(elements) => elements->Array.forEach(el => el->classList->replace(oldClass, newClass))
  }
  sel
}

// let getCssProperty: (selection, string) => option<string> = (sel, property) => {
//   switch sel {
//   | Single(Some(el)) =>
//     let style = getComputedStyle(el)
//     Some(style->getPropertyValue(property))
//   | Single(None) =>
//     Console.error("Elym: getProperty - Single element is None")
//     None
//   | Multiple(_) =>
//     Console.error("Elym: getProperty - getter not supported on multiple elements")
//     None
//   }
// }

// let setValue: (selection, string) => selection = (sel, value) => {
//   switch sel {
//   | Single(Some(el)) => el->setValue(value)
//   | Single(None) => Console.error("Elym: setValue - Single element is None.")
//   | Multiple(elements) => elements->Array.forEach(el => el->setValue(value))
//   }
//   sel
// }

// let getValue: selection => option<string> = sel => {
//   switch sel {
//   | Single(Some(el)) => el->getValue->Some
//   | Single(None) =>
//     Console.error("Elym: getValue - Single element is None.")
//     None
//   | Multiple(_elements) =>
//     Console.error("Elym: getValue - getter not supported on multiple elements.")
//     None
//   }
// }

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

let off: (selection, string) => selection = (sel, eventType) => {
  let removeListener = el => {
    switch WeakMap.get(listeners, el) {
    | Some(dict) =>
      switch Dict.get(dict, eventType) {
      | Some(arr) => {
          arr->Array.forEach(((_, cb)) => {
            el->removeEventListener(eventType, cb)
          })
          Dict.delete(dict, eventType)
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

let remove: selection => unit = sel => {
  let removeSingleElement = el => {
    // Remove all event listeners
    switch WeakMap.get(listeners, el) {
    | Some(dict) =>
      dict->Dict.keysToArray->Array.forEach(eventType => {
        off(Single(Some(el)), eventType)->ignore
      })
    | None => ()
    }

    // Remove the element from the DOM
    el->removeElement
  }

  switch sel {
  | Single(Some(el)) => removeSingleElement(el)
  | Single(None) => Console.error("Elym: remove - Single element is None.")
  | Multiple(elements) => elements->Array.forEach(removeSingleElement)
  }
}