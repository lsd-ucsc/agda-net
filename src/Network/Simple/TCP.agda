module Network.Simple.TCP where
-- We expose some functions from haskell's
-- network-simple:Network.Simple.TCP.

open import Agda.Builtin.String using (String)
open import Agda.Builtin.Unit using (⊤)
open import Data.Maybe using (Maybe; nothing; just)
open import Data.Nat using (ℕ)
open import Function.Base using (_∘_)
open import IO.Primitive using (IO; _>>=_; return)

{-# FOREIGN GHC
  import qualified Data.Text as Text
  import qualified Data.Text.IO as TIO
  import qualified Data.Text.Encoding as TENC
  import qualified Network.Simple.TCP as TCP
#-}




postulate
  print : String → IO ⊤

{-# COMPILE GHC print = TIO.putStrLn #-}




postulate
  Socket : Set

  -- The callback receives socket address as a string. This is useful
  -- for callbacks to serve, which will want to distinguish clients.
  connect : ∀ {a : Set} → String → ℕ → (Socket → String → IO a) → IO a
  serve : String → ℕ → (Socket → String → IO ⊤) → IO ⊤

{-# FOREIGN GHC
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

{-# COMPILE GHC Socket  = type TCP.Socket #-}
{-# COMPILE GHC connect = connectWrapper  #-}
{-# COMPILE GHC serve   = serveWrapper    #-}




-- FIXME later:
-- 
-- COMPILE pragmas must appear in the same module as their
-- corresponding definitions,
-- when checking the pragma
-- COMPILE GHC Maybe = data Maybe (Nothing | Just)
--
-- And so, a maybe type local to this agda module: Mebbe

data Mebbe (A : Set) : Set where
  Noth : Mebbe A
  Jus : A → Mebbe A

toMaybe : ∀ {A} → Mebbe A → Maybe A
toMaybe Noth = nothing
toMaybe (Jus a) = just a

{-# COMPILE GHC Mebbe  = data Maybe (Nothing | Just) #-}




postulate
  -- FIXME later: String is text:Text in haskell, not raw binary, and
  -- so might be bloated.
  sendUtf8 : Socket → String → IO ⊤

  -- FIXME later: The bytes arg here goes via Integer to Int, so
  -- overflow is a concern.
  --
  -- FIXME later: The return type here is text:Text, but the network
  -- isn't guaranteed to give correctly formatted utf8 data.
  recvUtf8M : Socket → ℕ → IO (Mebbe String)

recvUtf8 : Socket → ℕ → IO (Maybe String)
recvUtf8 sock count = recvUtf8M sock count >>= return ∘ toMaybe

{-# FOREIGN GHC
  sendUtf8Wrapper :: TCP.Socket -> Text.Text -> IO ()
  sendUtf8Wrapper sock t = TCP.send sock $ TENC.encodeUtf8 t

  recvUtf8Wrapper :: TCP.Socket -> Integer -> IO (Maybe Text.Text)
  recvUtf8Wrapper sock count
    | count == roundtrip = return . fmap TENC.decodeUtf8 =<< TCP.recv sock (fromInteger count)
    | otherwise = error "byte count did not fit in machine Int"
    where
      roundtrip = fromIntegral (fromInteger count :: Int) :: Integer
#-}

{-# COMPILE GHC sendUtf8  = sendUtf8Wrapper #-}
{-# COMPILE GHC recvUtf8M = recvUtf8Wrapper #-}
