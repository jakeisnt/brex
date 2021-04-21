#lang br/quicklang

;; every library is available from every DSL!
(require json)

;; this will map reader produced code to racket expressions!
;; add bindings to identifiers; we are always 'binding identifiers' rather than 'assigning values'

(define-macro (jsonic-mb PARSE-TREE)
  #'(#%module-begin
     (define result-string PARSE-TREE)
     ;; validate the expr, then display the result!
     (define validated-jsexpr (string->jsexpr result-string))
     (display result-string)))

;; rename so it doesn't conflict with the real module begin!
(provide (rename-out [jsonic-mb #%module-begin]))

;; match exactly a character in a json string,
;; converting it to a syntax object
(define-macro (jsonic-char CHAR-TOK-VALUE)
  #'CHAR-TOK-VALUE)

(provide jsonic-char)

;; match the whole program, then trim the annotations from the end
(define-macro (jsonic-program SEXP-OR-JSON-STR ...)
  #'(string-trim (string-append SEXP-OR-JSON-STR ...)))
(provide jsonic-program)

;; accept sexp token, then tries to convert it from jsexpr to strign
;; format datum converts source string into s-expression
;; as this is a macro, #'SEXP-STR is a syntax template for it - it will be subbed in later.

(define-macro (jsonic-sexp SEXP-STR)
  ;; with pattern introduces new pattern variables forthe macros
  ;; what does the a mean? is that a special syntax pattern? TODO
  (with-pattern ([SEXP-DATUM (format-datum '~a #'SEXP-STR)])
    ;; convert the expression back into the string after it's parsed
    #'(jsexpr->string SEXP-DATUM)))

(provide jsonic-sexp)