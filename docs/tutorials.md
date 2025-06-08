## Tutorial: Todo Application

This example demonstrates how to build a simple todo application with ResForge.

### HTML Structure

Creata a HTML file with the next following structure in the body:

```html
<!DOCTYPE html>
<html lang="en">
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
</html>
```

### ReScript Implementation

1. Set up DOM references

First, select the key elements we'll be interacting with:

```reason
// Required external bindings
@get external getInputTarget: Dom.event => Dom.event_like<Dom.htmlInputElement> = "target"
@get external getInputValue: Dom.event_like<Dom.htmlInputElement> => string = "value"
@get external getTextAreaTarget: Dom.event => Dom.eventTarget_like<Dom.htmlTextAreaElement> = "target"
@set external setDisabled: (Dom.eventTarget_like<Dom.htmlTextAreaElement>, bool) => unit = "disabled"

// Select DOM elements
let formTodoInput = ResForge.select(Selector("#todo__form-input"))
let formButtonAddTodo = ResForge.select(Selector("#todo__form-add-task-button"))
let todoList = ResForge.select(Selector("#todo__list"))
```

2. Create Task Helper Function

This function creates a new task element with edit and delete functionality:

```reason
let createTask: string => option<Dom.element> = content => {
  // Create task element from HTML template
  let node = ResForge.create(
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
      ResForge.select(Dom(n))
      ->ResForge.selectChild(".todo__list-task-button-edit")
      ->ResForge.on("click", _ => {
        ResForge.select(Dom(n))
        ->ResForge.selectChild(".todo__list-task-description")
        ->ResForge.attributed("disabled", ~exists=false)
        ->ignore
      })
      ->ignore

      // Disable editing on blur
      ResForge.select(Dom(n))
      ->ResForge.selectChild(".todo__list-task-description")
      ->ResForge.on("blur", (evt: Dom.event) => evt->getTextAreaTarget->setDisabled(true))
      ->ignore

      // Delete button functionality
      ResForge.select(Dom(n))
      ->ResForge.selectChild(".todo__list-task-button-delete")
      ->ResForge.on("click", _ => {
        ResForge.select(Dom(n))->ResForge.remove
      })
      ->ignore
    }
  }
  node
}
```

3. Add Input Validation Logic

Enable the **Add** button only when input has enough characters:

```reason
formTodoInput
->ResForge.on("input", (evt: Dom.event) => {
  let inputValue = evt->getInputTarget->getInputValue

  // Enable/disable button based on input length
  if inputValue->String.length > 3 {
    formButtonAddTodo->ResForge.attributed("disabled", ~exists=false)->ignore
  } else {
    formButtonAddTodo->ResForge.attributed("disabled", ~exists=true)->ignore
  }
})
->ignore
```

4. Add Task Creation Logic

Handle the **Add** button click to create new tasks:

```reason
formButtonAddTodo
->ResForge.on("click", _ => {
  // Get input value
  switch formTodoInput->ResForge.property("value") {
  | (_, Some(String(txt))) => {
      // Create and append new task
      let task = createTask(txt)
      switch task {
      | Some(el) => todoList->ResForge.append(Dom(el))->ignore
      | None => ()
      }
    }
  | _ => Console.error("Error on the input, it is invalid")
  }
})
->ignore
```

5. It's time to compile the ReScript files

ReScript needs to be compiled to JavaScript in order to see the application in the browser and create the bundled js file (See the section of [Compile and Run](/compile-run)).
