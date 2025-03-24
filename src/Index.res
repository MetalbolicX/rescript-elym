let createTask: string => Elym.selection = content => {
  let task = Elym.createFromTemplate(`
    <li class="todo__list-task">
        <div class="todo__list-task-content">
            <textarea class="todo__list-task-description" placeholder="Enter your task here" disabled>${content}</textarea>
            <button class="todo__list-task-button-edit">✏</button>
            <button class="todo__list-task-button-delete">🗑</button>
        </div>
    </li>`)
  task->Elym.selectChild(".todo__list-task-button-edit")
  ->Elym.on("click", _ => {
    let taskDescription = task->Elym.selectChild(".todo__list-task-description")
    switch taskDescription->Elym.getAttr("disabled") {
    | Some(_) => taskDescription->Elym.rmAttr("disabled")->ignore
    | None => taskDescription->Elym.setAttr("disabled", "")->ignore
    }
  })->ignore
  task->Elym.selectChild(".todo__list-task-description")
  ->Elym.on("blur", _ => {
    let taskDescription = task->Elym.selectChild(".todo__list-task-description")
    taskDescription->Elym.setAttr("disabled", "")->ignore
  })->ignore
  task->Elym.selectChild(".todo__list-task-button-delete")
  ->Elym.on("click", _ => {
    // TODO: Implement task deletion and remove the function of the event listener first.
    task->Elym.remove
  })->ignore
  task
}

let formTodoInput = Elym.select("#todo__form-input")
let formButtonAddTodo = Elym.select("#todo__form-add-task-button")
let todoList = Elym.select("#todo__list")

formTodoInput
->Elym.on("input", _ => {
  switch formTodoInput->Elym.getValue {
  | Some(text) =>
    if String.length(text) > 3 {
      formButtonAddTodo->Elym.rmAttr("disabled")->ignore
    } else {
      formButtonAddTodo->Elym.setAttr("disabled", "")->ignore
    }
  | None => ()
  }
})
->ignore

formButtonAddTodo
->Elym.on("click", _ => {
  switch formTodoInput->Elym.getValue {
  | Some(text) =>
    let newTask = createTask(text)
    switch newTask {
    | Single(Some(task)) => todoList->Elym.appendChild(task)->ignore
    | Single(None) => Console.error("Task creation failed")
    | Multiple(_) => Console.error("Multiple tasks cannot be created at once")
    }
  | None => Console.error("Input value is None")
  }
})
->ignore
