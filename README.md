# atom-ternjs package

Javascript code intelligence for atom with tern.js.

Based on https://github.com/artoale/atom-tern

(highly experimental)

# Installation

* Since this package hasn't been released as a package, clone and npm install
* Create a symlink to the cloned repo in /Users/.../.atom/packages like so:
```
  $ ln -s /path/to/repo /path/to/symlink
```
* In your project root, create a file named '.tern-project'. See docs http://ternjs.net/doc/manual.html#configuration. E.g.:
```
{
  "libs": [
    "browser",
    "jquery"
  ],
  "loadEagerly": [
    "./test/**/*.js"
  ]
}
```
# Usage

Currently supports the following features:

* Find definition (set your cursor position to one of variable, function or instance -> open context-menu and trigger "Find definition"), "Find definition" will only be available if atom wrapped the element correctly in one of: .variable.js, .function.js or .instance.js (see menus/atom-ternjs.cson)
* Completion (completion triggers if lastChar was "." and we are in the right context (e.g.: "this." -> triggers completion if completions.length > 0))
* At the current state, only the current active editor is handled for find definition
