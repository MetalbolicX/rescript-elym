/**
 * Represents a selection of DOM elements.
 */
type selection =
  | Single(option<Dom.element>)
  | Multiple(array<Dom.element>)

/**
 * A map to store event listeners for DOM elements.
 */
type listenerMap = WeakMap.t<Dom.element, Dict.t<array<(int, Dom.event => unit)>>>

/**
 * Represents a selector for DOM elements.
 */
type selector =
  | Selector(string)
  | Dom(Dom.element)

/**
 * WeakMap to store event listeners.
 */
let listeners: listenerMap = WeakMap.make()

/**
 * Counter for generating unique listener IDs.
 */
let nextListenerId = ref(0)

/**
 * Generates the next unique listener ID.
 */
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

// Add or remove DOM elements
@send external removeElement: Dom.element => unit = "remove"
@val @scope("document")
external createRange: unit => Dom.range = "createRange"
@send external createContextualFragment: (Dom.range, string) => Dom.documentFragment = "createContextualFragment"
@get external firstChild: Dom.documentFragment => option<Dom.node> = "firstChild"
@get external innerHTML: Dom.element => string = "innerHTML"
@send external replaceChildren: (Dom.element, Dom.documentFragment) => unit = "replaceChildren"

/**
 * Represents a value that can be assigned to a property.
 */
@unboxed
type propertyValue =
  | String(string)
  | Float(float)
  | Boolean(bool)

/**
 * Binding for Object.assign.
 * @param {('a, 'a)} - The objects to be merged.
 * @return {'a} - The merged object.
 */
@val @scope("Object")
external assign: ('a, 'a) => 'a = "assign"

/**
 * Selects a single element based on the given selector at document level.
 * @param {selector} selector - The selector to use.
 * @return {selection} - The selected element.
 * @example
 * ```res
 * // Using a css selector
 * let container = Elym.select(Selector("#app"))
 * // or use pass a Dom element, assuming list is an element
 * let list = Elym.select(Dom(list))
 * ```
 */
let select: selector => selection = selector => {
  switch selector {
    | Selector(str) => Single(str->docQuerySelector)
    | Dom(el) => Single(Some(el))
  }
}

/**
 * Selects multiple elements based on the given Css selector .
 * @param {string} selector - The selector to use.
 * @return {selection} - The selected elements.
 * @example
 * ```res
 * let items = Elym.selectAll("li")
 * ```
 */
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

/**
 * Selects a child element from the current selection.
 * @param {selection} selection - The current selection.
 * @param {string} selector - The selector for the child element.
 * @return {selection} - The selected child element.
 */
let selectChild: (selection, string) => selection = (selection, selector) => {
  switch selection {
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

/**
 * Selects multiple child elements from the current selection.
 * @param {selection} selection - The current selection.
 * @param {string} selector - The selector for the child elements.
 * @return {selection} - The selected child elements.
 */
let selectChildren: (selection, string) => selection = (selection, selector) => {
  switch selection {
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

/**
 * Gets or sets the text content of the selected element(s).
 * @param {selection} selection - The current selection.
 * @param {~content: string=?} - Optional text content to set.
 * @return {(selection, option<string>)} - The selection and the text content (if getting).
 * ```res
 * // Setting values
 * select("p")->text(~content="Hello")->ignore
 * // Getting values
 * let (_, text) = select("p")->text
 * ```
 */
let text: (selection, ~content: string=?) => (selection, option<string>) = (selection, ~content=?) => {
  let result = switch (selection, content) {
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
  (selection, result)
}

/**
 * Gets or sets the HTML content of the selected element(s).
 * @param {selection} selection - The current selection.
 * @param {~content: string=?} - Optional HTML content to set.
 * @return {(selection, option<string>)} - The selection and the HTML content (if getting).
 * @example
 * ```res
 * // Setting HTML content
 * select(Selector("#myElement"))->html(~content="<p>New content</p>")->ignore
 * // Getting HTML content
 * let (_, htmlContent) = select(Selector("#myElement"))->html
 * // Setting HTML content for multiple elements
 * selectAll(".myElements")->html(~content="<span>Updated</span>")->ignore
 * ```
 */
let html: (selection, ~content: string=?) => (selection, option<string>) = (selection, ~content=?) => {
  let setHtml = (el: Dom.element, htmlContent: string) => {
    let range = createRange()
    let fragment = range->createContextualFragment(htmlContent)
    el->replaceChildren(fragment)
  }

  let result = switch (selection, content) {
  | (Single(Some(el)), Some(htmlContent)) =>
    el->setHtml(htmlContent)
    None
  | (Single(Some(el)), None) =>
    Some(el->innerHTML)
  | (Single(None), _) =>
    Console.error("Elym: html - Single element is None.")
    None
  | (Multiple(elements), Some(htmlContent)) =>
    elements->Array.forEach(el => el->setHtml(htmlContent))
    None
  | (Multiple(_), None) =>
    Console.error("Elym: html - getter not supported on multiple elements.")
    None
  }
  (selection, result)
}

/**
 * Gets or sets an attribute of the selected element(s).
 * @param {selection} selection - The current selection.
 * @param {string} attrName - The name of the attribute.
 * @param {~value: string=?} - Optional value to set.
 * @return {(selection, option<string>)} - The selection and the attribute value (if getting).
 * ```res
 * // Setting values
 * select("div")->attr("id", ~value="myDiv")->ignore
 * // Getting values
 * let (_, id) = select("div")->attr("id")
 * ```
 */
let attr: (selection, string, ~value: string=?) => (selection, option<string>) = (selection, attrName, ~value=?) => {
  let result = switch (selection, value) {
  | (Single(Some(el)), Some(v)) =>
    setAttribute(el, attrName, v)
    None
  | (Single(Some(el)), None) =>el->getAttribute(attrName)
  | (Single(None), _) =>
    Console.error("Elym: attr - Single element is None.")
    None
  | (Multiple(elements), Some(v)) =>
    elements->Array.forEach(el => el->setAttribute(attrName, v))
    None
  | (Multiple(_), None) =>
    Console.error("Elym: attr - getter not supported on multiple elements.")
    None
  }
  (selection, result)
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

/**
 * Removes the selected element(s) from the DOM.
 * @param {selection} selection - The selection to remove.
 */
let remove: selection => unit = selection => {
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

  switch selection {
  | Single(Some(el)) => removeSingleElement(el)
  | Single(None) => Console.error("Elym: remove - Single element is None.")
  | Multiple(elements) => elements->Array.forEach(removeSingleElement)
  }
}