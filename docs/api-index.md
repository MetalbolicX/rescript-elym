# API Index

This page documents the core functions and types of the Elym module, which you can use to build your application.

## Selection and the `selection` Variant

**Description:**
Elym is built around the concept of a **selection**, which represents one or more DOM elements you want to manipulate. The `selection` type is a variant:

**Signature:**
```txt
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
```txt
let select: selector => selection
```

**Example:**
```txt
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
```txt
let selectChild: string => selection
```

**Example:**
```txt
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
```txt
let selectAll: selectors => selection
```

**Example:**
```txt
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
```txt
let selectChildren: string => selection
```

**Example:**
```txt
let parent = Elym.select(Selector("#parent"))
let children = parent->Elym.selectChildren(".child")
```

## Modifying Elements Functions

After selecting elements, you can modify them using various functions. These functions allow you to append new elements, set attributes, styles, and more.

### Appending Elements

#### `append`

**Description:**
Appends a new element to the current selection.
