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

// Class getters and setters
@get external classList: Dom.element => Dom.domTokenList = "classList"
@send @variadic
external add: (Dom.domTokenList, array<string>) => unit = "add"
@send @variadic
external removeToken: (Dom.domTokenList, array<string>) => unit = "remove"
@send external contains: (Dom.domTokenList, string) => bool = "contains"
@send external replace: (Dom.domTokenList, string, string) => unit = "replace"

// Text
@get external getTextContent: Dom.element => string = "textContent"
@set external setTextContent: (Dom.element, string) => unit = "textContent"

// Css properties
@val external getComputedStyle: Dom.element => Dom.cssStyleDeclaration = "getComputedStyle"
@send external getPropertyValue: (Dom.cssStyleDeclaration, string) => string = "getPropertyValue"
@get external getStyle: Dom.element => Dom.cssStyleDeclaration = "style"
@send external setProperty: (Dom.cssStyleDeclaration, string, string) => unit = "setProperty"
@send external removeProperty: (Dom.cssStyleDeclaration, string) => unit = "removeProperty"

// Event listeners
@send
external addEventListener: (Dom.element, string, Dom.event => unit) => unit = "addEventListener"
@send
external removeEventListener: (Dom.element, string, Dom.event => unit) => unit =
  "removeEventListener"

@send external removeElement: Dom.element => unit = "remove"

@unboxed
type propertyValue =
  | String(string)
  | Float(float)
  | Boolean(bool)

@val @scope("Object")
external assign: ('a, 'a) => 'a = "assign"

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

let property: (selection, string, ~value: propertyValue=?) => (selection, option<propertyValue>) = (sel, propName, ~value=?) => {
  let getValue: Dom.element => option<propertyValue> = el => {
    let rawValue = el->Obj.magic->Dict.get(propName)->Option.getExn
    switch Type.typeof(rawValue) {
    | #string => rawValue->Obj.magic->String->Some
    // | "number" =>
    //   if Float.isInt(Obj.magic(rawValue)) {
    //     Some(Int(Obj.magic(rawValue)))
    //   } else {
    //     Some(Float(Obj.magic(rawValue)))
    //   }
    | #number => rawValue->Obj.magic->Float->Some
    | #boolean => Some(Boolean(Obj.magic(rawValue)))
    | _ => None
    }
  }

  let setValue: (Dom.element, propertyValue) => Dict.t<'a> = (el, v) => {
    let value = switch v {
    | String(s) => Obj.magic(s)
    | Float(f) => Obj.magic(f)
    | Boolean(b) => Obj.magic(b)
    }
    assign(el->Obj.magic, [(propName, value)]->Dict.fromArray)
  }

  let result = switch (sel, value) {
  | (Single(Some(el)), Some(v)) =>
    setValue(el, v)->ignore
    None
  | (Single(Some(el)), None) =>
    getValue(el)
  | (Single(None), _) =>
    Console.error("Elym: property - Single element is None.")
    None
  | (Multiple(elements), Some(v)) =>
    elements->Array.forEach(el => setValue(el, v)->ignore)
    None
  | (Multiple(_), None) =>
    Console.error("Elym: property - getter not supported on multiple elements.")
    None
  }
  (sel, result)
}

let style: (selection, string, ~value: string=?) => (selection, option<string>) = (sel, styleName, ~value=?) => {
  let getStyleValue: Dom.element => string = el => el
    ->getComputedStyle
    ->getPropertyValue(styleName)

  let setStyleValue: (Dom.element, string) => unit = (el, v) => el
    ->getStyle
    ->setProperty(styleName, v)

  let result = switch (sel, value) {
  | (Single(Some(el)), Some(v)) =>
    setStyleValue(el, v)
    None
  | (Single(Some(el)), None) =>
    Some(getStyleValue(el))
  | (Single(None), _) =>
    Console.error("Elym: style - Single element is None.")
    None
  | (Multiple(elements), Some(v)) =>
    elements->Array.forEach(el => setStyleValue(el, v))
    None
  | (Multiple(_), None) =>
    Console.error("Elym: style - getter not supported on multiple elements.")
    None
  }
  (sel, result)
}

let styled: (selection, string, ~exists: bool=?) => (selection, option<bool>) = (sel, styleName, ~exists=?) => {
  let checkStyle: Dom.element => bool = el => {
    let computedStyle = getComputedStyle(el)
    let value = computedStyle->getPropertyValue(styleName)
    value != "" && value != "none" && value != "initial" && value != "inherit"
  }

  let setStyle: (Dom.element, bool) => unit = (el, shouldExist) => {
    let style = el->getStyle
    if shouldExist {
      // If the style should exist and it doesn't, set it to a default value
      if !checkStyle(el) {
        style->setProperty(styleName, "initial")
      }
    } else {
      // If the style shouldn't exist, remove it
      style->removeProperty(styleName)
    }
  }

  let result = switch (sel, exists) {
  | (Single(Some(el)), Some(true)) =>
    setStyle(el, true)
    None
  | (Single(Some(el)), Some(false)) =>
    setStyle(el, false)
    None
  | (Single(Some(el)), None) =>
    Some(checkStyle(el))
  | (Single(None), _) =>
    Console.error("Elym: styled - Single element is None.")
    None
  | (Multiple(elements), Some(shouldExist)) =>
    elements->Array.forEach(el => setStyle(el, shouldExist))
    None
  | (Multiple(_), None) =>
    Console.error("Elym: styled - getter not supported on multiple elements.")
    None
  }
  (sel, result)
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