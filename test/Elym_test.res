open Test
open Assertions

// DOM bindings
@val external document: Dom.document = "document"
@send external createElement: (Dom.document, string) => Dom.element = "createElement"
@send external appendChild: (Dom.element, Dom.element) => unit = "appendChild"
@send external querySelector: (Dom.document, string) => Nullable.t<Dom.element> = "querySelector"
@send external remove: Dom.element => unit = "remove"
@get external body: Dom.document => Dom.element = "body"
@get external textContent: Dom.element => string = "textContent"
@set external setTextContent: (Dom.element, string) => unit = "textContent"
@set external setId: (Dom.element, string) => unit = "id"
@get external getId: Dom.element => string = "id"

// Test utilities
let setup: unit => Dom.element = () => {
  let element = document->createElement("div")
  element->setId("100")
  element->setTextContent("Hello Rescript test")

  document->body->appendChild(element)
  element
}

let teardown: Dom.element => unit = element => element->remove

test("DOM element exists and has correct content", () => {
  let container = setup()

  let selection = Elym.select("div")
  switch selection {
  | Single(Some(_)) => isTruthy(true, ~message="The container element exists in the DOM")
  | Single(None) => isTruthy(false, ~message="The container element does not exist in the DOM")
  | Multiple(_) =>
    isTruthy(false, ~message="Elym select method is not capable of selecting multiple elements")
  }

  let id = selection->Elym.getAttr("id")
  switch id {
  | Some(id) =>
    id
    ->Belt.Int.fromString
    ->Belt.Option.getExn
    ->isIntegerEqual(100, ~message="The id of the container is equal to 100")
  | None => isTruthy(false, ~message="The container does not have the id of 100")
  }

  container->teardown
})
