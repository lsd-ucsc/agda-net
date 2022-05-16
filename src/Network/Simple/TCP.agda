module Network.Simple.TCP where
-- We expose some functions from haskell's
-- network-simple:Network.Simple.TCP.

open import IO.Primitive
open import Agda.Builtin.String
open import Agda.Builtin.Unit
open import Data.Nat
open import Data.Product

postulate
  print : String → IO ⊤

  Socket : Set

  -- The callback receives socket address as a string.
  connect : ∀ {a : Set} → String → ℕ → (Socket → String → IO a) → IO a
  serve : String → ℕ → (Socket → String → IO ⊤) → IO ⊤

{-# FOREIGN GHC
  import qualified Data.Text as Text
  import qualified Data.Text.IO as TIO
  import qualified Network.Simple.TCP as TCP
  
  connectWrapper :: () -> Text.Text -> Integer -> (TCP.Socket -> Text.Text -> IO a) -> IO a
  connectWrapper () host port action = do
    TCP.connect
      (Text.unpack host)
      (show port)
      $ \(sock, addr) -> action sock (Text.pack $ show addr)
    
  serveWrapper :: Text.Text -> Integer -> (TCP.Socket -> Text.Text -> IO ()) -> IO ()
  serveWrapper listenInterface listenPort action = do
    TCP.serve
      (TCP.Host $ Text.unpack listenInterface)
      (show listenPort)
      $ \(sock, addr) -> action sock (Text.pack $ show addr)
#-}

{-# COMPILE GHC print    = TIO.putStrLn      #-}
{-# COMPILE GHC Socket   = type TCP.Socket   #-}
{-# COMPILE GHC connect  = connectWrapper    #-}
{-# COMPILE GHC serve    = serveWrapper      #-}
