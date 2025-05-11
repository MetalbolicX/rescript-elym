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
  | Number(float)
  | Boolean(bool)

type elementCreator =
  | Tag(string)
  | Template(string)

let append: (selection, element) => selection
let appendChildren: (selection, array<Dom.element>) => selection
let attr: (selection, string, ~value: string=?) => (selection, option<string>)
let attributed: (selection, string, ~exists: bool=?) => (selection, option<bool>)
let call: (selection, selection => selection) => selection
let classed: (selection, string, ~exists: bool=?) => (selection, option<bool>)
let create: elementCreator => option<Dom.element>
let each: (selection, (Dom.element, int) => unit) => selection
let html: (selection, ~content: string=?) => (selection, option<string>)
let off: (selection, string) => selection
let on: (selection, string, Dom.event => unit) => selection
let onAsync: (selection, string, Dom.event => promise<unit>) => selection
let property: (selection, string, ~value: propertyValue=?) => (selection, option<propertyValue>)
let remove: selection => unit
let replaceClass: (selection, string, string) => selection
let select: selector => selection
let selectAll: string => selection
let selectChild: (selection, string) => selection
let selectChildren: (selection, string) => selection
let style: (selection, string, ~value: string=?) => (selection, option<string>)
let styled: (selection, string, ~exists: bool=?) => (selection, option<bool>)
let text: (selection, ~content: string=?) => (selection, option<string>)