# ResForge

> ResForge is a ReScript library that provides a fluent, type-safe API for DOM manipulation, inspired by [d3.js selection module](https://github.com/d3/d3-selection).

**Supported Versions:**

![ReScript](https://img.shields.io/badge/ReScript->=11.0.0-blue)

## Why ResForge?

Many developers are eager to try ReScript, but often find themselves spending more time writing external bindings for JavaScript than building their actual applications. Elym solves this problem for front-end web development by providing a fluent, type-safe API for selecting, manipulating, and managing DOM elements—so you can focus on building great apps, no more manual boring typing code.

## Features

* **Fluent API**: Chain methods for concise, readable code.
* **Type Safety**: Leverage ReScript's type system to catch errors at compile time.
* **Event Management**: Automatic cleanup of event listeners when elements are removed.
* **Familiar Pattern**: If you're familiar with d3.js selections, you'll feel right at home.

## 🚀 Quick Installation

### 1. Create a ReScript Application

First, create a new ReScript application using one of the following commands:

```sh
npm create rescript-app@latest
```

> 📝 **Note:** For more information on setting up a ReScript project, refer to the [official ReScript documentation](https://rescript-lang.org/docs/manual/latest/installation).

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

## 🙌 Hello World Example

To get started with ResForge, let's create a simple **Hello World** example.

```rescript
ResForge.select(Selector("body"))
  ->ResForge.append(Tag("h1"))
  ->ResForge.text(~content="Hello World!")
  ->ignore
```

This code selects the `body` element, appends an `<h1>` tag, sets its text content to "Hello World!", and ignores the result since we don't need to use it further.

## 🛠 Build and Run

To build and run your ReScript application, see the [Compile and Run](https://metalbolicx.github.io/resforge/#/compile-run) section.

## 📚 Documentation

<div align="center">

[![view - Documentation](https://img.shields.io/badge/view-Documentation-blue?style=for-the-badge)](https://metalbolicx.github.io/resforge/#/api-index)

</div>

## ✍ Do you want to learn more?

- Explore the [ReScript documentation](https://rescript-lang.org/docs/manual/v11.0.0/introduction) for more details on the language and its features.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Technologies used

* [ReScript](https://rescript-lang.org/), a strong typed functional programming language the compiles to JavaScript.

## License

Released under [MIT](/LICENSE) by [@MetalbolicX](https://github.com/MetalbolicX).