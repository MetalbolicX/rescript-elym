# API Index

This page documents the core functions and types of the Elym module, which you can use to build your application.

## Selection and the `selection` Variant

**Description:**
Elym is built around the concept of a **selection**, which represents one or more DOM elements you want to manipulate. The `selection` type is a variant:

**Signature:**
```reason
type selection =
  | Single(option<Dom.element>)
  | Many(array<Dom.element>)
```

- `Single(option<Dom.element>)`: Represents a single DOM element (or `None` if not found).
- `Many(array<Dom.element>)`: Represents multiple DOM elements.

This design allows Elym to provide a consistent, type-safe API for both single and multiple element operations, enabling method chaining and reducing boilerplate when working with the DOM.

## Selection Functions

Selection functions are used to select elements from the DOM. They return a `selection` object that can be used to manipulate the selected elements.

### Single Selection Functions

#### `select`

**Description:**
Selects a single DOM element at `document` level.

Accepted argument (`type selector = Selector(string) | Dom(Dom.element)` variant):

- `Selector(string)`: Pass a CSS selector string, e.g. `Selector("#app")` or `Selector(".item")`.
- `Dom(Dom.element)`: Pass a direct reference to a DOM element, e.g. `Dom(myElement)`.

**Returns:**
A `Single(option<Dom.element>)` selection, which is either the found element or `None` if not found.

**Signature:**
```reason
let select: selector => selection
```

**Example:**
```reason
// Selectt by CSS selector
let header = Elym.select(Selector("#header"))

// Select by direct DOM element reference
@val @scope("document") @return(nullable)
external querySelector: string => option<Dom.element> = "querySelector"

let paragraph = querySelector("#paragraph")
switch paragraph {
| Some(el) => Elym.select(Dom(el))
| None => () // Handle case where element is not found
}
```

#### `selectChild`

**Description:**
Selects a single child element of the current selection.

Accepted argument:
- `string`: A CSS selector string to match the child element, e.g. `"div"` or `".child"`.

**Returns:**
A `Single(option<Dom.element>)` selection of the child element.

**Signature:**
```reason
let selectChild: (selection, string) => selection
```

**Example:**
```reason
let parent = Elym.select(Selector("#parent"))
let child = parent->Elym.selectChild(".child")
```

### Multiple selection functions

#### `selectAll`

**Description:**
Selects multiple DOM elements at `document` level.

Accepted argument (`type selectors = Selector(string) | List(Dom.nodeList)` variant):

- `Selector(string)`: Pass a CSS selector string, e.g. `Selector(".items")`.
- `List(Dom.nodeList)`: Pass a NodeList, e.g. `List(myNodeList)`.

**Returns:**
A `Many(array<Dom.element>)` selection containing all matching elements.

**Signature:**
```reason
let selectAll: selectors => selection
```

**Example:**
```reason
// Select all elements with the class "item"
let items = Elym.selectAll(Selector(".item"))
// Select all <li> elements in a list
let listItems = Elym.selectAll(Selector("ul li"))
```

#### `selectChildren`

**Description:**
Selects multiple child elements of the current selection.

Accepted argument:
- `string`: A CSS selector string to match child elements, e.g. `"div"` or `".child"`.

**Returns:**
A `Many(array<Dom.element>)` selection of the child elements.

**Signature:**
```reason
let selectChildren: (selection, string) => selection
```

**Example:**
```reason
let parent = Elym.select(Selector("#parent"))
let children = parent->Elym.selectChildren(".child")
```

## Modifying Elements Functions

After selecting elements, you can modify them using various functions. These functions allow you to append new elements, set attributes, styles, and more.

### Appending Elements

#### `append`

**Description:**
Appends a new element to the current selection.

Accepted argument (`type element = Dom(Dom.element) | Tag(string)` variant):

- `Dom(Dom.element)`: Pass a direct reference to a DOM element, e.g. `Dom(myElement)`.
- `Tag(string)`: Pass a tag name string, e.g. `Tag("div")` or `Tag("span")`.

**Returns:**
A `selection` representing the updated selection after appending the new element.

**Signature:**
```reason
let append: (selection, element) => selection
```

**Example:**
```reason
// Append a new element using a tag name
Elym.select(Selector("svg"))->Elym.append(Tag("circle"))->ignore

// Append an element using a direct DOM reference
let existingElement = document->createElement("span")
select(Selector("div"))->append(Dom(existingElement))->ignore
```

#### `appendChildren`

**Description:**
Appends multiple new elements to the current selection.

Accepted argument:
- `array<Dom.element>`: An array of DOM elements to append.

**Returns:**
A `selection` representing the updated selection after appending the new elements.

**Signature:**
```reason
let appendChildren: (selection, array<Dom.element>) => selection
```

**Example:**
```reason
let newElements = [document->createElement("div"), document->createElement("span")]
Elym.select(Selector("#container"))->Elym.appendChildren(newElements)->ignore
```

#### `create`

**Description:**
Creates a new element from a tag or a whole DOM node fragment.

Accepted argument (`type elementCreator = Tag(string) | Template(string)` variant):

- `Tag(string)`: Pass a tag name string, e.g. `Tag("div")` or `Tag("span")`.
- `Template(string)`: Pass a template string containing HTML, e.g. `Template("<div class='item'>Item</div>")`.

::: details
In order to use create elements with a given namespace, you need to write the prefix of the namespace in the tag name, e.g. `Tag("svg:circle")` for an SVG circle element.
:::

**Returns:**
A `optiona<Dom.element>` representing the newly created element.

**Signature:**
```reason
let create: elementCreator => option<Dom.element>
```

**Example:**
```reason
// Create a new div element
let newDiv = Elym.create(Tag("div"))
switch newDiv {
| Some(el) => Elym.select(Dom(el))->Elym.append(Dom(el))->ignore
| None => () // Handle case where element creation failed
}

// Create a new element from a template string
let newElement = Elym.create(Template("<li class='item'>Item 1</li><li class='item'>Item 2</li>"))
switch newElement {
| Some(el) => Elym.select(Selector("#list"))->Elym.append(Dom(el))->ignore
| None => () // Handle case where element creation failed
}

// Create an SVG circle element
let svgCircle = Elym.create(Tag("svg:circle"))
switch svgCircle {
| Some(el) => Elym.select(Selector("svg"))->Elym.append(Dom(el))->ignore
| None => () // Handle case where element creation failed
}
```
### Setting Attributes and Styles

#### `attr`

**Description:**
Work as a setter or getter for attributes on the selected elements.

Arguments accpeted:
- `string`: The name of the attribute to set or get.
- `~value: string =?`: The value to set the attribute to when it is used as a setter.

::: details
When ~value is not provided, the function acts as a getter and returns the current value of the attribute.
:::

**Returns:**
A tuple `(selection, option<string>)` where:
- The first element is the updated `selection`.
- The second element is an `option<string>` containing the current value of the attribute (or `None` if not set).

**Signature:**
```reason
let attr: (selection, string, ~value: string=?) => (selection, option<string>)
```

**Example:**
```reason
// Set an attribute
let updatedSelection = Elym.select(Selector("#myElement"))->Elym.attr("data-custom", ~value="myValue")
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
let (sel, attrValue) = Elym.select(Selector("#myElement"))->Elym.attr("data-custom")
switch attrValue {
| Some(value) => Console.log("Attribute value: " ++ value)
| None => Console.log("Attribute not found")
}
```