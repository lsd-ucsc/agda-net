module Test where

open import Agda.Builtin.String renaming (primStringAppend to _++_)
open import Agda.Builtin.Unit
open import Data.Maybe using (nothing; just)
open import IO.Primitive
open import Function.Base using (case_of_)
open import Network.Simple.TCP

_>>_ : ∀ {a b} {A : Set a} {B : Set b} → IO A → (IO B) → IO B
a >> b = a >>= λ _ → b

main : IO ⊤
main = do

  print "Connecting to localhost:8081"
  connect "localhost" 8081 connectedToServer

  print "Serving on localhost:8080"
  serve "localhost" 8080 servingClient
  where

    connectedToServer : Socket → String → IO String
    connectedToServer sock addr = do
      print "Connected to server and making request"
      sendUtf8 sock "Please give me data!\n\n"
      mstr ← recvUtf8 sock 4096
      case mstr of
        λ { (just s) → return ("Data: " ++ s)
          ; nothing → return "No data. :("
          }

    servingClient : Socket → String → IO ⊤
    servingClient sock addr = do
      print ("Got connection from: " ++ addr)
      print "Waiting for client request"
      mstr ← recvUtf8 sock 4096
      case mstr of
        λ { (just "hello\n") → sendUtf8 sock "Good day!"
          ; (just s) → sendUtf8 sock ("Invalid request: Please say hello")
          ; nothing → print "No request"
          }
