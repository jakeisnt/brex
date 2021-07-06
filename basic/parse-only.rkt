#lang br/quicklang
(require "parser.rkt" "tokenizer.rkt")

;; this language can be used by referencing #lang basic/parse-only: imports language in parse-only.rkt from basic

(define (read-syntax path port)
  (define parse-tree (parse path (make-tokenizer port path)))
  (strip-bindings
   #`(module basic-parser-mod basic/parse-only #,parse-tree)))

(module+ reader (provide read-syntax))

(define-macro (parser-only-mb PARSE-TREE)
  #'(#%module-begin 'PARSE-TREE))

(provide (rename-out [parser-only-mb #%module-begin]))
