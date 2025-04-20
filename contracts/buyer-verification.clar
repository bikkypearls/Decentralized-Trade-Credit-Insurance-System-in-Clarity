;; Buyer Verification Contract
;; This contract validates the financial stability of purchasers

(define-data-var min-credit-score uint u650)
(define-data-var admin principal tx-sender)

;; Map to store verified buyers with their credit scores and verification status
(define-map verified-buyers
  principal
  {
    credit-score: uint,
    verified: bool,
    last-updated: uint
  }
)

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin))
)

;; Update admin
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-admin) (err u403))
    (ok (var-set admin new-admin))
  )
)

;; Update minimum credit score requirement
(define-public (set-min-credit-score (new-score uint))
  (begin
    (asserts! (is-admin) (err u403))
    (ok (var-set min-credit-score new-score))
  )
)

;; Add or update a buyer's verification status
(define-public (verify-buyer (buyer principal) (credit-score uint))
  (begin
    (asserts! (is-admin) (err u403))
    (asserts! (>= credit-score (var-get min-credit-score)) (err u400))
    (ok (map-set verified-buyers buyer {
      credit-score: credit-score,
      verified: true,
      last-updated: block-height
    }))
  )
)

;; Revoke a buyer's verification status
(define-public (revoke-verification (buyer principal))
  (begin
    (asserts! (is-admin) (err u403))
    (match (map-get? verified-buyers buyer)
      buyer-data (ok (map-set verified-buyers buyer
        (merge buyer-data { verified: false, last-updated: block-height })))
      (err u404)
    )
  )
)

;; Check if a buyer is verified
(define-read-only (is-buyer-verified (buyer principal))
  (match (map-get? verified-buyers buyer)
    buyer-data (get verified buyer-data)
    false
  )
)

;; Get buyer's credit score
(define-read-only (get-buyer-credit-score (buyer principal))
  (match (map-get? verified-buyers buyer)
    buyer-data (ok (get credit-score buyer-data))
    (err u404)
  )
)
