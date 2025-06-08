/**
 * Represents a selection of DOM elements.
 */
type selection =
  | Single(option<Dom.element>)
  | Many(array<Dom.element>)

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
 * Represents the element to be added in the DOM.
 */
type element =
  | Dom(Dom.element)
  | Tag(string)

/**
 * Represents a value that can be assigned to a property.
 */
@unboxed
type propertyValue =
  | String(string)
  | Number(float)
  | Boolean(bool)

/**
 * Represents a creator for DOM elements.
 */
type elementCreator =
  | Tag(string)
  | Template(string)

/**
 * Appends a new element to each element in the selection.
 * @param {selection} selection - The current selection.
 * @param {element} typeOrElement - The type of element to append (e.g., "p", "circle") or a DOM element to append.
 * @return {selection} - A new selection containing the appended elements.
 */
let append: (selection, element) => selection

/**
 * Appends multiple child elements to each element in the selection.
 * @param {selection} selection - The current selection.
 * @param {array<Dom.element>} children - An array of DOM elements to append.
 * @return {selection} - A new selection containing the appended elements.
 */
let appendChildren: (selection, array<Dom.element>) => selection

/**
 * Gets or sets an attribute of the selected element(s).
 * @param {selection} selection - The current selection.
 * @param {string} attrName - The name of the attribute.
 * @param {~value: string=?} - Optional value to set.
 * @return {(selection, option<string>)} - The selection and the attribute value (if getting).
 */
let attr: (selection, string, ~value: string=?) => (selection, option<string>)

/**
 * Checks, sets, or removes the existence of an attribute on the selected element(s).
 * @param {selection} selection - The current selection.
 * @param {string} attrName - The name of the attribute.
 * @param {~exists: bool=?} - Optional boolean to set or remove the attribute.
 * @return {(selection, option<bool>)} - The selection and the attribute existence (if checking).
 */
let attributed: (selection, string, ~exists: bool=?) => (selection, option<bool>)

/**
 * Invokes the specified function exactly once, passing in this selection.
 * Returns the original selection. This facilitates method chaining.
 * @param {selection} selection - The current selection.
 * @param {selection => selection} func - The function to call.
 * @return {selection} - The original selection.
 */
let call: (selection, selection => selection) => selection

/**
 * Adds, removes, or checks for a class on the selected element(s).
 * @param {selection} selection - The current selection.
 * @param {string} className - The name of the class.
 * @param {~exists: bool=?} - Optional boolean to add or remove the class.
 * @return {(selection, option<bool>)} - The selection and the class existence (if checking).
 */
let classed: (selection, string, ~exists: bool=?) => (selection, option<bool>)

/**
 * Creates a new DOM element or elements from a tag or HTML template.
 * @param {elementCreator} creator - The tag name or HTML template to create element(s) from.
 * @return {option<Dom.element>} - A new element(s) created.
 */
let create: elementCreator => option<Dom.element>

/**
 * Invokes the specified function for each element in the selection.
 * @param {selection} selection - The current selection.
 * @param {(Dom.element, int) => unit} func - The function to call for each element.
 * @return {selection} - The original selection.
 */
let each: (selection, (Dom.element, int) => unit) => selection

/**
 * Gets or sets the HTML content of the selected element(s).
 * @param {selection} selection - The current selection.
 * @param {~content: string=?} - Optional HTML content to set.
 * @return {(selection, option<string>)} - The selection and the HTML content (if getting).
 */
let html: (selection, ~content: string=?) => (selection, option<string>)

/**
 * Removes event listeners of a specific type from the selected element(s).
 * @param {selection} selection - The current selection.
 * @param {string} eventType - The type of event to remove listeners for.
 * @return {selection} - The updated selection.
 */
let off: (selection, string) => selection

/**
 * Adds an event listener to the selected element(s).
 * @param {selection} selection - The current selection.
 * @param {string} eventType - The type of event to listen for.
 * @param {Dom.event => unit} callback - The callback function to execute when the event occurs.
 * @return {selection} - The updated selection.
 */
let on: (selection, string, Dom.event => unit) => selection

/**
 * Adds an asynchronous event listener to the selected element(s).
 * @param {selection} selection - The current selection.
 * @param {string} eventType - The type of event to listen for.
 * @param {Dom.event => promise<unit>} callback - The asynchronous callback function to execute when the event occurs.
 * @return {selection} - The updated selection.
 */
let onAsync: (selection, string, Dom.event => promise<unit>) => selection

/**
 * Adds an event listener that triggers only after the event has occurred a specified number of times.
 * @param {selection} selection - The current selection.
 * @param {string} eventType - The type of event to listen for.
 * @param {Dom.event => unit} callback - The callback function to execute when the event occurs.
 * @param {~times: int=} - Optional number of times the event must occur before the callback is executed.
 * @return {selection} - The updated selection.
 */
let onNthTimes: (selection, string, Dom.event => unit, ~times: int=?) => selection

/**
 * Adds an asynchronous event listener that triggers only after the event has occurred a specified number of times.
 * @param {selection} selection - The current selection.
 * @param {string} eventType - The type of event to listen for.
 * @param {Dom.event => promise<unit>} callback - The asynchronous callback function to execute when the event occurs.
 * @param {~times: int=} - Optional number of times the event must occur before the callback is executed.
 * @return {selection} - The updated selection.
 */
let onAsyncNthTimes: (selection, string, Dom.event => promise<unit>, ~times: int=?) => selection

/**
 * Gets or sets a property of the selected element(s).
 * @param {selection} selection - The current selection.
 * @param {string} propName - The name of the property.
 * @param {~value: propertyValue=?} - Optional value to set.
 * @return {(selection, option<propertyValue>)} - The selection and the property value (if getting).
 */
let property: (selection, string, ~value: propertyValue=?) => (selection, option<propertyValue>)

/**
 * Removes the selected element(s) from the DOM and cleans up all associated event listeners.
 * @param {selection} selection - The selection to remove.
 */
let remove: selection => unit

/**
 * Replaces a class with another on the selected element(s).
 * @param {selection} selection - The current selection.
 * @param {string} oldClass - The class to be replaced.
 * @param {string} newClass - The new class to add.
 * @return {selection} - The updated selection.
 */
let replaceClass: (selection, string, string) => selection

/**
 * Selects a single element based on the given selector at document level.
 * @param {selector} selector - The selector to use.
 * @return {selection} - The selected element.
 */
let select: selector => selection

/**
 * Selects multiple elements based on the given selector at document level.
 * @param {selectors} selectors - The selector to use.
 * @return {selection} - The selected elements.
 */
let selectAll: selectors => selection

/**
 * Selects a child element from the current selection.
 * @param {selection} selection - The current selection.
 * @param {string} selector - The selector for the child element.
 * @return {selection} - The selected child element.
 */
let selectChild: (selection, string) => selection

/**
 * Selects multiple child elements from the current selection.
 * @param {selection} selection - The current selection.
 * @param {string} selector - The selector for the child elements.
 * @return {selection} - The selected child elements.
 */
let selectChildren: (selection, string) => selection

/**
 * Gets or sets a style property of the selected element(s).
 * @param {selection} selection - The current selection.
 * @param {string} styleName - The name of the style property.
 * @param {~value: string=?} - Optional value to set.
 * @return {(selection, option<string>)} - The selection and the style value (if getting).
 */
let style: (selection, string, ~value: string=?) => (selection, option<string>)

/**
 * Checks, sets, or removes the existence of a style property on the selected element(s).
 * @param {selection} selection - The current selection.
 * @param {string} styleName - The name of the style property.
 * @param {~exists: bool=?} - Optional boolean to set or remove the style.
 * @return {(selection, option<bool>)} - The selection and the style existence (if checking).
 */
let styled: (selection, string, ~exists: bool=?) => (selection, option<bool>)

/**
 * Gets or sets the text content of the selected element(s).
 * @param {selection} selection - The current selection.
 * @param {~content: string=?} - Optional text content to set.
 * @return {(selection, option<string>)} - The selection and the text content (if getting).
 */
let text: (selection, ~content: string=?) => (selection, option<string>)