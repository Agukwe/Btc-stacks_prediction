;; prediction-market.clar

;; Import the oracle trait
(use-trait oracle-trait .oracle-contract.oracle-trait)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant FEE_PERCENTAGE u5) ;; 5% fee
(define-constant MIN_STAKE u100) ;; Minimum stake amount (in microSTX)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-event (err u101))
(define-constant err-event-resolved (err u102))
(define-constant err-invalid-stake (err u103))
(define-constant err-not-participant (err u104))
(define-constant err-unauthorized (err u105))

;; Data storage
(define-map events
    {event-id: uint}
    {
        creator: principal,
        title: (string-utf8 100),
        description: (string-utf8 500),
        deadline: uint,
        resolved: bool,
        outcome: (optional (string-utf8 10)) ;; "Yes" or "No"
    }
)

(define-map stakes
    {event-id: uint, participant: principal}
    {
        amount: uint,
        outcome: (string-utf8 10) ;; "Yes" or "No"
    }
)

(define-map total-stakes
    {event-id: uint}
    {
        yes: uint,
        no: uint
    }
)

;; Helper functions

;; Calculate the fee amount
(define-private (calculate-fee (amount uint))
    (/ (* amount FEE_PERCENTAGE) u100)
)

;; Update total stakes for an event
(define-private (update-total-stakes (event-id uint) (outcome (string-utf8 10)) (amount uint))
    (let ((totals (default-to {yes: u0, no: u0} (map-get? total-stakes {event-id: event-id}))))
        (if (is-eq outcome "Yes")
            (map-set total-stakes {event-id: event-id} {yes: (+ (get yes totals) amount), no: (get no totals)})
            (map-set total-stakes {event-id: event-id} {yes: (get yes totals), no: (+ (get no totals) amount)})
        )
    )
)