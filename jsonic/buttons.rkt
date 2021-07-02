#lang br
(require racket/draw)


(define (button-func drr-window)
  (define expr-string "@$  %@")
  (define editor (send drr-window get-definitions-text))
  (send editor insert expr-string)
  (define pos (send editor get-start-position))
  (send editor set-position (- pos 3))) ;; calling drrwindow class method; jump back three spaces, to the center of the pasted string

(define our-jsonic-buttons (list
                           "Insert expression"
                           (make-object bitmap% 16 16) ;; white square!
                           button-func
                           #f))

;; each button in list must be four values:
; - string repr. butotn label
;; - 16 pixle high bitmap for the icon next ot the label
;; function called when button is pressed; receives reference to editor window
;; number that determines the ordering of the button on the toolbar (if it matters)

(define button-list (list our-jsonic-buttons))
(provide button-list)

