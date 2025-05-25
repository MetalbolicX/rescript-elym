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

### Multiple selection functions