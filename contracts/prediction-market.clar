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