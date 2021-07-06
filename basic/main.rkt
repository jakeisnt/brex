#lang br/quicklang
(require "parser.rkt" "tokenizer.rkt")

(define (read-syntax path port)
  ;; make the parse tree with the parser!
  (define parse-tree (parse path (make-tokenizer port path)))
  ;; strip bindings from the tokenizer after expanding it!
  (strip-bindings
    ;; insert parse tree into module expression, but the expander itself does not need the bindings
    #`(module basic-mod basic/expander #,parse-tree)))


(module+ reader
  (provide read-syntax))
