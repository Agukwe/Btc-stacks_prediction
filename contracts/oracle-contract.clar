;; oracle-contract.clar

;; Define the contract owner
(define-constant contract-owner tx-sender)

;; Error codes
(define-constant err-owner-only (err u100))
(define-constant err-oracle-exists (err u101))
(define-constant err-oracle-not-found (err u102))

;; Data storage: List of trusted oracles
(define-data-var trusted-oracles (list 10 principal) (list))

;; Add a trusted oracle (only callable by the contract owner)
(define-public (add-trusted-oracle (oracle principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (not (contains? (var-get trusted-oracles) oracle)) err-oracle-exists)
        (ok (var-set trusted-oracles (append (var-get trusted-oracles) (list oracle))))
    )
)

;; Remove a trusted oracle (only callable by the contract owner)
(define-public (remove-trusted-oracle (oracle principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (contains? (var-get trusted-oracles) oracle) err-oracle-not-found)
        (ok (var-set trusted-oracles (filter (lambda (x) (not (is-eq x oracle))) (var-get trusted-oracles))))
    )
)

;; Check if an address is a trusted oracle
(define-read-only (is-trusted-oracle (address principal))
    (contains? (var-get trusted-oracles) address)
)