# atom-ternjs package

Javascript code intelligence for atom with tern.js.

Based on https://github.com/artoale/atom-tern

(highly experimental)

# Installation

* Since this package has'nt been released as an package, clone and npm install
* Create a symlink to the cloned repo in /Users/.../.atom/packages
* In your project root, create a file named '.tern-project'. See docs http://ternjs.net/doc/manual.html#configuration

# Usage

Currently supports the following features:

* Find definition (set your cursor position to one of variable, function or instance -> open context-menu and trigger "Find definition"), "Find definition" will only be available if atom wrapped the element correctly in one of: .variable.js, .function.js or .instance.js (see menus/atom-ternjs.cson)
* Completion (completion triggers if lastChar was "." and we are in the right context (e.g.: "this." -> triggers completion if completions.length > 0))
* At the current state, only the current active editor is handled
