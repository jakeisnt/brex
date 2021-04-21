#lang br/quicklang
; why make languages?
; the only indispensable tool is the programming language we use
; just another program; takes input, evaluates, and produces a result. here, source code is transformed.
; making a programming language is just making a standalone dsl. : |
; helps you naturally describe your solutions - just make a DSL in which you can express what you want!


; racket language components:
; - reader - source -> s-expression
; - expander - expand s-expressions to real racket expressions

; every language made requires specitying a reader and expander
; to use a local language: #lang reader "langname.rkt"

;; read-syntax: returns code describing a module as packaged by a syntax object
; racket replaces source code with this module
; this module then invokes the expander
; module is then evaluated normally by racket.

;; path: the path to the file
;; port: a generic IO interface
;; converts contents of port to lines, then return code describing a module with an expander
;; expander determines how the expressions inside of the module are interpreted

;; to convert code into a syntax object: first convert it to a datum. quote it, basically
;; then, datum->syntax converts this to code syntax
;; we then return the syntax object as the result of a function. a syntax object is just a datum with programatic context!

;;(define (read-syntax path port)
;;  (define src-lines (port->lines port))
;;  (datum->syntax #f '(module lucy br
;;                       42)))

;; the return value is /entirely/ replaced by the syntax object returned! (module lucy br 42)
;; the #lang line is no different from declaring the module and the syntax transform at the top of the file.

;; wrap each line in a (handle ...) form with format-datums
;; after a quasiquote (`), the comma prefix allows us to insert variables into s-expressions
;; to insert multiple values and 'unwrap' them inline, use ',@' instead. this prevents nested sublists
;;(define (read-syntax path port)
;;  (define src-lines (port->lines port))
;;  (define src-datums (format-datums ''(handle ~a) src-lines))
;;  (define module-datum `(module stacker-mod br
;;                          ,@src-datums))
;;  (datum->syntax #f module-datum))

;; the specified expander refers to the file that provides the functions
;; to call after expansion; essentially the prelude of the core language!
;; here, it's self-referential, so it borrows from itself
(define (read-syntax path port)
  (define src-lines (port->lines port))
  (define src-datums (format-datums '(handle ~a) src-lines))
  (define module-datum `(module stacker-mod "stacker.rkt"
                          ,@src-datums))
  (datum->syntax #f module-datum))
(provide read-syntax)

;; let's define the expander here:
;; the expander applies a series of macros to expand each line to give it programatic functionality!
;; macros are syntax transformers, accepting code packaged as a syntax object and returning another as output
;; they're essentially functions, but 'functions' should only be used to describe runtime execution. it's just a template.

;; macros can only treat code as syntax. they cannot evaluate args or expressions within the code (only available at runtime)

;; the expander for a language starts with #%module-begin by convention. this is converted to an invocation of that macro.
;; currently this does nothing. it accepts the expr and returns it in the module begin amcro.
;; macros are typically defined by syntax patterns: regular expressions to break the input into pieces and rearrange it.
;; the prefix #' makes the code returned into a syntax object. it returns the datum and the lexical context (environment)
(define-macro (stacker-module-begin HANDLE-EXPR ...)
  #'(#%module-begin
     HANDLE-EXPR ...
     ;; then after our program is done....
     (display (first stack))
     ))


;; renames the macro to its proper #%module-begin name so it can function in the other file without aliasing
(provide (rename-out [stacker-module-begin #%module-begin]))

;; now we have to define the stack!
(define stack '())
(define (pop-stack!)
  (define arg (first stack))
  (set! stack (rest stack))
  arg)

(define (push-stack! arg)
  (set! stack (cons arg stack)))

;; the brackets mean what?
;; what does the #f mean?
;; it takes one argument, called arg. this argument is declared optional by '[ ... #f]'
;; if it's a number, push it!
;; if it's one of our two operators, call the operator on the first two items of the stack.
(define (handle [arg #f])
  (cond
    [(number? arg) (push-stack! arg)]
    [(or (equal? + arg) (equal? * arg))
     (define op-result (arg (pop-stack!) (pop-stack!)))
     (push-stack! op-result)]))

;; the code needs to evaluate handle after macro expansion!
(provide handle)
;; because it can call + or *, it needs those from us too. pass them on.
(provide * +)

;; it's not displaying anything yet! we need (display (first stack)) to show how it ends to the define-macro.
;; this prints out the top of the stack after our program is done executing : )