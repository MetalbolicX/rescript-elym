open Test
open Assertions

// DOM bindings
@val external document: Dom.document = "document"
@send external createElement: (Dom.document, string) => Dom.element = "createElement"
@send external appendChild: (Dom.element, Dom.element) => unit = "appendChild"
@send @return(nullable)
external querySelector: (Dom.element, string) => option<Dom.element> = "querySelector"
// @val
// external query: (
//   @unwrap [#Doc(Dom.document) | #Element(Dom.element)],
//   string,
// ) => Nullable.t<Dom.element> = "querySelector"
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

  let selection = Elym.select(Selector("div"))
  switch selection {
  | Single(Some(_)) => passWith("The container elemment exists in the DOM") //isTruthy(true, ~message="The container element exists in the DOM.")
  | Single(None) => failWith("The container element does not exist in the DOM.")
  | Multiple(_) => failWith("Elym select method is not capable of selecting multiple elements.")
  }

  let (_, id) = selection->Elym.attr("id")
  switch id {
  | Some(id) =>
    id
    ->Belt.Int.fromString
    ->Belt.Option.getExn
    ->isIntEqualTo(100, ~message="The id of the container is equal to 100.")
  | None => isTruthy(false, ~message="The container does not have the id of 100.")
  }

  let (_, hello) = selection->Elym.text
  switch hello {
  | Some(txt) =>
    txt->isTextEqualTo(
      "Hello Rescript test",
      ~message="The container text content is: Hello Rescript test.",
    )
  | None => failWith("The container text content does not have the phrase 'Hello Rescript test'.")
  }

  let (withDataId, _) = selection->Elym.attr("data-id", ~value="abc")
  switch withDataId->Elym.attr("data-id") {
  | (_, Some(id)) =>
    id->isTextEqualTo(
      "abc",
      ~message="The container data-id is 'abc'. It was correctly set using Elym.",
    )
  | (_, None) =>
    failWith("The container data-id is not 'abc', it was not able to be set using Elym.")
  }

  let (withoutDataId, _) = withDataId->Elym.attributed("data-id", ~exists=false)
  switch withoutDataId->Elym.attributed("data-id") {
  | (_, Some(true)) =>
    failWith("The data-id is still in the container and it was removed correctly.")
  | (_, Some(false)) => passWith("The data-id was correctly removed.")
  | _ => failWith("The was a problem to test the Elym attributed function.")
  }

  container->teardown
})

test("selectAll and selectChildren correctly select elements", () => {
  let container = setup()

  let selection = Elym.selectAll("div")
  switch selection {
  | Multiple(elements) =>
    isIntEqualTo(elements->Array.length, 1, ~message="selectAll correctly selects one div element.")
  | _ => failWith("selectAll did not return the expected Multiple selection.")
  }

  let childSelection = Elym.select(Selector("div"))->Elym.selectChildren("textarea")
  switch childSelection {
  | Multiple(elements) =>
    isIntEqualTo(
      elements->Array.length,
      1,
      ~message="selectChildren correctly selects one textarea element.",
    )
  | _ => failWith("selectChildren did not return the expected Multiple selection.")
  }

  container->teardown
})

test("append correctly appends new elements", () => {
  let container = setup()

  let selection = Elym.select(Selector("div"))
  let updatedSelection = selection->Elym.append(Tag("span"))

  switch updatedSelection {
  | Single(Some(el)) =>
    isTextEqualTo(el->textContent, "", ~message="append correctly appends a new span element.")
  | _ => failWith("append did not return the expected updated selection.")
  }

  container->teardown
})

test("attr, classed, and style correctly manipulate attributes, classes, and styles", () => {
  let container = setup()

  let selection = Elym.select(Selector("div"))

  // Test attr
  selection->Elym.attr("data-test", ~value="test-value")->ignore
  let (_, attrValue) = selection->Elym.attr("data-test")
  switch attrValue {
  | Some(value) =>
    value->isTextEqualTo("test-value", ~message="attr correctly set the data-test attribute.")
  | None => failWith("attr did not set the data-test attribute.")
  }

  // Test classed
  selection->Elym.classed("test-class", ~exists=true)->ignore
  let (_, hasClass) = selection->Elym.classed("test-class")
  switch hasClass {
  | Some(true) => passWith("classed correctly added the test-class class.")
  | _ => failWith("classed did not add the test-class class.")
  }

  // Test style
  selection->Elym.style("color", ~value="red")->ignore
  let (_, styleValue) = selection->Elym.style("color")
  switch styleValue {
  | Some(value) =>
    value->isTextEqualTo("rgb(255, 0, 0)", ~message="style correctly set the color style.")
  | None => failWith("style did not set the color style.")
  }

  container->teardown
})

test("remove correctly removes elements from the DOM", () => {
  setup()->ignore

  let selection = Elym.select(Selector("div"))
  selection->Elym.remove->ignore

  let removedElement = Elym.select(Selector("div"))
  switch removedElement {
  | Single(None) => passWith("remove correctly removed the element from the DOM.")
  | _ => failWith("remove did not remove the element from the DOM.")
  }
})

test("call and each correctly invoke functions on the selection", () => {
  let container = setup()

  let selection = Elym.select(Selector("div"))

  // Test call
  selection
  ->Elym.call(sel => {
    sel->Elym.attr("data-test", ~value="called")->ignore
    sel
  })
  ->ignore

  let (_, attrValue) = selection->Elym.attr("data-test")
  switch attrValue {
  | Some(value) =>
    value->isTextEqualTo("called", ~message="call correctly invoked the function on the selection.")
  | None => failWith("call did not invoke the function on the selection.")
  }

  // Test each
  let count = ref(0)
  selection
  ->Elym.each((_, _) => {
    count := count.contents + 1
  })
  ->ignore
  count.contents->isIntEqualTo(1, ~message="each correctly invoked the function for each element.")

  container->teardown
})
