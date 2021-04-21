#lang br/quicklang

;; accept bf-module-begin
(define-macro (bf-module-begin PARSE-TREE)
  ;; prefix the parse tree with the '
  #'(#%module-begin PARSE-TREE))

(provide (rename-out [bf-module-begin #%module-begin]))

;; given the definition of the parse tree, we now look for three types of parse tree nodes;
;; one defined for every type in the #lang brag parse tree.

;; define-macro relies on a syntax pattern, breaking down a syntax object into pieces

;; bf-program, literal identifier in code
(define-macro (bf-program
         ;; if in all caps, the argumetn is a pattern variable that matches everything
         ;; otherwise, it matches /literally/ the name of the argument as provided
         OP-OR-LOOP-ARG
         ;; the ellipsis is our * qualifier, accepting all of the arguments that follow
         ;; this also allows us to accept no arguments
         ...) #'(void OP-OR-LOOP-ARG ...))

(provide bf-program)

;; as bf-loop follows the same rules, we do the same thing,
;; but this time we ensure that the loop is surrounded by brackets!
(define-macro (bf-loop "[" OP-OR-LOOP-ARG ... "]")
  ;; we have a rule to follow now: until the current byte is 0, we read the arguments
  #'(until (zero? (current-byte)) OP-OR-LOOP-ARG ...))

(provide bf-loop)

;; for bf-op, we can use the cases macro, which gives us
;; the right matching statements already! syntax pattern -> syntax template.
;; we map these to functions in a prelude that actually perform the desired behavior!
(define-macro-cases bf-op
  [(bf-op ">") #'(gt)]
  [(bf-op "<") #'(lt)]
  [(bf-op "+") #'(plus)]
  [(bf-op "-") #'(minus)]
  [(bf-op ".") #'(period)]
  [(bf-op ",") #'(comma)])
(provide bf-op)

;; bf starts with a byte array of 30,000 elements
(define arr (make-vector 30000 0))
(define ptr 0)
;; these are kept internal to this file and mutated - this lets us implement
;; the language without forcing the user to do any work!

;; get the item in the arr at the index! or the current byte pointed to in the vector.
(define (current-byte) (vector-ref arr ptr))
;; we probably also need to be able to set things to get any of the operations to work
(define (set-current-byte! val) (vector-set! arr ptr val))

(define (gt) (set! ptr (add1 ptr)))
(define (lt) (set! ptr (sub1 ptr)))

;; plus and minus increment and decrement the pointer, respectively
(define (plus) (set-current-byte! (add1 (current-byte))))
(define (minus) (set-current-byte! (sub1 (current-byte))))

;; write the current char to stdout
(define (period) (write-byte (current-byte)))

;; read from stdin
(define (comma) (set-current-byte! (read-byte)))
