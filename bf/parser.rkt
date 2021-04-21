#lang brag

; parsing in racket: no more s-expressions!
; use a parser generator, as specified by a grammar: a way of notating any program written in the language

; grammar contains:
; - series of production rules, one per line. each defines a structural element of the rule and the pattern it should match.
; - can write ambiguous grammars - producing multiple potential parse trees
; - recursive grammars can also succinctly express rules: i.e. a list of items, each a parseable token itself

; bf grammar:
; bf-program: (bf-op | bf-loop)* 0 or more of a bf op or a bf loop
; bf-op: ">" | "<" | "+" | "-" | "." | ","
; bf-loop: "[" bf-program "]"
; this isn't /quite/ a BNF grammar, but it's organized in this way to make it easy to read and reach

; now for converting this into a parser!
; the power of racket DSLs allows us to express this in exactly the same way!
bf-program : (bf-op | bf-loop)*
bf-op: ">" | "<" | "+" | "-" | "." | ","
bf-loop: "[" bf-program "]"

; a parser really accepts a sequence of tokens: smallest meaningful units of source code.
; tokenizer can reduce the number of distinct tokens we have to handle in our grammar:
; - comments
; - type of value can be represented with generic token rather than symbol
; if we don't use a tokenizer, every character becomes a potential token, which is sometimes fine? but mostly not.

