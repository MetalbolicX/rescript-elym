type selection =
  | Single(option<Dom.element>)
  | Multiple(array<Dom.element>)

let select: string => selection
let selectAll: string => selection
// let createFromTemplate: string => selection
let setAttr: (selection, string, string) => selection
let getAttr: (selection, string) => option<string>
let removeAttr: (selection, string) => selection
// let appendChild: (selection, Dom.element) => selection
let setText: (selection, string) => selection
let getText: selection => option<string>
let selectChild: (selection, string) => selection
let selectChildren: (selection, string) => selection
let remove: selection => unit
let addClass: (selection, array<string>) => selection
let removeClass: (selection, array<string>) => selection
let isClassed: (selection, string) => option<bool>
let toggleClass: (selection, string, ~isForced: bool=?) => selection
let replaceClass: (selection, string, string) => selection
let getCssProperty: (selection, string) => option<string>
let hasAttr: (selection, string) => option<bool>
let toggleAttr: (selection, string) => selection
let getValue: selection => option<string>
let setValue: (selection, string) => selection
let on: (selection, string, Dom.event => unit) => selection
let off: (selection, string) => selection