module Main where

import Prelude
import YouTube.Api
import Jwplayer
import Control.Monad.Aff (Aff, launchAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Monad.Except.Trans (ExceptT(..), except, runExceptT)
import Control.Monad.Maybe.Trans (MaybeT(..), runMaybeT)
import DOM (DOM)
import DOM.HTML (window)
import DOM.HTML.Types (htmlDocumentToParentNode)
import DOM.HTML.Window (document)
import DOM.Node.Element (getAttribute)
import DOM.Node.Node (setTextContent)
import DOM.Node.ParentNode (QuerySelector(..), querySelector)
import DOM.Node.Types (Element, ParentNode, elementToNode)
import Data.Either (Either(..), either)
import Data.Maybe (Maybe(..), maybe)
import Data.Newtype (wrap)
import Data.Nullable (toMaybe)
import Network.HTTP.Affjax (AJAX)

documentParentNode :: ∀ t4. Eff ( dom ∷ DOM | t4 ) ParentNode
documentParentNode = do
  w <- window
  d <- document w
  pure $ htmlDocumentToParentNode d

maybeMeta :: ∀ t4. Eff ( dom ∷ DOM | t4 ) (Maybe Element)
maybeMeta = do
  parent <- documentParentNode
  el <- querySelector (wrap "meta[name=channel-id]") parent
  pure el

maybeChannelId :: ∀ t28. Eff ( dom ∷ DOM | t28 ) (Maybe String)
maybeChannelId = runMaybeT do
  meta <- MaybeT $ maybeMeta
  attr <- MaybeT $ getAttribute "content" meta
  pure attr

setVideoStatus :: ∀ t119. String → Eff ( dom ∷ DOM | t119 ) Unit
setVideoStatus str = do
  parent <- documentParentNode
  el <- querySelector (wrap "#video") parent
  case el of
       Nothing -> pure unit
       Just e -> setTextContent str (elementToNode e)
  
lookupLiveVideoId :: ∀ t80. ExceptT String (Aff ( ajax ∷ AJAX , dom ∷ DOM | t80 ) ) String
lookupLiveVideoId = do
  chan <- ExceptT $ maybe (Left "No meta tag or content") Right <$> liftEff maybeChannelId
  resp <- getLiveSearchResultT chan
  res  <- except $ maybe (Left "No live stream") Right (firstSearchResult resp)
  pure $ videoIdFromResult res

--main :: ∀ t131. Eff ( err ∷ EXCEPTION , ajax ∷ AJAX , dom ∷ DOM , jw ∷ JWPLAYER | t131 ) Unit
main = void $ launchAff do
  vid <- runExceptT lookupLiveVideoId
  liftEff $ either setVideoStatus runJwplayer vid

