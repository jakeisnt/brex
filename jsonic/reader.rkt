#lang br/quicklang

(require "tokenizer.rkt" "parser.rkt" racket/contract)

(define (read-syntax path port)
  (define parse-tree (parse path (make-tokenizer port)))
  (define module-datum `(module jsonic-module jsonic/expander
                          ,parse-tree))
  (datum->syntax #f module-datum))

;; (provide read-syntax)

;; -> : contract combinator. each argument is a function that performs a test, or a predicate
;; last argument tests the return value, other args test the input arguments
;; infix notation is typically used for contracts rather than prefix notation
(provide (contract-out
          [read-syntax
           ;; path: any type, and port, a port type. returns a syntax object
           ;; port should be just an input port
           (any/c input-port? . -> . syntax?)]))

