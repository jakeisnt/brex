#lang br/quicklang

(define (read-syntax path port)
  (define src-lines (port->lines port))
  ;; we aren't just wrapping everything in a 'handle anymore..
  ;; rather, to make this functional, we want to either nest everything
  ;; or pass everything as arguments to a single function, then iterate through them.
  (define src-datums (format-datums ' ~a src-lines))
  (define module-datum `(module funstacker-mod "funstacker.rkt"
                          ;; everything is passed to the handle-args function call now.
                          (handle-args ,@src-datums)))
  (datum->syntax #f module-datum))
(provide read-syntax)

(define-macro (funstacker-module-begin HANDLE-ARGS-EXPR)
  #'(#%module-begin
     (display (first HANDLE-ARGS-EXPR))))

;; renames the macro to its proper #%module-begin name so it can function in the other file without aliasing
(provide (rename-out [funstacker-module-begin #%module-begin]))

;; '.' character defines the following char, 'args', as a 'rest' argument.
;; accepts any number of positional arguments in a list.
(define (handle-args . args)
  ;; iterates over a list of values, carrying with it an accumulator
  ;; 
  (for/fold
   ;; definition of the accumulator and its initial value
   ([stack-acc empty])
   ;; 'arg' is the iterator, iterating over all of the 'args'
   ;; in-list constructs a sequence of elements to be iterated through
   ([arg (in-list args)]
    ;; a guard expression to skip invalid arguments
    #:unless (void? arg))

    ;; this is the iterator expression.
    ;; it uses the defined name, 'arg',
    ;; and performs some operation on it.
    ;; stack-acc is defined initially as the accumulator argument above as well.
    ;; rather than mutating a global variable as `stacker` did, this returns the entire
    ;; stack for every value.
    (cond
      [(number? arg) (cons arg stack-acc)]
      [(or (equal? * arg) (equal? + arg))
       (define op-result
         (arg (first stack-acc) (second stack-acc)))
       (cons op-result (drop stack-acc 2))])))

(provide handle-args)


;; because it can call + or *, it needs those from us too. pass them on.
(provide * +)