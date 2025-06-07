# ResForge

> ResForge is a ReScript library that provides a fluent, type-safe API for DOM manipulation, inspired by [d3.js selection module](https://github.com/d3/d3-selection).

**Supported Versions:**

![ReScript](https://img.shields.io/badge/ReScript->=11.0.0-blue)

## What problem ResForge solves?

Many developers are eager to try ReScript, but often find themselves spending more time writing external bindings for JavaScript than building their actual applications. Elym solves this problem for front-end web development by providing a fluent, type-safe API for selecting, manipulating, and managing DOM elements—so you can focus on building great apps, no more manual boring typing code.

## Why ResForge?

* **Fluent API**: Chain methods for concise, readable code.
* **Type Safety**: Leverage ReScript's type system to catch errors at compile time.
* **Event Management**: Automatic cleanup of event listeners when elements are removed.
* **Familiar Pattern**: If you're familiar with d3.js selections, you'll feel right at home.

## Quick Installation

### 1. Create a ReScript Application

First, create a new ReScript application using one of the following commands:

```sh
npm create rescript-app@latest
```

> [!NOTE]
> For more information on setting up a ReScript project, refer to the [official ReScript documentation](https://rescript-lang.org/docs/manual/latest/installation).

### 2. Install the ResForge Package

Add the required dependencies to your project.

```sh
npm i resforge
```

### 3. Update Configuration

In your `rescript.json` file, add the following dependency:

```json
{
  "bs-dependencies": ["resforge"]
}
```

## Core concepts

Elym is built around a few key concepts:

### Selections

A selection represents a group of DOM elements that you can manipulate. There are two types:

* **Single**: Represents one element or no element.
* **Multiple**: Represents multiple elements.

```res
// Select a single element
let header = Elym.select(Selector("#header"))

// Select multiple elements
let paragraphs = Elym.selectAll("p")
```

### Method Chaining

Most Elym methods return the selection they operate on, allowing you to chain operations:

```res
Elym.select(Selector("#app"))
->Elym.append(Tag("h1"))
->Elym.text(~content="Hello Elym")
->Elym.style("color", ~value="blue")
->ignore
```

### Event Handling

Elym manages event listeners and automatically removes them when elements are removed:

```res
Elym.select(Selector("#button"))
->Elym.on("click", _ => Console.log("Button clicked!"))
->ignore
```

## API Reference

### Selection Methods

| Method           | Description              | Example                                 |
| ---------------- | ------------------------ | --------------------------------------- |
| `select`         | Select a single element  | `Elym.select(Selector("#app"))`         |
| `selectAll`      | Select multiple elements | `Elym.selectAll("li")`                  |
| `selectChild`    | Select a child element   | `selection->Elym.selectChild(".child")` |
| `selectChildren` | Select child elements    | `selection->Elym.selectChildren("div")` |

### DOM Manipulation

|Method|Description|Example|
|---|---|---|
|`append`|Append an element|`selection->Elym.append(Tag("div"))`|
|`text`|Get or set text content|`selection->Elym.text(~content="Hello")`|
|`html`|Get or set HTML content|`selection->Elym.html(~content="<span>Hello</span>")`|
|`attr`|Get or set an attribute|`selection->Elym.attr("id", ~value="main")`|
|`classed`|Add or remove a class|`selection->Elym.classed("active", ~exists=true)`|
|`style`|Get or set a style property|`selection->Elym.style("color", ~value="red")`|

### Event Handling

|Method|Description|Example|
|---|---|---|
|`on`|Add an event listener|`selection->Elym.on("click", handleClick)`|
|`off`|Remove event listeners|`selection->Elym.off("click")`|

### Element Creation

|Method|Description|Example|
|---|---|---|
|`create`|Create a new element|`Elym.create(Tag("div"))`|
|`create`|Create from HTML template|`Elym.create(Template("<div>Hello</div>"))`|

### Utility Methods

| Method   | Description                    | Example                                  |
| -------- | ------------------------------ | ---------------------------------------- |
| `call`   | Run a function on a selection  | `selection->Elym.call(customFn)`         |
| `each`   | Run a function on each element | `selection->Elym.each((el, i) => {...})` |
| `remove` | Remove elements from DOM       | `selection->Elym.remove`                 |

## Usage Example: Todo Application

This example demonstrates how to build a simple todo application with Elym.

### HTML Structure

Creata a HTML file with the next following structure in the body:

```html
<body>
  <main>
    <header>
      <h1>Todos app</h1>
    </header>
    <form id="todo__form">
      <label for="todo__form-input">New task</label>
      <input
        type="text"
        name="task"
        id="todo__form-input"
        placeholder="Write a task..."
        minlength="3"
      />
      <button type="button" id="todo__form-add-task-button" disabled>
        Add
      </button>
    </form>
    <ul id="todo__list"></ul>
  </main>
  <script
    src="./dist/Index.res.js"
    type="module"
    language="javascript"
  ></script>
</body>
```

### ReScript Implementation

1. Set up DOM references

First, select the key elements we'll be interacting with:

```res
// Required external bindings
@get external getInputTarget: Dom.event => Dom.event_like<Dom.htmlInputElement> = "target"
@get external getInputValue: Dom.event_like<Dom.htmlInputElement> => string = "value"
@get external getTextAreaTarget: Dom.event => Dom.eventTarget_like<Dom.htmlTextAreaElement> = "target"
@set external setDisabled: (Dom.eventTarget_like<Dom.htmlTextAreaElement>, bool) => unit = "disabled"

// Select DOM elements
let formTodoInput = Elym.select(Selector("#todo__form-input"))
let formButtonAddTodo = Elym.select(Selector("#todo__form-add-task-button"))
let todoList = Elym.select(Selector("#todo__list"))
```

2. Create Task Helper Function

This function creates a new task element with edit and delete functionality:

```res
let createTask: string => option<Dom.element> = content => {
  // Create task element from HTML template
  let node = Elym.create(
    Template(
      `<li class="todo__list-task">
        <div class="todo__list-task-content">
          <textarea class="todo__list-task-description" placeholder="Enter your task here" disabled>${content}</textarea>
          <button class="todo__list-task-button-edit">✏</button>
          <button class="todo__list-task-button-delete">🗑</button>
        </div>
      </li>`,
    ),
  )

  // Add event handlers if node was successfully created
  switch node {
  | None => ()
  | Some(n) => {
      // Edit button functionality
      Elym.select(Dom(n))
      ->Elym.selectChild(".todo__list-task-button-edit")
      ->Elym.on("click", _ => {
        Elym.select(Dom(n))
        ->Elym.selectChild(".todo__list-task-description")
        ->Elym.attributed("disabled", ~exists=false)
        ->ignore
      })
      ->ignore

      // Disable editing on blur
      Elym.select(Dom(n))
      ->Elym.selectChild(".todo__list-task-description")
      ->Elym.on("blur", (evt: Dom.event) => evt->getTextAreaTarget->setDisabled(true))
      ->ignore

      // Delete button functionality
      Elym.select(Dom(n))
      ->Elym.selectChild(".todo__list-task-button-delete")
      ->Elym.on("click", _ => {
        Elym.select(Dom(n))->Elym.remove
      })
      ->ignore
    }
  }
  node
}
```
3. Add Input Validation Logic

Enable the "Add" button only when input has enough characters:

```res
formTodoInput
->Elym.on("input", (evt: Dom.event) => {
  let inputValue = evt->getInputTarget->getInputValue

  // Enable/disable button based on input length
  if inputValue->String.length > 3 {
    formButtonAddTodo->Elym.attributed("disabled", ~exists=false)->ignore
  } else {
    formButtonAddTodo->Elym.attributed("disabled", ~exists=true)->ignore
  }
})
->ignore
```
4. Add Task Creation Logic

Handle the "Add" button click to create new tasks:

```res
formButtonAddTodo
->Elym.on("click", _ => {
  // Get input value
  switch formTodoInput->Elym.property("value") {
  | (_, Some(String(txt))) => {
      // Create and append new task
      let task = createTask(txt)
      switch task {
      | Some(el) => todoList->Elym.append(Dom(el))->ignore
      | None => ()
      }
    }
  | _ => Console.error("Error on the input, it is invalid")
  }
})
->ignore
```

5. It's time to compile the ReScript files

ReScript needs to be compiled to JavaScript in order to see the application in the browser and create the bundled js file (See the section of **Build and Run**).

## Build and Run

To build and run your ReScript application, see the [Compile and Run](https://metalbolicx.github.io/resforge/#/compile-run) section.

## Documentation

<div align="center">

[![view - Documentation](https://img.shields.io/badge/view-Documentation-blue?style=for-the-badge)](https://metalbolicx.github.io/resforge/#/api-index)

</div>

## Do you want to learn more?

- Explore the [ReScript documentation](https://rescript-lang.org/docs/manual/v11.0.0/introduction) for more details on the language and its features.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Technologies used

* [ReScript](https://rescript-lang.org/), a strong typed functional programming language the compiles to JavaScript.

## License

Released under [MIT](/LICENSE) by [@MetalbolicX](https://github.com/MetalbolicX).