#lang br/quicklang

;; time to finish the reader!
(module reader br
  (require "reader.rkt")
  (provide read-syntax get-info)

  ;; get-info is used to provde various settings for the language,
  ;; like how it should use drracket features in drracket to provide information to the user of the language!
  (define (get-info port src-mod src-line src-col src-pos)
    (define (handle-query key default)
      ;; called with key erquest for info and default if key is not handled
      ;; color lexer, drracket indentation, or toolbar buttons
      (case key
        ;; these are the drracket defaults aside from the jsonic tools
        ;; create new modules in jsonic to provide functions that are used by jsonic
        ;; as they aren't used unless using jsonic, only require them when they're actually used! (lazily?)
        [(color-lexer) (dynamic-require 'jsonic/colorer 'color-jsonic)]
        [(drracket:indentation) (dynamic-require 'jsonic/indenter 'indent-jsonic)]
        [(drracket:toolbar-buttons) (dynamic-require 'jsonic/buttons 'button-list)]
        [else default]))
    handle-query))