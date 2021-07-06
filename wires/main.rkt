#lang br/quicklang

;; (module reader br/quicklang) hides reader inside a submodule:
;; to use, must (require (submod wires reader)).
;; better to use module+!!

(module+ reader
  (provide read-syntax))

(define (read-syntax path port)
  (define wire-datums
    ;; each one is an element in a list!
    (for/list ([wire-str (in-lines port)])
      (format-datum '(wire ~a) wire-str)))
  ;; strip the bindings from the syntax object: read-syntax should parse the syntax without assoc. bindings?
  (strip-bindings
   ;; quasisyntax: like quasiquote, but preserves the syntax information
   #`(module wires-mod wires/main #,@wire-datums)))

;; we don't have macros to expand here as language is easily parseable
;; as such, can use the original module begin as provided
(provide #%module-begin)

;; macro that needs to handle multiple cases? use define-macro-cases !!
;; recursive macro! references 'wire after reducing and applying the operation
(define-macro-cases wire
  ;; wire with a single value
  [(wire ARG -> ID) #'(define/display (ID) (val ARG))]
  ;; wire with result of operation with one argument
  [(wire OP ARG -> ID) #'(wire (OP (val ARG)) -> ID)]
  ;; wire with result of op with two arguments
  [(wire ARG1 OP ARG2 -> ID) #'(wire (OP (val ARG1) (val ARG2)) -> ID)]
  ;; else dies
  [else #'(void)])

(provide wire)

;; works just like (define ...), but prints the value at the end - so we have the solution to our puzzle!
(define-macro (define/display (ID) BODY)
  #'(begin
      ;; define the id as the body
      (define (ID) BODY)
      ;; after the wire function is defined,
      ;; we use the main module to print quoted name of wire function and runtime value by calling it
      ;; module+ main submodule automatically runs when racket runs a module directly
      ;; runs after module has been loaded so useful for deferring tasks (need to define all wires before printing values)
      (module+ main
        (displayln (format "~a: ~a" 'ID (ID))))))


;; if arg is a number, val passes it through, if it's a wire function, we call the wire function!
; (define (val num-or-wire)
;  (if (number? num-or-wire)
;      num-or-wire
;      (num-or-wire)))
;; works but inneficient: an explosion of intermediate wire values
;; we should probably cache them instead!
;; store everything in the val-cache hashmap
(define val-cache (make-hash))
;; reference val cache if not a number, calling it if the hash  val doesn't end up working
;(define (val num-or-wire)
;  (if (number? num-or-wire)
;      num-or-wire
;      (hash-ref! val-cache num-or-wire num-or-wire)))

;; probably a better idea to make val-cache private to the function though:
(define val
  ;; hides val-cache inside of val!
  (let ([val-cache (make-hash)])
    (lambda (num-or-wire)
      (if (number? num-or-wire)
          num-or-wire
          (hash-ref! val-cache num-or-wire num-or-wire)))))

;; use functions when we can and values when we must: val only needs runtime values
;; define/display, however, builds a submodule, and uses ID as raw name and runtime value


(define (mod-16bit x) (modulo x 65536))
;; defines a 16 bit value: calling the 16 bit function in a closure of the result of the procid
;; ex: (define ID (lambda (x) (mod-16bit (PROC-ID x))))
;; then once everything is coupled up all of the results are lazily-evaluated by the lang!
(define-macro (define-16bit ID PROC-ID)
  #'(define ID (compose1 mod-16bit PROC-ID)))

(define-16bit AND bitwise-and)
(define-16bit OR bitwise-ior)
(define-16bit NOT bitwise-not)
(define-16bit LSHIFT arithmetic-shift)
(define (RSHIFT x y) (LSHIFT x (- y)))
(provide AND OR NOT LSHIFT RSHIFT)