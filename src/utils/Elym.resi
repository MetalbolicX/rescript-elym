type selection =
    | Single(option<Dom.element>)
    | Multiple(array<Dom.element>)

let select: string => selection
let selectAll: string => selection
let createFromTemplate: string => selection
let setAttr: (selection, string, string) => selection
let getAttr: (selection, string) => option<string>
let rmAttr: (selection, string) => selection
let setText: (selection, string) => selection
let on: (selection, string, unit => unit) => selection
let appendChild: (selection, Dom.element) => selection
let setText: (selection, string) => selection
let getText: selection => option<string>
let getValue: selection => option<string>
let setValue: (selection, string) => selection
let selectChild: (selection, string) => selection
let selectChildren: (selection, string) => selection
let remove: selection => unit