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

;; Public functions

;; Create a new prediction event
(define-public (create-event (title (string-utf8 100)) (description (string-utf8 500)) (deadline uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (let ((event-id (+ (var-get event-counter) u1)))
            (begin
                (var-set event-counter event-id)
                (map-set events {event-id: event-id} {
                    creator: tx-sender,
                    title: title,
                    description: description,
                    deadline: deadline,
                    resolved: false,
                    outcome: none
                })
                (ok event-id)
            )
        )
    )
)

;; Stake tokens on an event outcome
(define-public (stake (event-id uint) (outcome (string-utf8 10)) (amount uint))
    (begin
        (asserts! (>= amount MIN_STAKE) err-invalid-stake)
        (asserts! (or (is-eq outcome "Yes") (is-eq outcome "No")) err-invalid-event)
        (let ((event (unwrap! (map-get? events {event-id: event-id}) err-invalid-event)))
            (asserts! (not (get resolved event)) err-event-resolved)
            (asserts! (> (get deadline event) block-height) err-event-resolved)
            (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
            (map-set stakes {event-id: event-id, participant: tx-sender} {amount: amount, outcome: outcome})
            (update-total-stakes event-id outcome amount)
            (ok true)
        )
    )
)

;; Resolve an event (only the event creator or a trusted oracle can resolve)
(define-public (resolve-event (event-id uint) (outcome (string-utf8 10)))
    (begin
        (asserts! (or (is-eq outcome "Yes") (is-eq outcome "No")) err-invalid-event)
        (let ((event (unwrap! (map-get? events {event-id: event-id}) err-invalid-event)))
            (asserts! (or 
                (is-eq tx-sender (get creator event)) 
                (contract-call? .oracle-contract is-trusted-oracle tx-sender)
            ) err-unauthorized)
            (asserts! (not (get resolved event)) err-event-resolved)
            (let ((totals (unwrap! (map-get? total-stakes {event-id: event-id}) err-invalid-event)))
                (begin
                    (map-set events {event-id: event-id} (merge event {resolved: true, outcome: (some outcome)}))
                    (if (is-eq outcome "Yes")
                        (distribute-winnings event-id "Yes" (get no totals))
                        (distribute-winnings event-id "No" (get yes totals))
                    )
                    (ok true)
                )
            )
        )
    )
)

;; Distribute winnings to participants
(define-private (distribute-winnings (event-id uint) (winning-outcome (string-utf8 10)) (losing-pool uint))
    (let ((fee (calculate-fee losing-pool)))
        (begin
            (stx-transfer? fee (as-contract tx-sender) contract-owner)
            (map-set total-stakes {event-id: event-id} {yes: u0, no: u0})
            (ok true)
        )
    )
)

;; Read-only functions

;; Get event details
(define-read-only (get-event (event-id uint))
    (match (map-get? events {event-id: event-id})
        event (ok event)
        (err err-invalid-event)
    )
)

;; Get total stakes for an event
(define-read-only (get-total-stakes (event-id uint))
    (match (map-get? total-stakes {event-id: event-id})
        totals (ok totals)
        (err err-invalid-event)
    )
)

;; Get participant's stake for an event
(define-read-only (get-participant-stake (event-id uint) (participant principal))
    (match (map-get? stakes {event-id: event-id, participant: participant})
        stake (ok stake)
        (err err-not-participant)
    )
)
