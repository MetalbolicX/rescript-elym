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