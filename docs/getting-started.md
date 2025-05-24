# Getting Started

## Setup environment

ReScrtip can work on modern JavaScript runtimes, including [Node.js](https://nodejs.org), [Deno](https://deno.com/), [Bun](https://bun.sh/).

### Node.js

To work with Node.js, you must have installed the version 14 or higher. That's the ReScript version 11 requirement.

Check your Node.js version with the following command:
```sh
node -v
```
If you do not have Node.js installed in current environment, or the installed version is too low, you can use [nvm](https://github.com/nvm-sh/nvm) to install the latest version of Node.js.

## Create a new project

Navigate to the folder where your project will be created and run the following command to create a new directory:
```sh
mkdir my-rescript-app && cd my-rescript-app
```

Initialize a `package.json` file using one of the following commands:

::: code-group
```sh [npm]
npm init
```

```sh [pnpm]
pnpm init
```

```sh [yarn]
yarn init
```

```sh [bun]
bun init
```

```sh [deno]
deno init
```
:::

## Install Dependencies

Install Express, ReScript, and Rexpress using your preferred package manager:

::: code-group
```sh [npm]
npm install rescript @rescript/core rescript-elym
```

```sh [pnpm]
pnpm add rescript @rescript/core rescript-elym
```

```sh [yarn]
yarn add rescript @rescript/core rescript-elym
```

```sh [bun]
bun add rescript @rescript/core rescript-elym
```

```sh [deno]
deno add --npm rescript @rescript/core rescript-elym
```
:::

## Create the `rescript.json` File

Create a `rescript.json` file at the root of your project:

::: code-group
```sh [Unix]
touch rescript.json
```

```ps1 [Windows]
New-Item -Path ".\rescript.json" -ItemType File
```
:::

In `rescript.json` file, add the following content:
```json
{
  "name": "your-project-name",
  "sources": [
    {
      "dir": "src",
      "subdirs": true
    }
  ],
  "package-specs": [
    {
      "module": "esmodule",
      "in-source": true
    }
  ],
  "suffix": ".res.mjs",
  "bs-dependencies": [
    "@rescript/core",
    "rescript-elym"
  ],
  "bsc-flags": [
    "-open RescriptCore"
  ]
}
```

::: details
For a more advanced configuration of the `rescript.json` file, you can read the [Rescript documentation](https://rescript-lang.org/docs/manual/v11.0.0/build-configuration).
:::

## Helper commands

Add the following scripts to your `package.json` to compile your `.res` files to JavaScript:

```json
"scripts": {
  "res:dev": "rescript -w",
  "res:build": "rescript",
  "res:clean": "rescript clean"
}
```

::: details
If you want more information about how to set up your ReScript project, you can check the [ReScript installation documentation](https://rescript-lang.org/docs/manual/v11.0.0/installation).
:::

**Next Steps:**
You are now ready to start to develop a front-end application. See the [Usage Examples](./examples.md) for sample code and patterns.