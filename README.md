# rescript-elym

## Description

Elym, short for &quot;element manipulator,&quot; is a JavaScript external bindings library for the ReScript programming language. It&#39;s inspired by the syntax of [D3.js](https://d3js.org/) and its module [d3-selection](https://github.com/d3/d3-selection). Elym allows you to manipulate the DOM with ease and efficiency.

## Features

* Direct DOM selection
* Function chaining
* Automatic removal of all event listeners when an element is removed
* Manual removal of event listeners

## Installation

### 1. Create a ReScript Application

First, create a new ReScript application using one of the following commands:

```sh
npm create rescript-app@latest
```
```sh
pnpm create rescript-app
```
```sh
bun create rescript-app
```

For more information on setting up a ReScript project, refer to the official [ReScript documentation](https://rescript-lang.org/docs/manual/v11.0.0/installation).

### 2. Install Dependencies

Add the required dependencies to your project.

```sh
npm install rescript-elym
```
```sh
pnpm add rescript-elym
```
```sh
bun add rescript-elym
```

### 3. Update Configuration
In your `rescript.json` file, add the following dependency:

```sh
{
  "bs-dependencies": ["rescript-elym"]
}
```

## Usage

### Requirements

Let's create a simple "To-Do" application to demonstrate the usage of `rescript-elym`. Our application will have the following features:

1. An input field and a button to add new tasks.

2. The "Add" button is disabled unless the input has more than three characters.

3. Each task has "Edit" and "Delete" buttons.
4. Task editing is disabled when the focus moves away from the task.
5. Tasks can be deleted permanently.

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

### ReScript Code (Index.res)

Create a file named `Index.res` in your `src` directory and add the following code:

1. Select the DOM elements that will be interacting to create a new task (input, add button and the container of the tasks).
```res
let formTodoInput = Elym.select(Selector("#todo__form-input"))
let formButtonAddTodo = Elym.select(Selector("#todo__form-add-task-button"))
let todoList = Elym.select(Selector("#todo__list"))
```

2. The input textbox needs to remove the `disabled` attribute of the add button to append a new task when the task description has more than three characters long. To do that it's necessary to add an event listener and add some external bindings in order to get the `value` of the input and check it.

```res
// At the top of the .res file add the next external bindings
@get external getInputTarget: Dom.event => Dom.event_like<Dom.htmlInputElement> = "target"
@get external getInputValue: Dom.event_like<Dom.htmlInputElement> => string = "value"
```

```res
// Add the listener to the input element.
formTodoInput
->Elym.on("input", (evt: Dom.event) => {
  if evt->getInputTarget->getInputValue->String.length > 3 {
    formButtonAddTodo->Elym.attributed("disabled", ~exists=false)->ignore
  } else {
    formButtonAddTodo->Elym.attributed("disabled", ~exists=true)->ignore
  }
})
->ignore
```

3. Lets create a helper function that will be written below the extenal bindings. The function will create the a new task element with the buttons edit and delete and their event listeners.

```res
let createTask: string => option<Dom.element> = content => {
  let node = Elym.create(
    Template(
      `
    <li class="todo__list-task">
      <div class="todo__list-task-content">
        <textarea class="todo__list-task-description" placeholder="Enter your task here" disabled>${content}</textarea>
        <button class="todo__list-task-button-edit">✏</button>
        <button class="todo__list-task-button-delete">🗑</button>
      </div>
    </li>`,
    ),
  )
  switch node {
  | None => ()
  | Some(n) => {
      Elym.select(Dom(n))
      ->Elym.selectChild(".todo__list-task-button-edit")
      ->Elym.on("click", _ => {
        Elym.select(Dom(n))
        ->Elym.selectChild(".todo__list-task-description")
        ->Elym.attributed("disabled", ~exists=false)
        ->ignore
      })
      ->ignore

      Elym.select(Dom(n))
      ->Elym.selectChild(".todo__list-task-description")
      ->Elym.on("blur", (evt: Dom.event) => evt->getTextAreaTarget->setDisabled(true))
      ->ignore

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

4. Add the action to the add button when it is clicked. It's necessary to add some external bindings in order to able or disable the edition of the task description. This bindings will be below the external bindings of the second step. After adding the bindings add the event listener to the add button.

```res
@get external getTextAreaTarget: Dom.event => Dom.eventTarget_like<Dom.htmlTextAreaElement> = "target"
@set external setDisabled: (Dom.eventTarget_like<Dom.htmlTextAreaElement>, bool) => unit = "disabled"
```

```res
formButtonAddTodo
->Elym.on("click", _ => {
  switch formTodoInput->Elym.property("value") {
  | (_, Some(Str(txt))) => {
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

5. It's time to compile the ReScript files to JavaScript in to see the application in the browser and create the bundled js file (See the section of **Build and Run**).

## Build and Run

Follow these steps to build and run your rescript-elym application:

1. Start the ReScript development compile checker:
```sh
npm run res:dev
```
2. If there are no errors, build the JavaScript files:
```res
npm run res:build
```

3. Build the JavaScript bundle for browser use. For example, using [Bun](https://bun.sh/docs/bundler) (you can use any other JavaScript bundler):
```sh
bun build ./src/Index.res.mjs --outdir ./dist --format esm
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Technologies used

* [ReScript](https://rescript-lang.org/), a strong stat typed functional language the compiles to JavaScript.

## License

This project is licensed under the [MIT License](https://opensource.org/license/mit). See the LICENSE file for details.


