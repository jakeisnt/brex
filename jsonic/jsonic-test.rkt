#lang jsonic
// a line comment
[
  @$ 'null $@,
  @$ (* 6 7) $@,
  @$ (= 2 (+ 1 1)) $@,
  @$ (list "array" "of" "strings") $@,
  @$ (hash 'key-1 'null
  'key-2 (even? 3)
  'key-3 (hash 'subkey 21)) $@,
  @$ (list "i just made" "my first button!") %@
]

// i have syntax highlighting now? this is nuts! how does this work?
// i suspect that the racket plugin loads after the lsp
