import van from "vanjs-core";

const { li, div, textarea, button } = van.tags;

const createTask = (description: string): (() => HTMLElement | null) => {
  const isEditing = van.state(false),
    willBeDeleted = van.state(false);

  return () =>
    willBeDeleted.val
      ? null // VanJS removes the element when it returns null
      : li(
          { class: "todo__list-task" },
          div(
            { class: "todo__list-task-content" },
            textarea({
              value: description,
              class: "todo__list-task-description",
              disabled: () => !isEditing.val,
              onblur: () => (isEditing.val = false),
            }),
            button(
              {
                class: "todo__list-task-button-edit",
                onclick: () => (isEditing.val = !isEditing.val),
              },
              "✏"
            ),
            button(
              {
                class: "todo__list-task-button-delete",
                onclick: () => (willBeDeleted.val = true), // Mark for deletion
              },
              "🗑"
            )
          )
        );
};

const todoFormInput = document.getElementById(
  "todo__form-input"
) as HTMLInputElement;
const todoFormAddButon = document.getElementById(
  "todo__form-add-task-button"
) as HTMLButtonElement;
const todoList = document.getElementById("todo__list") as HTMLUListElement;
if (!(todoFormInput && todoFormAddButon && todoList))
  throw new Error("Could not find form elements");

const taskState = van.state(todoFormInput.value);

todoFormInput.addEventListener("input", ({ target }: Event) => {
  taskState.val = (target as HTMLInputElement).value;
});

van.derive(() => (todoFormAddButon.disabled = taskState.val.length <= 3));

todoFormAddButon.addEventListener("click", () => {
  if (!taskState.val.trim().length) return;
  van.add(todoList, createTask(taskState.val));
  taskState.val = "";
  todoFormInput.value = taskState.val;
});
