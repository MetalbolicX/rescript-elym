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

  let textArea = document->createElement("textarea")
  element->appendChild(textArea)

  document->body->appendChild(element)
  element
}

let teardown: Dom.element => unit = element => element->remove

test("DOM element exists and check the id, textContent and data-id", () => {
  let container = setup()

  let selection = Elym.select("div")
  switch selection {
  | Single(Some(_)) => isTruthy(true, ~message="The container element exists in the DOM.")
  | Single(None) => isTruthy(false, ~message="The container element does not exist in the DOM.")
  | Multiple(_) =>
    isTruthy(false, ~message="Elym select method is not capable of selecting multiple elements.")
  }

  let id = selection->Elym.getAttr("id")
  switch id {
  | Some(id) =>
    id
    ->Belt.Int.fromString
    ->Belt.Option.getExn
    ->isIntEqualTo(100, ~message="The id of the container is equal to 100.")
  | None => isTruthy(false, ~message="The container does not have the id of 100.")
  }

  let hello = selection->Elym.getText
  switch hello {
  | Some(txt) =>
    txt->isTextEqualTo(
      "Hello Rescript test",
      ~message="The container text content is: Hello Rescript test.",
    )
  | None =>
    isTruthy(
      false,
      ~message="The container text content does not have the phrase 'Hello Rescript test'.",
    )
  }

  selection->Elym.setAttr("data-id", "abc")->ignore
  let dataId = selection->Elym.getAttr("data-id")
  switch dataId {
  | Some(id) =>
    id->isTextEqualTo(
      "abc",
      ~message="The container data-id is 'abc'. It was correctly set using Elym.",
    )
  | None =>
    isTruthy(
      false,
      ~message="The container data-id is not 'abc', it was not able to be set using Elym.",
    )
  }

  selection->Elym.removeAttr("data-id")->ignore
  switch selection->Elym.hasAttr("data-id") {
  | Some(t) =>
    isTruthy(!t, ~message="The container data-id was successfully removed. Using Elym removeAttr.")
  | None => isTruthy(false, ~message="The container data-id is not None.")
  }

  container->teardown
})

test("Check the class attribute API that add, removes, toggles, etc.", () => {
  let container = setup()

  let selection = Elym.select("div")

  let hasClassHello = selection->Elym.isClassed("hello")
  switch hasClassHello {
  | Some(t) => {
      isTruthy(!t, ~message="The container does not have the class 'hello'.")
      selection->Elym.addClass(["hello"])->ignore
    }
  | None =>
    isTruthy(
      false,
      ~message="The container does not have the class 'hello' and the result is None.",
    )
  }

  let wasHelloClassAdded = selection->Elym.isClassed("hello")
  switch wasHelloClassAdded {
  | Some(t) =>
    isTruthy(
      t,
      ~message="The container has the class 'hello' and it was correctly added using Elym addClass.",
    )
  | None =>
    isTruthy(false, ~message="The container was not able to be added using Elym addClass function.")
  }

  selection->Elym.toggleClass("visible")->ignore
  let isVisible = selection->Elym.isClassed("visible")
  switch isVisible {
  | Some(t) =>
    isTruthy(
      t,
      ~message="The container has the visible class, it was added using the Elym toogleClass function",
    )
  | None =>
    isTruthy(
      false,
      ~message="The container, visible class was not added using the Elym toogleClass function",
    )
  }

  selection->Elym.replaceClass("visible", "hidden")->ignore
  let wasReplaced = selection->Elym.isClassed("hidden")
  switch wasReplaced {
  | Some(t) =>
    isTruthy(t, ~message="The container 'visible' class was replaced for the class 'hidden'")
  | None =>
    isTruthy(
      false,
      ~message="The container 'visible' class was not replaced for the class 'hidden'",
    )
  }

  container->teardown
})

test("Check the properties of css and special ones of some Html tags", () => {
  let container = setup()

  let selection = Elym.select("div")

  let color = selection->Elym.getCssProperty("color")
  switch color {
  | Some(c) =>
    c->isTextEqualTo(
      "",
      ~message="The container does not have the property of 'color', it is an empty string",
    )
  | None => isTruthy(false, ~message="The container property of color is None")
  }

  let textArea = selection->Elym.selectChild("textarea")
  switch textArea {
  | Single(Some(_)) => isTruthy(true, ~message="The container has child of textarea.")
  | Single(None) => isTruthy(false, ~message="The container does not have the child textarea.")
  | Multiple(_) =>
    isTruthy(false, ~message="The Elym selectChild can only get one element at a time.")
  }

  let text = textArea->Elym.getValue
  switch text {
    | Some(txt) => txt->isTextEqualTo("", ~message="The textarea input value is an empty string.")
    | None => isTruthy(false, ~message="The textarea input value is None")
  }

  textArea->Elym.setValue("Hello world!")->ignore
  let newText = textArea->Elym.getValue
  switch newText {
    | Some(txt) => txt->isTextEqualTo("Hello world!", ~message="The textarea input value is 'Hello world!'")
    | None => isTruthy(false, ~message="The textarea input value is None")
  }

  textArea->Elym.toggleAttr("readonly")->ignore
  switch textArea->Elym.hasAttr("readonly") {
    | Some(t) => isTruthy(t, ~message="The textares has the attribute readonly, added using Elym toggleAttr function.")
    | None => isTruthy(false, ~message="The textarea is None")
  }

  container->teardown
})
