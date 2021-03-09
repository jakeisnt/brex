#lang br/quicklang

(provide + *)

;; only takes one s-expression,
;; so we only need it to accept and pass in one!
(define-macro (stackerizer-mb EXPR)
  #'(#%module-begin
     ;; flatten the expression to one list rather than nested
     ;; then flip it and display each character on a new line
     ;; (+ 1 (+ 2 3)) -> 3 2 + 1 + - exactly what our stack needs!
     (for-each displayln (reverse (flatten EXPR)))))

(provide (rename-out [stackerizer-mb #%module-begin]))


;; this evaluates the operations properly without doing anything,
;; but we /do/ need to evaluate more than two arguments in the right order!

;; define-macro-cases works just like define-macro,
;; but it accepts a series of patterns to match - just like a 'cond'

;(define-macro-cases +
;; if it matches just one argument, it returns a syntax object with that argument.
;  [(+ FIRST) #'FIRST]
  ;; if it matches more than one argument (two arguments and whatever is next)
  ;; '+ symbol represents a dyadic addition rather than a variadic addition to guarantee proper order of ops
  ;; it will be replaced by something later
  ;; the macro is called recursively to form a lot of dyadic operations!
;  [(+ FIRST NEXT ...) #'(list '+ FIRST (+ NEXT ...))])

; we need another macro for *. instead of copy pasting we can abstract to generate code for both!

(define-macro (define-op OP)
  ;; returns the syntax structure for the macro cases
  #'(define-macro-cases OP
      ;; no different from the previous, but substitutes OP in
      [(OP FIRST) #'FIRST]
      ;; the (... ...) form escapes a pattern that consists of a single ellipsis.
      ;; this allows us to use it in the following program.
      [(OP FIRST NEXT (... ...))
       #'(list 'OP FIRST (OP NEXT (... ...)))]))

;; (define-op +)
;; (define-op *)

;; ellipsis means 'handle the other elements the same way we handled the current one'.

;; let's define all of our ops with one macro!
(define-macro (define-ops OP ...)
  #'(begin
      (define-macro-cases OP
        [(OP FIRST) #'FIRST]
        [(OP FIRST NEXT (... ...))
         #'(list 'OP FIRST (OP NEXT (... ...)))])
      ;; this ellipsis, in conjunction with begin,
      ;; treats the rest of the arguments the same way as the first!
      ...))

(define-ops + *)