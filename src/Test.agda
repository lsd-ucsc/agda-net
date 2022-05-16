module Test where

open import IO.Primitive
open import Agda.Builtin.String
open import Agda.Builtin.Unit
open import Network.Simple.TCP

_>>_ : ∀ {a b} {A : Set a} {B : Set b} → IO A → (IO B) → IO B
a >> b = a >>= λ _ → b

main : IO ⊤
main = do
  connect "localhost" 8081 cb
  serve "localhost" 8080 cb
  where
    cb : Socket → String → IO ⊤
    cb sock addr = do
      print (primStringAppend "in callback for addr: " addr)
