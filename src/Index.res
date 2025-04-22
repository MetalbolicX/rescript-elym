@get external getInputTarget: Dom.event => Dom.event_like<Dom.htmlInputElement> = "target"
@get external getInputValue: Dom.event_like<Dom.htmlInputElement> => string = "value"

@get
external getTextAreaTarget: Dom.event => Dom.eventTarget_like<Dom.htmlTextAreaElement> = "target"
@set
external setDisabled: (Dom.eventTarget_like<Dom.htmlTextAreaElement>, bool) => unit = "disabled"

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
        Elym.select(Dom(n))
        ->Elym.selectChild(".todo__list-task-button-edit")
        ->Elym.off("click")
        ->ignore
        Elym.select(Dom(n))
        ->Elym.selectChild(".todo__list-task-description")
        ->Elym.off("blur")
        ->ignore
        Elym.select(Dom(n))
        ->Elym.selectChild(".todo__list-task-button-delete")
        ->Elym.off("click")
        ->ignore
        Elym.select(Dom(n))->Elym.remove
      })
      ->ignore
    }
  }
  node
}

let formTodoInput = Elym.select(Selector("#todo__form-input"))
let formButtonAddTodo = Elym.select(Selector("#todo__form-add-task-button"))
let todoList = Elym.select(Selector("#todo__list"))

formTodoInput
->Elym.on("input", evt => {
  if evt->getInputTarget->getInputValue->String.length > 3 {
    formButtonAddTodo->Elym.attributed("disabled", ~exists=false)->ignore
  } else {
    formButtonAddTodo->Elym.attributed("disabled", ~exists=true)->ignore
  }
})
->ignore

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
