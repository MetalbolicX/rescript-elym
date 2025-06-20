/**
 * Represents a selection of DOM elements.
 */
type selection =
  | Single(option<Dom.element>)
  | Many(array<Dom.element>)

/**
 * A map to store event listeners for DOM elements.
 */
// type listenerMap = WeakMap.t<Dom.element, Dict.t<array<(int, Dom.event => unit)>>>
type listenerMap = WeakMap.t<Dom.element, Dict.t<array<(string, Dom.event => unit)>>>

/**
 * Represents a selector for DOM elements.
 */
type selector =
  | Selector(string)
  | Dom(Dom.element)

/**
 * Represents a selector for the case of multiple elements.
 */
type selectors =
  | Selector(string)
  | List(Dom.nodeList)

/**
 * Represents a the element to added in the DOM.
 */
type element =
  | Dom(Dom.element)
  | Tag(string)

/**
 * WeakMap to store event listeners.
 */
let listeners: listenerMap = WeakMap.make()


// Random function
@val @scope("crypto")
external randomUUID: unit => string = "randomUUID"

// Selectors
@val @scope("document") @return(nullable)
external docQuerySelector: string => option<Dom.element> = "querySelector"
@send @return(nullable)
external querySelector: (Dom.element, string) => option<Dom.element> = "querySelector"
@val @scope("document")
external docQuerySelectorAll: string => Dom.nodeList = "querySelectorAll"
@send external querySelectorAll: (Dom.element, string) => Dom.nodeList = "querySelectorAll"
// @get external nodeListLength: Dom.nodeList => int = "length"
// @send external item: (Dom.nodeList, int) => Nullable.t<Dom.element> = "item"
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
@get external innerHTML: Dom.element => string = "innerHTML"
@send external replaceChildren: (Dom.element, Dom.documentFragment) => unit = "replaceChildren"

@send external appendChild: (Dom.element, Dom.element) => unit = "appendChild"
@get external ownerDocument: Dom.element => Dom.document = "ownerDocument"
@send external createElement: (Dom.document, string) => Dom.element = "createElement"
@send external createElementNS: (Dom.document, string, string) => Dom.element = "createElementNS"
@get external namespaceURI: Dom.element => option<string> = "namespaceURI"
@send @variadic
external appendMany: (Dom.element, array<Dom.element>) => unit = "append"

@send external createContextualFragment: (Dom.range, string) => Dom.documentFragment = "createContextualFragment"
@val @scope("document") external createElementNoDoc: string => Dom.element = "createElement"
@val @scope("document") external createElementNSNoDoc: (string, string) => Dom.element = "createElementNS"
@get external firstElementChild: Dom.documentFragment => Null.t<Dom.element> = "firstElementChild"

@val @scope("Array")
external toArray: Dom.nodeList => array<Dom.element> = "from"

/**
 * Represents a value that can be assigned to a property.
 */
@unboxed
type propertyValue =
  | String(string)
  | Number(float)
  | Boolean(bool)

type elementCreator =
  | Tag(string)
  | Template(string)

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
 * let container = ResForge.select(Selector("#app"))
 * // or use pass a Dom element, assuming list is an element
 * let list = ResForge.select(Dom(list))
 * ```
 */
let select: selector => selection = selector => {
  switch selector {
    | Selector(str) => Single(str->docQuerySelector)
    | Dom(el) => Single(Some(el))
  }
}

/**
 * Selects multiple elements based on the given selector at document level.
 * @param {selectors} selector - The selector to use.
 * @return {selection} - The selected elements.
 * @example
 * ```res
 * // Using a css selector
 * let containers = ResForge.selectAll(Selector(".container"))
 * // or use pass a Dom element, assuming list is an element
 * let lists = ResForge.selectAll(List(list))
 * ```
 */
let selectAll: selectors => selection = selector => {
  switch selector {
  | Selector(str) => Many(str->docQuerySelectorAll->toArray)
  | List(elements) => Many(elements->toArray)
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
  | Many(elements) =>
    let firstMatch = elements->Array.reduce(None, (first, el) => {
      switch first {
      | Some(_) => first // Already found a match
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
      let elements = element->querySelectorAll(selector)->toArray
      switch elements {
      | [] => Many([])
      | _ => Many(elements)
      }
    | Single(None) => Many([])
    | Many(elements) =>
      let allMatches = elements->Array.reduce([], (list, el) => {
        let matches = el->querySelectorAll(selector)->toArray
        switch matches {
        | [] => list
        | _ => [...list, ...matches]
        }
      })
      Many(allMatches)
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
    Console.error("ResForge: text - Single element is None.")
    None
  | (Many(elements), Some(text)) =>
    elements->Array.forEach(el => el->setTextContent(text))
    None
  | (Many(_), None) =>
    Console.error("ResForge: text - getter not supported on multiple elements.")
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
    Console.error("ResForge: html - Single element is None.")
    None
  | (Many(elements), Some(htmlContent)) =>
    elements->Array.forEach(el => el->setHtml(htmlContent))
    None
  | (Many(_), None) =>
    Console.error("ResForge: html - getter not supported on multiple elements.")
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
    Console.error("ResForge: attr - Single element is None.")
    None
  | (Many(elements), Some(v)) =>
    elements->Array.forEach(el => el->setAttribute(attrName, v))
    None
  | (Many(_), None) =>
    Console.error("ResForge: attr - getter not supported on multiple elements.")
    None
  }
  (selection, result)
}

/**
 * Checks, sets, or removes the existence of an attribute on the selected element(s).
 * @param {selection} selection - The current selection.
 * @param {string} attrName - The name of the attribute.
 * @param {~exists: bool=?} - Optional boolean to set or remove the attribute.
 * @return {(selection, option<bool>)} - The selection and the attribute existence (if checking).
 * @example
 * ```res
 * // Check if an attribute exists
 * let (_, hasAttr) = select(Selector("#myElement"))->attributed("data-custom")
 * // Set an attribute
 * select(Selector("#myElement"))->attributed("data-custom", ~exists=true)->ignore
 * // Remove an attribute
 * select(Selector("#myElement"))->attributed("data-custom", ~exists=false)->ignore
 * ```
 */
let attributed: (selection, string, ~exists: bool=?) => (selection, option<bool>) = (selection, attrName, ~exists=?) => {
  let result = switch (selection, exists) {
  | (Single(Some(el)), Some(true)) =>
    el->setAttribute(attrName, "")
    None
  | (Single(Some(el)), Some(false)) =>
    el->removeAttribute(attrName)
    None
  | (Single(Some(el)), None) =>
    Some(el->hasAttribute(attrName))
  | (Single(None), _) =>
    Console.error("ResForge: attributed - Single element is None.")
    None
  | (Many(elements), Some(true)) =>
    elements->Array.forEach(el => el->setAttribute(attrName, ""))
    None
  | (Many(elements), Some(false)) =>
    elements->Array.forEach(el => el->removeAttribute(attrName))
    None
  | (Many(_), None) =>
    Console.error("ResForge: attributed - getter not supported on multiple elements.")
    None
  }
  (selection, result)
}

/**
 * Adds, removes, or checks for a class on the selected element(s).
 * @param {selection} selection - The current selection.
 * @param {string} className - The name of the class.
 * @param {~exists: bool=?} - Optional boolean to add or remove the class.
 * @return {(selection, option<bool>)} - The selection and the class existence (if checking).
 * @example
 * ```res
 * // Check if a class exists
 * let (_, hasClass) = select(Selector(".myElement"))->classed("active")
 * // Add a class
 * select(Selector(".myElement"))->classed("active", ~exists=true)->ignore
 * // Remove a class
 * select(Selector(".myElement"))->classed("active", ~exists=false)->ignore
 * ```
 */
let classed: (selection, string, ~exists: bool=?) => (selection, option<bool>) = (selection, className, ~exists=?) => {
  let result = switch (selection, exists) {
  | (Single(Some(el)), Some(true)) =>
    el->classList->add([className])
    None
  | (Single(Some(el)), Some(false)) =>
    el->classList->removeToken([className])
    None
  | (Single(Some(el)), None) =>
    Some(el->classList->contains(className))
  | (Single(None), _) =>
    Console.error("ResForge: classed - Single element is None.")
    None
  | (Many(elements), Some(true)) =>
    elements->Array.forEach(el => el->classList->add([className]))
    None
  | (Many(elements), Some(false)) =>
    elements->Array.forEach(el => el->classList->removeToken([className]))
    None
  | (Many(_), None) =>
    Console.error("ResForge: classed - getter not supported on multiple elements.")
    None
  }
  (selection, result)
}

/**
 * Replaces a class with another on the selected element(s).
 * @param {selection} selection - The current selection.
 * @param {string} oldClass - The class to be replaced.
 * @param {string} newClass - The new class to add.
 * @return {selection} - The updated selection.
 * @example
 * ```res
 * select(Selector(".myElement"))->replaceClass("old-class", "new-class")->ignore
 * ```
 */
let replaceClass: (selection, string, string) => selection = (selection, oldClass, newClass) => {
  switch selection {
  | Single(Some(el)) => el->classList->replace(oldClass, newClass)
  | Single(None) => Console.error("ResForge: replaceClass - Single element is None")
  | Many(elements) => elements->Array.forEach(el => el->classList->replace(oldClass, newClass))
  }
  selection
}

/**
 * Gets or sets a property of the selected element(s).
 * @param {selection} selection - The current selection.
 * @param {string} propName - The name of the property.
 * @param {~value: propertyValue=?} - Optional value to set.
 * @return {(selection, option<propertyValue>)} - The selection and the property value (if getting).
 * @example
 * ```res
 * // Set a property
 * select(Selector("#myInput"))->property("value", ~value=String("New Value"))->ignore
 * // Get a property
 * let (_, value) = select(Selector("#myInput"))->property("value")
 * ```
 */
let property: (selection, string, ~value: propertyValue=?) => (selection, option<propertyValue>) = (selection, propName, ~value=?) => {
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
    | #number => rawValue->Obj.magic->Number->Some
    | #boolean => Some(Boolean(Obj.magic(rawValue)))
    | _ => None
    }
  }

  let setValue: (Dom.element, propertyValue) => Dict.t<'a> = (el, v) => {
    let value = switch v {
    | String(s) => Obj.magic(s)
    | Number(f) => Obj.magic(f)
    | Boolean(b) => Obj.magic(b)
    }
    assign(el->Obj.magic, [(propName, value)]->Dict.fromArray)
  }

  let result = switch (selection, value) {
  | (Single(Some(el)), Some(v)) =>
    setValue(el, v)->ignore
    None
  | (Single(Some(el)), None) =>
    getValue(el)
  | (Single(None), _) =>
    Console.error("ResForge: property - Single element is None.")
    None
  | (Many(elements), Some(v)) =>
    elements->Array.forEach(el => setValue(el, v)->ignore)
    None
  | (Many(_), None) =>
    Console.error("ResForge: property - getter not supported on multiple elements.")
    None
  }
  (selection, result)
}

/**
 * Gets or sets a style property of the selected element(s).
 * @param {selection} selection - The current selection.
 * @param {string} styleName - The name of the style property.
 * @param {~value: string=?} - Optional value to set.
 * @return {(selection, option<string>)} - The selection and the style value (if getting).
 * @example
 * ```res
 * // Set a style
 * select(Selector(".myElement"))->style("color", ~value="red")->ignore
 * // Get a style
 * let (_, color) = select(Selector(".myElement"))->style("color")
 * ```
 */
let style: (selection, string, ~value: string=?) => (selection, option<string>) = (selection, styleName, ~value=?) => {
  let getStyleValue: Dom.element => string = el => el
    ->getComputedStyle
    ->getPropertyValue(styleName)

  let setStyleValue: (Dom.element, string) => unit = (el, v) => el
    ->getStyle
    ->setProperty(styleName, v)

  let result = switch (selection, value) {
  | (Single(Some(el)), Some(v)) =>
    setStyleValue(el, v)
    None
  | (Single(Some(el)), None) =>
    Some(getStyleValue(el))
  | (Single(None), _) =>
    Console.error("ResForge: style - Single element is None.")
    None
  | (Many(elements), Some(v)) =>
    elements->Array.forEach(el => setStyleValue(el, v))
    None
  | (Many(_), None) =>
    Console.error("ResForge: style - getter not supported on multiple elements.")
    None
  }
  (selection, result)
}

/**
 * Checks, sets, or removes the existence of a style property on the selected element(s).
 * @param {selection} selection - The current selection.
 * @param {string} styleName - The name of the style property.
 * @param {~exists: bool=?} - Optional boolean to set or remove the style.
 * @return {(selection, option<bool>)} - The selection and the style existence (if checking).
 * @example
 * ```res
 * // Check if a style exists
 * let (_, hasStyle) = select(Selector(".myElement"))->styled("display")
 * // Set a style to its initial value
 * select(Selector(".myElement"))->styled("display", ~exists=true)->ignore
 * // Remove a style
 * select(Selector(".myElement"))->styled("display", ~exists=false)->ignore
 * ```
 */
let styled: (selection, string, ~exists: bool=?) => (selection, option<bool>) = (selection, styleName, ~exists=?) => {
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

  let result = switch (selection, exists) {
  | (Single(Some(el)), Some(true)) =>
    setStyle(el, true)
    None
  | (Single(Some(el)), Some(false)) =>
    setStyle(el, false)
    None
  | (Single(Some(el)), None) =>
    Some(checkStyle(el))
  | (Single(None), _) =>
    Console.error("ResForge: styled - Single element is None.")
    None
  | (Many(elements), Some(shouldExist)) =>
    elements->Array.forEach(el => setStyle(el, shouldExist))
    None
  | (Many(_), None) =>
    Console.error("ResForge: styled - getter not supported on multiple elements.")
    None
  }
  (selection, result)
}

/**
 * Adds an event listener to the selected element(s).
 * @param {selection} selection - The current selection.
 * @param {string} eventType - The type of event to listen for.
 * @param {Dom.event => unit} callback - The callback function to execute when the event occurs.
 * @return {selection} - The updated selection.
 * @example
 * ```res
 * select(Selector("#myButton"))->on("click", _ => {
 *   Console.log("Button clicked!")
 * })->ignore
 * ```
 */
let on: (selection, string, Dom.event => unit) => selection = (selection, eventType, callback) => {
  let addListener = el => {
    let id = randomUUID()
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

  switch selection {
  | Single(Some(el)) => addListener(el)
  | Single(None) => Console.error("ResForge: on - Single element is None.")
  | Many(elements) => elements->Array.forEach(addListener)
  }
  selection
}

/**
 * Adds an asynchronous event listener to the selected element(s).
 * @param {selection} selection - The current selection.
 * @param {string} eventType - The type of event to listen for.
 * @param {Dom.event => promise<unit>} callback - The asynchronous callback function to execute when the event occurs.
 * @return {selection} - The updated selection.
 * @example
 * ```res
 * select(Selector("#myButton"))->onAsync("click", async _ => {
 *   await Js.Promise.resolve()
 *   Console.log("Button clicked!")
 * })->ignore
 * ```
 */
let onAsync: (selection, string, Dom.event => promise<unit>) => selection = (selection, eventType, callback) => {
  let addListener = el => {
    let id = randomUUID()
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
    let asyncWrapper = (event: Dom.event) => {
      callback(event)->ignore // Execute the promise but ignore its result
    }
    Dict.set(listenersForElement, eventType, [(id, asyncWrapper), ...listenersForEvent])
    el->addEventListener(eventType, asyncWrapper)
  }

  switch selection {
  | Single(Some(el)) => addListener(el)
  | Single(None) => Console.error("ResForge: onAsync - Single element is None.")
  | Many(elements) => elements->Array.forEach(addListener)
  }
  selection
}

/**
 * Adds an event listener that will be triggered only after the event has occurred a specified number of times.
 * @param {selection} selection - The current selection.
 * @param {string} eventType - The type of event to listen for.
 * @param {Dom.event => unit} callback - The callback function to execute when the event occurs.
 * @param {~times: int=} - Optional number of times the event must occur before the callback is executed.
 * @return {selection} - The updated selection.
 * @example
 * ```res
 * select(Selector("#myButton"))->onNthTimes("click", _ => {
 *   Console.log("Button clicked 3 times!")
 * }, ~times=3)->ignore
 * ```
 */
let onNthTimes: (selection, string, Dom.event => unit, ~times: int=?) => selection = (selection, eventType, callback, ~times=1) => {
  let addListener = el => {
    let id = randomUUID()
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

    let count = ref(0)
    let wrappedCallback = (event: Dom.event) => {
      count := !count + 1
      if !count >= times {
        el->removeEventListener(eventType, wrappedCallback)
      }
      callback(event)
    }

    Dict.set(listenersForElement, eventType, [(id, wrappedCallback), ...listenersForEvent])
    el->addEventListener(eventType, wrappedCallback)
  }

  switch selection {
  | Single(Some(el)) => addListener(el)
  | Single(None) => Console.error("ResForge: onNthTimes - Single element is None.")
  | Many(elements) => elements->Array.forEach(addListener)
  }
  selection
}

/**
 * Adds an asynchronous event listener that will be triggered only after the event has occurred a specified number of times.
 * @param {selection} selection - The current selection.
 * @param {string} eventType - The type of event to listen for.
 * @param {Dom.event => promise<unit>} callback - The asynchronous callback function to execute when the event occurs.
 * @param {~times: int=} - Optional number of times the event must occur before the callback is executed.
 * @return {selection} - The updated selection.
 * @example
 * ```res
 * select(Selector("#myButton"))->onAsyncNthTimes("click", async _ => {
 *   await Js.Promise.resolve()
 *   Console.log("Button clicked 3 times!")
 * }, ~times=3)->ignore
 * ```
 */
let onAsyncNthTimes: (selection, string, Dom.event => promise<unit>, ~times: int=?) => selection = (selection, eventType, callback, ~times=1) => {
  let addListener = el => {
    let id = randomUUID()
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

    let count = ref(0)
    let wrappedCallback = (event: Dom.event) => {
      count := !count + 1
      if !count >= times {
        el->removeEventListener(eventType, wrappedCallback)
      }
      callback(event)->ignore // Execute the promise but ignore its result
    }

    Dict.set(listenersForElement, eventType, [(id, wrappedCallback), ...listenersForEvent])
    el->addEventListener(eventType, wrappedCallback)
  }

  switch selection {
  | Single(Some(el)) => addListener(el)
  | Single(None) => Console.error("ResForge: onAsyncNthTimes - Single element is None.")
  | Many(elements) => elements->Array.forEach(addListener)
  }
  selection
}


/**
 * Removes event listeners of a specific type from the selected element(s).
 * @param {selection} selection - The current selection.
 * @param {string} eventType - The type of event to remove listeners for.
 * @return {selection} - The updated selection.
 * @example
 * ```res
 * select(Selector("#myButton"))->off("click")->ignore
 * ```
 */
let off: (selection, string) => selection = (selection, eventType) => {
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
  switch selection {
  | Single(Some(el)) => removeListener(el)
  | Single(None) => Console.error("ResForge: off - Single element is None.")
  | Many(elements) => elements->Array.forEach(removeListener)
  }
  selection
}

/**
 * Appends a new element to each element in the selection.
 * @param {selection} selection - The current selection.
 * @param {element} typeOrElement - The type of element to append (e.g., "p", "circle") or a DOM element to append.
 * @return {selection} - A new selection containing the appended elements.
 * @example
 * ```res
 * // Append a paragraph to each div
 * select(Selector("div"))->append(Tag("p"))->ignore
 * // Append an SVG circle to an SVG element
 * select(Selector("svg"))->append(Tag("circle"))->ignore
 * // Append an existing DOM element
 * let existingElement = document->createElement("span")
 * select(Selector("div"))->append(Dom(existingElement))->ignore
 * ```
 */
let append: (selection, element) => selection = (selection, elementType) => {
  // Helper function to create an element, inheriting namespace from parent if needed
  let createElement: (Dom.element, string) => Dom.element = (parentEl, tag) => {
    let ownerDoc = parentEl->ownerDocument
    let parentNamespace = parentEl->namespaceURI

    switch (parentNamespace, tag) {
    | (Some("http://www.w3.org/2000/svg"), _) =>
      // If parent is SVG, create element in SVG namespace
      ownerDoc->createElementNS("http://www.w3.org/2000/svg", tag)
    | (Some("http://www.w3.org/1998/Math/MathML"), _) =>
      ownerDoc->createElementNS("http://www.w3.org/1998/Math/MathML", tag)
    | (_, "svg") =>
      // If tag is "svg", always create in SVG namespace
      ownerDoc->createElementNS("http://www.w3.org/2000/svg", tag)
    | (_, "math") =>
      ownerDoc->createElementNS("http://www.w3.org/1998/Math/MathML", tag)
    | _ =>
      // For all other cases, create in HTML namespace
      ownerDoc->createElement(tag)
    }
  }

  // Function to append a new element or an existing element to a parent element
  let appendElement: Dom.element => Dom.element = parentEl => {
    let newEl = switch elementType {
    | Tag(tag) => createElement(parentEl, tag)
    | Dom(element) => element
    }
    parentEl->appendChild(newEl)
    newEl
  }

  // Apply the append operation based on the selection type
  switch selection {
  | Single(Some(el)) =>
    let newEl = el->appendElement
    Single(Some(newEl))
  | Single(None) =>
    Console.error("ResForge: append - Single element is None.")
    Single(None)
  | Many(elements) =>
    let newElements = elements->Array.map(appendElement)
    Many(newElements)
  }
}

/**
 * Appends multiple child elements to each element in the selection.
 * @param {selection} selection - The current selection.
 * @param {array<Dom.element>} children - An array of DOM elements to append.
 * @return {selection} - A new selection containing the appended elements.
 * @example
 * ```res
 * let child1 = document->Document.createElement("div")
 * let child2 = document->Document.createElement("span")
 * select(Selector("#parent"))->appendChildren([child1, child2])->ignore
 * ```
 */
let appendChildren: (selection, array<Dom.element>) => selection = (selection, children) => {
  // Function to append children to a parent element
  let appendToElement = (parentEl) => {
    parentEl->appendMany(children)
    children
  }

  // Apply the append operation based on the selection type
  switch selection {
  | Single(Some(el)) =>
    let newElements = appendToElement(el)
    Many(newElements)
  | Single(None) =>
    Console.error("ResForge: appendChildren - Single element is None.")
    Many([])
  | Many(elements) =>
    let newElements = elements->Array.flatMap(el => appendToElement(el))
    Many(newElements)
  }
}

/**
 * Invokes the specified function exactly once, passing in this selection.
 * Returns the original selection. This facilitates method chaining.
 * @param {selection} selection - The current selection.
 * @param {selection => selection} func - The function to call.
 * @return {selection} - The original selection.
 * @example
 * ```res
 * // Using an arrow function
 * select(Selector("p"))->call(p => p->attr("id", ~value="something"))->ignore
 *
 * // Using a named function
 * let setColor = selection => {
 *   selection->style("color", ~value="red")->ignore
 *   selection
 * }
 * select(Selector("div"))->call(setColor)->ignore
 *
 * // Chaining multiple calls
 * select(Selector("div"))
 * ->call(el => el->attr("id", ~value="myDiv")->ignore)
 * ->call(el => el->style("color", ~value="blue")->ignore)
 * ->ignore
 * ```
 */
let call: (selection, selection => selection) => selection = (selection, func) => {
  func(selection)->ignore
  selection
}

/**
 * Invokes the specified function for each element in the selection.
 * @param {selection} selection - The current selection.
 * @param {(Dom.element, int) => unit} func - The function to call for each element.
 * @return {selection} - The original selection.
 * @example
 * ```res
 * // Simple example
 * selectAll(".item")->each((el, i) => {
 *   el->Dom.Element.setAttribute("data-index", Belt.Int.toString(i))
 * })->ignore
 *
 * // Example with text content
 * selectAll("li")->each((el, i) => {
 *   el->Dom.Element.setTextContent(`Item ${Belt.Int.toString(i + 1)}`)
 * })->ignore
 *
 * // Example with nested selections
 * select("#list")->each((parentEl, _) => {
 *   selectAll("li", parentEl)->each((childEl, i) => {
 *     childEl->Dom.Element.setTextContent(`Child ${Belt.Int.toString(i + 1)}`)
 *   })->ignore
 * })->ignore
 * ```
 */
let each: (selection, (Dom.element, int) => unit) => selection = (selection, func) => {
  switch selection {
  | Single(Some(el)) =>
    func(el, 0)
  | Single(None) =>
    Console.error("ResForge: each - Single element is None.")
  | Many(elements) =>
    elements->Array.forEachWithIndex((el, i) => {
      func(el, i)
    })
  }
  selection
}

/**
 * Creates a single DOM element from a tag name.
 * @param {string} tagName - The tag name, optionally prefixed with "svg:" or "math:" for namespace.
 * @return {Dom.element} - The created DOM element.
 */
let createElement: string => Dom.element = tagName => {
  let (namespace, tag) = switch String.split(tagName, ":") {
  | [ns, t] when ns == "svg" => (Some("http://www.w3.org/2000/svg"), t)
  | [ns, t] when ns == "math" => (Some("http://www.w3.org/1998/Math/MathML"), t)
  | _ => (None, tagName)
  }

  switch namespace {
  | Some(ns) => createElementNSNoDoc(ns, tag)
  | None => createElementNoDoc(tag)
  }
}

/**
 * Creates DOM elements from an HTML template string.
 * @param {string} html - The HTML template string.
 * @return {array<Dom.element>} - An array of created DOM elements.
 */
let createFromTemplate: string => option<Dom.element> = html => {
  let fragment = createRange()->createContextualFragment(html)
  switch fragment->firstElementChild {
    | Value(el) => Some(el)
    | Null => None
  }
}

/**
 * Creates a new DOM element or elements from a tag or HTML template.
 * @param {elementCreator} creator - The tag name or HTML template to create element(s) from.
 * @return {option<Dom.element>} - A new element(s) created.
 * @example
 * ```res
 * // Create a single element
 * let divSelection = ResForge.create(Tag("div"))
 *
 * // Create an SVG element
 * let svgCircle = ResForge.create(Tag("svg:circle"))
 *
 * // Create multiple elements from a template
 * let listItems = ResForge.create(Template("<li>Item 1</li><li>Item 2</li><li>Item 3</li>"))
 * ```
 */
let create: elementCreator => option<Dom.element> = creator => {
  switch creator {
  | Tag(tagName) =>
      let element = createElement(tagName)
      Some(element)
  | Template(html) => createFromTemplate(html)
  }
}

/**
 * Recursively removes all event listeners from an element and its children.
 * @param {Dom.element} element - The root element to start removing listeners from.
 */
let rec removeAllEventListeners = (element: Dom.element) => {
  // Remove all event listeners from the current element
  switch WeakMap.get(listeners, element) {
  | Some(dict) => {
      dict->Dict.keysToArray->Array.forEach(eventType => {
        off(Single(Some(element)), eventType)->ignore
      })
      let _ = WeakMap.delete(listeners, element)
    }
  | None => ()
  }

  // Get all child elements
  let children = element->querySelectorAll("*")->toArray
  children->Array.forEach(child => {
    switch Obj.magic(child)["nodeType"] {
    | 1 => removeAllEventListeners(Obj.magic(child)) // Element nodes
    | _ => () // Ignore non-element nodes
    }
  })
}

/**
 * Removes the selected element(s) from the DOM and cleans up all associated event listeners.
 * @param {selection} selection - The selection to remove.
 * @example
 * ```res
 * select(Selector("#myButton"))->removeWithListeners
 * ```
 */
let removeWithListeners: selection => unit = selection => {
  let removeSingleElement = el => {
    removeAllEventListeners(el)
    el->removeElement
  }

  switch selection {
  | Single(Some(el)) => removeSingleElement(el)
  | Single(None) => Console.error("ResForge: removeWithListeners - Single element is None.")
  | Many(elements) => elements->Array.forEach(removeSingleElement)
  }
}

/**
 * Removes the selected element(s) from the DOM and cleans up all associated event listeners.
 * @param {selection} selection - The selection to remove.
 * @example
 * ```res
 * select(Selector("#myButton"))->remove
 * ```
 */
let remove: selection => unit = removeWithListeners