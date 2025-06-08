@get external getInputTarget: Dom.event => Dom.event_like<Dom.htmlInputElement> = "target"
@get external getInputValue: Dom.event_like<Dom.htmlInputElement> => string = "value"

@get
external getTextAreaTarget: Dom.event => Dom.eventTarget_like<Dom.htmlTextAreaElement> = "target"
@set
external setDisabled: (Dom.eventTarget_like<Dom.htmlTextAreaElement>, bool) => unit = "disabled"

let createTask: string => option<Dom.element> = content => {
  let node = ResForge.create(
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
      ResForge.select(Dom(n))
      ->ResForge.selectChild(".todo__list-task-button-edit")
      ->ResForge.on("click", _ => {
        ResForge.select(Dom(n))
        ->ResForge.selectChild(".todo__list-task-description")
        ->ResForge.attributed("disabled", ~exists=false)
        ->ignore
      })
      ->ignore

      ResForge.select(Dom(n))
      ->ResForge.selectChild(".todo__list-task-description")
      ->ResForge.on("blur", (evt: Dom.event) => evt->getTextAreaTarget->setDisabled(true))
      ->ignore

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

let formTodoInput = ResForge.select(Selector("#todo__form-input"))
let formButtonAddTodo = ResForge.select(Selector("#todo__form-add-task-button"))
let todoList = ResForge.select(Selector("#todo__list"))

formTodoInput
->ResForge.on("input", (evt: Dom.event) => {
  if evt->getInputTarget->getInputValue->String.length > 3 {
    formButtonAddTodo->ResForge.attributed("disabled", ~exists=false)->ignore
  } else {
    formButtonAddTodo->ResForge.attributed("disabled", ~exists=true)->ignore
  }
})
->ignore

formButtonAddTodo
->ResForge.on("click", _ => {
  switch formTodoInput->ResForge.property("value") {
  | (_, Some(String(txt))) => {
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
