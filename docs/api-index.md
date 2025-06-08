# API Index

This page documents the core functions and types of the ResForge module, which you can use to build your application.

## Selection and the `selection` Variant

**Description:**
ResForge is built around the concept of a **selection**, which represents one or more DOM elements you want to manipulate. The `selection` type is a variant:

**Signature:**
```reason
type selection =
  | Single(option<Dom.element>)
  | Many(array<Dom.element>)
```

- `Single(option<Dom.element>)`: Represents a single DOM element (or `None` if not found).
- `Many(array<Dom.element>)`: Represents multiple DOM elements.

This design allows ResForge to provide a consistent, type-safe API for both single and multiple element operations, enabling method chaining and reducing boilerplate when working with the DOM.

## Selection Functions

Selection functions are used to select elements from the DOM. They return a `selection` object that can be used to manipulate the selected elements.

### Single Selection Functions

#### `select`

**Description:**
Selects a single DOM element at `document` level.

**Signature:**
```reason
let select: selector => selection
```

Accepted argument (`type selector = Selector(string) | Dom(Dom.element)` variant):

- `Selector(string)`: Pass a CSS selector string, e.g. `Selector("#app")` or `Selector(".item")`.
- `Dom(Dom.element)`: Pass a direct reference to a DOM element, e.g. `Dom(myElement)`.

**Returns:**
A `Single(option<Dom.element>)` selection, which is either the found element or `None` if not found.

**Example:**
```reason
// Selectt by CSS selector
let header = ResForge.select(Selector("#header"))

// Select by direct DOM element reference
@val @scope("document") @return(nullable)
external querySelector: string => option<Dom.element> = "querySelector"

let paragraph = querySelector("#paragraph")
switch paragraph {
| Some(el) => ResForge.select(Dom(el))
| None => () // Handle case where element is not found
}
```

#### `selectChild`

**Description:**
Selects a single child element of the current selection.

**Signature:**
```reason
let selectChild: (selection, string) => selection
```

Accepted argument:
- `string`: A CSS selector string to match the child element, e.g. `"div"` or `".child"`.

**Returns:**
A `Single(option<Dom.element>)` selection of the child element.

**Example:**
```reason
let parent = ResForge.select(Selector("#parent"))
let child = parent->ResForge.selectChild(".child")
```

### Multiple selection functions

#### `selectAll`

**Description:**
Selects multiple DOM elements at `document` level.

**Signature:**
```reason
let selectAll: selectors => selection
```
Accepted argument (`type selectors = Selector(string) | List(Dom.nodeList)` variant):
- `Selector(string)`: Pass a CSS selector string, e.g. `Selector(".items")`.
- `List(Dom.nodeList)`: Pass a NodeList, e.g. `List(myNodeList)`.

**Returns:**
A `Many(array<Dom.element>)` selection containing all matching elements.

**Example:**
```reason
// Select all elements with the class "item"
let items = ResForge.selectAll(Selector(".item"))
// Select all <li> elements in a list
let listItems = ResForge.selectAll(Selector("ul li"))
```

#### `selectChildren`

**Description:**
Selects multiple child elements of the current selection.

**Signature:**
```reason
let selectChildren: (selection, string) => selection
```

Accepted argument:
- `string`: A CSS selector string to match child elements, e.g. `"div"` or `".child"`.

**Returns:**
A `Many(array<Dom.element>)` selection of the child elements.

**Example:**
```reason
let parent = ResForge.select(Selector("#parent"))
let children = parent->ResForge.selectChildren(".child")
```

## Modifying Elements Functions

After selecting elements, you can modify them using various functions. These functions allow you to append new elements, set attributes, styles, and more.

### Appending Elements

#### `append`

**Description:**
Appends a new element to the current selection.

**Signature:**
```reason
let append: (selection, element) => selection
```

Accepted argument (`type element = Dom(Dom.element) | Tag(string)` variant):

- `Dom(Dom.element)`: Pass a direct reference to a DOM element, e.g. `Dom(myElement)`.
- `Tag(string)`: Pass a tag name string, e.g. `Tag("div")` or `Tag("span")`.

**Returns:**
A `selection` representing the updated selection after appending the new element.

**Example:**
```reason
// Append a new element using a tag name
ResForge.select(Selector("svg"))->ResForge.append(Tag("circle"))->ignore

// Append an element using a direct DOM reference
let existingElement = document->createElement("span")
select(Selector("div"))->append(Dom(existingElement))->ignore
```

#### `appendChildren`

**Description:**
Appends multiple new elements to the current selection.

**Signature:**
```reason
let appendChildren: (selection, array<Dom.element>) => selection
```

Accepted argument:
- `array<Dom.element>`: An array of DOM elements to append.

**Returns:**
A `selection` representing the updated selection after appending the new elements.

**Example:**
```reason
let newElements = [document->createElement("div"), document->createElement("span")]
ResForge.select(Selector("#container"))->ResForge.appendChildren(newElements)->ignore
```

#### `create`

**Description:**
Creates a new element from a tag or a whole DOM node fragment.

Accepted argument (`type elementCreator = Tag(string) | Template(string)` variant):

- `Tag(string)`: Pass a tag name string, e.g. `Tag("div")` or `Tag("span")`.
- `Template(string)`: Pass a template string containing HTML, e.g. `Template("<div class='item'>Item</div>")`.

?> In order to use create elements with a given namespace, you need to write the prefix of the namespace in the tag name, e.g. `Tag("svg:circle")` for an SVG circle element.

**Returns:**
A `optiona<Dom.element>` representing the newly created element.

**Signature:**
```reason
let create: elementCreator => option<Dom.element>
```

**Example:**
```reason
// Create a new div element
let newDiv = ResForge.create(Tag("div"))
switch newDiv {
| Some(el) => ResForge.select(Dom(el))->ResForge.append(Dom(el))->ignore
| None => () // Handle case where element creation failed
}

// Create a new element from a template string
let newElement = ResForge.create(Template("<li class='item'>Item 1</li><li class='item'>Item 2</li>"))
switch newElement {
| Some(el) => ResForge.select(Selector("#list"))->ResForge.append(Dom(el))->ignore
| None => () // Handle case where element creation failed
}

// Create an SVG circle element
let svgCircle = ResForge.create(Tag("svg:circle"))
switch svgCircle {
| Some(el) => ResForge.select(Selector("svg"))->ResForge.append(Dom(el))->ignore
| None => () // Handle case where element creation failed
}
```

### Removing Elements

#### `remove`

**Description:**
Removes the selected elements from the DOM.

?> This function remove automatically any event listeners attached to the elements, so you don't need to worry about memory leaks.

**Signature:**
```reason
let remove: selection => unit
```

**Returns:**
- `unit`: This function does not return a value; it simply removes the elements from the DOM.

**Example:**
```reason
// Remove a single element
let elementToRemove = ResForge.select(Selector("#elementToRemove"))
elementToRemove->ResForge.remove

// Remove multiple elements
let elementsToRemove = ResForge.selectAll(Selector(".elementsToRemove"))
elementsToRemove->ResForge.remove
```

### Setting Attributes and Styles

#### `attr`

**Description:**
Work as a setter or getter for attributes on the selected elements.

**Signature:**
```reason
let attr: (selection, string, ~value: string=?) => (selection, option<string>)
```

Arguments accpeted:
- `string`: The name of the attribute to set or get.
- `~value: string =?`: The value to set the attribute to when it is used as a setter.

?> When ~value is not provided, the function acts as a getter and returns the current value of the attribute.

**Returns:**
A tuple `(selection, option<string>)` where:
- The first element is the updated `selection`.
- The second element is an `option<string>` containing the current value of the attribute (or `None` if not set).

**Example:**
```reason
// Set an attribute
let updatedSelection = ResForge.select(Selector("#myElement"))->ResForge.attr("data-custom", ~value="myValue")
switch updatedSelection {
| (sel, Some(value)) => {
    // Successfully set the attribute
    Console.log("Attribute set to: " ++ value)
  }
| (sel, None) => {
    // Attribute was not set
    Console.log("Attribute not set")
  }
}

// Get an attribute
let (sel, attrValue) = ResForge.select(Selector("#myElement"))->ResForge.attr("data-custom")
switch attrValue {
| Some(value) => Console.log("Attribute value: " ++ value)
| None => Console.log("Attribute not found")
}
```

#### `attributed`

**Description:**
Adds or removes an attribute from the selected elements based on a boolean condition.

**Signature:**
```reason
let attributed: (selection, string, ~exists: bool=?) => (selection, option<bool>)
```

Arguments accepted:
- `string`: The name of the attribute to add or remove.
- `~exists: bool =?`: A boolean indicating whether to add (`true`) or remove (`false`) the attribute.

**Returns:**
A tuple `(selection, option<bool>)` where:
- The first element is the updated `selection`.
- The second element is an `option<bool>` indicating whether the attribute was added or removed (or `None` if the operation was not applicable).

**Example:**
```reason
// Add a class to an element
let (updatedSelection, wasAdded) = ResForge.select(Selector("#myElement"))->ResForge.attributed("data-id", ~exists=true)

switch wasAdded {
| Some(true) => Console.log("Attribute added")
| Some(false) => Console.log("Attribute already exists")
| None => Console.log("Attribute operation not applicable")
}
```

#### `classed`

**Description:**
Adds or removes a class from the selected elements based on a boolean condition.

**Signature:**
```reason
let classed: (selection, string, ~exists: bool=?) => (selection, option<bool>)
```

Arguments accepted:
- `string`: The name of the class to add or remove.
- `~exists: bool =?`: A boolean indicating whether to add (`true`) or remove (`false`) the class.
**Returns:**
A tuple `(selection, option<bool>)` where:
- The first element is the updated `selection`.
- The second element is an `option<bool>` indicating whether the class was added or removed (or `None` if the operation was not applicable).

**Example:**
```reason
// Add a class to an element
let (updatedSelection, wasAdded) = ResForge.select(Selector("#myElement"))->ResForge.classed("active", ~exists=true)

switch wasAdded {
| Some(true) => Console.log("Class added")
| Some(false) => Console.log("Class already exists")
| None => Console.log("Class operation not applicable")
}
```

#### `style`

**Description:**
Sets or gets a style property on the selected elements.

**Signature:**
```reason
let styled: (selection, string, ~exists: bool=?) => (selection, option<bool>)
```

Arguments accepted:
- `string`: The name of the style property to set or get.
- `~value: string =?`: The value to set the style property to when it is used as a setter.

?> When ~value is not provided, the function acts as a getter and returns the current value of the style property.

**Returns:**
A tuple `(selection, option<string>)` where:
- The first element is the updated `selection`.
- The second element is an `option<string>` containing the current value of the style property (or `None` if not set).

**Example:**
```reason
// Set a style property
let updatedSelection = ResForge.select(Selector("#myElement"))->ResForge.style("color", ~value="red")

switch updatedSelection {
| (sel, Some(value)) => {
    // Successfully set the style property
    Console.log("Style set to: " ++ value)
  }
| (sel, None) => {
    // Style property was not set
    Console.log("Style not set")
  }
}

// Get a style property
let (sel, styleValue) = ResForge.select(Selector("#myElement"))->ResForge.style("color")

switch styleValue {
| Some(value) => Console.log("Style value: " ++ value)
| None => Console.log("Style not found")
}
```

#### `styled`

**Description:**
Adds or removes a style property from the selected elements based on a boolean condition.

**Signature:**
```reason
let styled: (selection, string, ~exists: bool=?) => (selection, option<bool>)
```

Arguments accepted:
- `string`: The name of the style property to add or remove.
- `~exists: bool =?`: A boolean indicating whether to add (`true`) or remove (`false`) the style property.

**Returns:**
A tuple `(selection, option<bool>)` where:
- The first element is the updated `selection`.
- The second element is an `option<bool>` indicating whether the style property was added or removed (or `None` if the operation was not applicable).

**Example:**
```reason
// Add a style property to an element
let (updatedSelection, wasAdded) = ResForge.select(Selector("#myElement"))->ResForge.styled("color", ~exists=true)

switch wasAdded {
| Some(true) => Console.log("Style added")
| Some(false) => Console.log("Style already exists")
| None => Console.log("Style operation not applicable")
}
```

#### `property`

**Description:**
Sets or gets a property on the selected elements.

**Signature:**
```reason
let property: (selection, string, ~value: propertyValue=?) => (selection, option<propertyValue>)
```

Arguments accepted:
- `string`: The name of the property to set or get.
- `~value: propertyValue =?`: The value to set the property to when it is used as a setter.

?> When ~value is not provided, the function acts as a getter and returns the current value of the property.

**Returns:**
A tuple `(selection, option<propertyValue>)` where:
- The first element is the updated `selection`.
- The second element is an `option<propertyValue>` containing the current value of the property (or `None` if not set).

**Example:**
```reason
// Set a property
let updatedSelection = ResForge.select(Selector("#myElement"))->ResForge.property("value", ~value="New Value")

switch updatedSelection {
| (sel, Some(value)) => {
    // Successfully set the property
    Console.log("Property set to: " ++ value)
  }
| (sel, None) => {
    // Property was not set
    Console.log("Property not set")
  }
}

// Get a property
let (sel, propValue) = ResForge.select(Selector("#myElement"))->ResForge.property("value")

switch propValue {
| Some(value) => Console.log("Property value: " ++ value)
| None => Console.log("Property not found")
}
```

### Text and HTML Content

#### `text`

**Description:**
Sets or gets the text content of the selected elements.

**Signature:**
```reason
let text: (selection, ~content: string=?) => (selection, option<string>)
```

Arguments accepted:
- `~content: string =?`: The text content to set when used as a setter. If not provided, it acts as a getter and returns the current text content.

**Returns:**
A tuple `(selection, option<string>)` where:
- The first element is the updated `selection`.
- The second element is an `option<string>` containing the current text content (or `None` if not set).

**Example:**
```reason
// Set text content
let updatedSelection = ResForge.select(Selector("#myElement"))->ResForge.text(~content="Hello World")

switch updatedSelection {
| (sel, Some(value)) => {
    // Successfully set the text content
    Console.log("Text set to: " ++ value)
  }
| (sel, None) => {
    // Text content was not set
    Console.log("Text not set")
  }
}

// Get text content
let (sel, textValue) = ResForge.select(Selector("#myElement"))->ResForge.text
switch textValue {
| Some(value) => Console.log("Text content: " ++ value)
| None => Console.log("Text content not found")
}
```

#### `html`

**Description:**
Sets or gets the HTML content of the selected elements.

**Signature:**
```reason
let html: (selection, ~content: string=?) => (selection, option<string>)
```

Arguments accepted:
- `~content: string =?`: The HTML content to set when used as a setter. If not provided, it acts as a getter and returns the current HTML content.

**Returns:**
A tuple `(selection, option<string>)` where:
- The first element is the updated `selection`.
- The second element is an `option<string>` containing the current HTML content (or `None` if not set).

**Example:**
```reason
// Set HTML content
let updatedSelection = ResForge.select(Selector("#myElement"))->ResForge.html(~content="<strong>Hello World</strong>")

switch updatedSelection {
| (sel, Some(value)) => {
    // Successfully set the HTML content
    Console.log("HTML set to: " ++ value)
  }
| (sel, None) => {
    // HTML content was not set
    Console.log("HTML not set")
  }
| (sel, None) => Console.log("HTML content not found")
}

// Get HTML content
let (sel, htmlValue) = ResForge.select(Selector("#myElement"))->ResForge.html
switch htmlValue {
| Some(value) => Console.log("HTML content: " ++ value)
| None => Console.log("HTML content not found")
}
```

### Event Handling

#### `on`

**Description:**
Adds synchronous an event listener to the selected elements. The listener is automatically removed when the elements are removed from the DOM.

**Signature:**
```reason
let on: (selection, string, Dom.event => unit) => selection
```

Arguments accepted:
- `string`: The name of the event to listen for, e.g. `"click"` or `"input"`.
- `Dom.event => unit`: A callback function that will be called when the event occurs. The callback receives the event object as an argument.

**Returns:**
A `selection` representing the updated selection after adding the event listener.

**Example:**
```reason
// Add a click event listener
let button = ResForge.select(Selector("#myButton"))
button->ResForge.on("click", _ => {
  Console.log("Button clicked!")
})

// Required external bindings
@get external getInputTarget: Dom.event => Dom.event_like<Dom.htmlInputElement> = "target"
@get external getInputValue: Dom.event_like<Dom.htmlInputElement> => string = "value"

// Add an input event listener
let inputField = ResForge.select(Selector("#myInput"))
inputField->ResForge.on("input", event => {
  let inputVal = event->getInputTarget->getInputValue
  Console.log("Input value changed: " ++ inputVal)
})
```

#### `onAsync`

**Description:**
Adds an asynchronous event listener to the selected elements. The listener is automatically removed when the elements are removed from the DOM.

**Signature:**
```reason
let onAsync: (selection, string, Dom.event => promise<unit>) => selection
```

Arguments accepted:
- `string`: The name of the event to listen for, e.g. `"click"` or `"input"`.
- `Dom.event => promise<unit>`: A callback function that will be called when the event occurs. The callback receives the event object as an argument and returns a promise.

**Returns:**
A `selection` representing the updated selection after adding the asynchronous event listener.

**Example:**
```reason
// Add a click event listener that returns a promise
let button = ResForge.select(Selector("#myButton"))
button->ResForge.onAsync("click", event => {
  Console.log("Button clicked!")
  Js.Promise.resolve()
})

// Required external bindings
@get external getInputTarget: Dom.event => Dom.event_like<Dom.htmlInputElement> = "target"
@get external getInputValue: Dom.event_like<Dom.htmlInputElement> => string = "value"

// Add an input event listener that returns a promise
let inputField = ResForge.select(Selector("#myInput"))
inputField->ResForge.onAsync("input", event => {
  let inputVal = event->getInputTarget->getInputValue
  Console.log("Input value changed: " ++ inputVal)
  Js.Promise.resolve();
})
```

#### `onNthTimes`

**Description:**
Adds an event listener that will be triggered only after the specified number of times the event occurs.

**Signature:**
```reason
let onNthTimes: (selection, string, Dom.event => unit, ~times: int=?) => selection
```

Arguments accepted:
- `string`: The name of the event to listen for, e.g. `"click"` or `"input"`.
- `Dom.event => unit`: A callback function that will be called when the event occurs. The callback receives the event object as an argument.
- `~times: int =?`: The number of times the event must occur before the listener is triggered. Defaults to `1`.

**Returns:**
A `selection` representing the updated selection after adding the event listener.

**Example:**
```reason
// Add a click event listener that triggers after 3 clicks
let button = ResForge.select(Selector("#myButton"))
button->ResForge.onNthTimes("click", _ => {
  Console.log("Button clicked 3 times!")
}, ~times=3)

// Required external bindings
@get external getInputTarget: Dom.event => Dom.event_like<Dom.htmlInputElement> = "target"
@get external getInputValue: Dom.event_like<Dom.htmlInputElement> => string = "value"
// Add an input event listener that triggers after 5 inputs
let inputField = ResForge.select(Selector("#myInput"))
inputField->ResForge.onNthTimes("input", event => {
  let inputVal = event->getInputTarget->getInputValue
  Console.log("Input value changed: " ++ inputVal)
}, ~times=5)
```

#### `onAsyncNthTimes`

**Description:**
Adds an asynchronous event listener that will be triggered only after the specified number of times the event occurs.

**Signature:**
```reason
let onAsyncNthTimes: (selection, string, Dom.event => promise<unit>, ~times: int=?) => selection
```

Arguments accepted:
- `string`: The name of the event to listen for, e.g. `"click"` or `"input"`.
- `Dom.event => promise<unit>`: A callback function that will be called when the event occurs. The callback receives the event object as an argument and returns a promise.
- `~times: int =?`: The number of times the event must occur before the listener is triggered. Defaults to `1`.

**Returns:**
A `selection` representing the updated selection after adding the asynchronous event listener.

**Example:**
```reason
// Add a click event listener that triggers after 3 clicks
let button = ResForge.select(Selector("#myButton"))
button->ResForge.onAsyncNthTimes("click", event => {
  Console.log("Button clicked 3 times!")
  Js.Promise.resolve()
}, ~times=3)

// Required external bindings
@get external getInputTarget: Dom.event => Dom.event_like<Dom.htmlInputElement> = "target"
@get external getInputValue: Dom.event_like<Dom.htmlInputElement> => string = "value"

// Add an input event listener that triggers after 5 inputs
let inputField = ResForge.select(Selector("#myInput"))
inputField->ResForge.onAsyncNthTimes("input", event => {
  let inputVal = event->getInputTarget->getInputValue
  Console.log("Input value changed: " ++ inputVal)
  Js.Promise.resolve()
}, ~times=5)
```

#### `off`

**Description:**
Removes an event listener from the selected elements.

**Signature:**
```reason
let off: (selection, string) => selection
```

Arguments accepted:
- `string`: The name of the event to remove the listener for, e.g. `"click"` or `"input"`.

**Returns:**
A `selection` representing the updated selection after removing the event listener.

**Example:**
```reason
// Remove a click event listener
let button = ResForge.select(Selector("#myButton"))
button->ResForge.off("click")
```

## Utility Functions

#### `call`

**Description:**
Runs a function on the selected elements. This is useful for applying custom logic to the selection.

**Signature:**
```reason
let call: (selection, selection => selection) => selection
```

Arguments accepted:
- `selection => selection`: A function that takes a `selection` and returns a modified `selection`.

**Returns:**
A `selection` representing the updated selection after applying the function.

**Example:**
```reason
// Run a custom function on the selection
let customFn = selection => {
  // Custom logic here
  selection->ResForge.text(~content="Custom text")
}
```

#### `each`

**Description:**
Applies a function to each element in the selection.

**Signature:**
```reason
let each: (selection, (Dom.element, int) => unit) => selection
```

Arguments accepted:
- `(Dom.element, int) => unit`: A function that takes a `Dom.element` and its index in the selection, and performs some action.

**Returns:**
A `selection` representing the updated selection after applying the function to each element.

**Example:**
```reason
// Apply a function to each element in the selection
let items = ResForge.selectAll(Selector(".item"))
items->ResForge.each((el, i) => {
  Console.log2("Item " ++ string_of_int(i) ++ ", el)
})
```