module Jwplayer where

import Prelude
import Control.Monad.Eff (Eff, kind Effect)

foreign import data JWPLAYER :: Effect

foreign import runJwplayer :: forall eff. String -> Eff ( jw :: JWPLAYER | eff) Unit

