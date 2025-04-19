type selection =
  | Single(option<Dom.element>)
  | Multiple(array<Dom.element>)

type selector =
  | Selector(string)
  | Dom(Dom.element)

type element =
  | Dom(Dom.element)
  | Tag(string)

@unboxed
type propertyValue =
  | String(string)
  | Float(float)
  | Boolean(bool)

let select: selector => selection
let selectAll: string => selection
let selectChild: (selection, string) => selection
let selectChildren: (selection, string) => selection
let remove: selection => unit
let replaceClass: (selection, string, string) => selection
let on: (selection, string, Dom.event => unit) => selection
let off: (selection, string) => selection
let text: (selection, ~content: string=?) => (selection, option<string>)
let attr: (selection, string, ~value: string=?) => (selection, option<string>)
let classed: (selection, string, ~exists: bool=?) => (selection, option<bool>)
let attributed: (selection, string, ~exists: bool=?) => (selection, option<bool>)
let property: (selection, string, ~value: propertyValue=?) => (selection, option<propertyValue>)
let style: (selection, string, ~value: string=?) => (selection, option<string>)
let styled: (selection, string, ~exists: bool=?) => (selection, option<bool>)
let html: (selection, ~content: string=?) => (selection, option<string>)
let append: (selection, element) => selection
let call: (selection, selection => selection) => selection