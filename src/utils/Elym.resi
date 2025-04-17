type selection =
  | Single(option<Dom.element>)
  | Multiple(array<Dom.element>)

let select: string => selection
let selectAll: string => selection
// let createFromTemplate: string => selection
// let appendChild: (selection, Dom.element) => selection
let selectChild: (selection, string) => selection
let selectChildren: (selection, string) => selection
let remove: selection => unit
let replaceClass: (selection, string, string) => selection
// let getCssProperty: (selection, string) => option<string>
// let getValue: selection => option<string>
// let setValue: (selection, string) => selection
let on: (selection, string, Dom.event => unit) => selection
let off: (selection, string) => selection

let text: (selection, ~content: string=?) => (selection, option<string>)
let value: (selection, ~newValue: string=?) => (selection, option<string>)
let attr: (selection, string, ~value: string=?) => (selection, option<string>)
let classed: (selection, string, ~exists: bool=?) => (selection, option<bool>)
let attributed: (selection, string, ~exists: bool=?) => (selection, option<bool>)