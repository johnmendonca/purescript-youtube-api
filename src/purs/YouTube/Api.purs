module YouTube.Api where

import Prelude
import Control.Monad.Aff (Aff, attempt)
import Control.Monad.Except (runExcept, withExcept)
import Control.Monad.Except.Trans (ExceptT(..))
import Data.Array (head)
import Data.Bifunctor (lmap)
import Data.Either (Either)
import Data.Foreign (Foreign, F, toForeign)
import Data.Foreign.Class (class Decode)
import Data.Foreign.Generic (defaultOptions, genericDecode, genericDecodeJSON)
import Data.FormURLEncoded (encode, fromArray)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe(Just))
import Data.Tuple (Tuple(..))
import Network.HTTP.Affjax (AJAX, get)

newtype SearchListResponse = SearchListResponse {
  kind :: String,
  etag :: String,
  regionCode :: String,
  items :: Array SearchResult
}

newtype SearchResult = SearchResult {
  kind :: String,
  etag :: String,
  id   :: Video,
  snippet :: Snippet
}

newtype Video = Video {
  kind :: String,
  videoId :: String
}

newtype Snippet = Snippet {
  publishedAt :: String,
  channelId :: String,
  title :: String,
  description :: String,
  thumbnails :: Thumbnails,
  channelTitle :: String,
  liveBroadcastContent :: String
}

newtype Thumbnails = Thumbnails {
  default :: Thumbnail,
  medium :: Thumbnail,
  high :: Thumbnail
}

newtype Thumbnail = Thumbnail {
  url :: String,
  width :: Int,
  height :: Int
}

derive instance genericSearchListResponse :: Generic SearchListResponse _
derive instance genericSearchResult       :: Generic SearchResult _
derive instance genericVideo              :: Generic Video _
derive instance genericSnippet            :: Generic Snippet _
derive instance genericThumbnails         :: Generic Thumbnails _
derive instance genericThumbnail          :: Generic Thumbnail _

instance showSearchListResponse :: Show SearchListResponse where
  show = genericShow

instance showSearchResult :: Show SearchResult where
  show = genericShow

instance showVideo :: Show Video where
  show = genericShow

instance showSnippet :: Show Snippet where
  show = genericShow

instance showThumbnails :: Show Thumbnails where
  show = genericShow

instance showThumbnail :: Show Thumbnail where
  show = genericShow

opts = defaultOptions { unwrapSingleConstructors = true }

instance decodeSearchListResponse :: Decode SearchListResponse where
  decode = genericDecode opts

instance decodeSearchResult :: Decode SearchResult where
  decode = genericDecode opts

instance decodeVideo :: Decode Video where
  decode = genericDecode opts

instance decodeSnippet :: Decode Snippet where
  decode = genericDecode opts

instance decodeThumbnails :: Decode Thumbnails where
  decode = genericDecode opts

instance decodeThumbnail :: Decode Thumbnail where
  decode = genericDecode opts

--readSearchListResponse :: String -> F SearchListResponse
--readSearchListResponse = genericDecodeJSON opts

--readSearchResult :: Foreign -> F SearchResult
--readSearchResult = genericDecodeJSON opts

--readVideo :: Foreign -> F Video
--readVideo = genericDecodeJSON opts

--readSnippet :: Foreign -> F Snippet
--readSnippet = genericDecodeJSON opts

--readThumbnails :: Foreign -> F Thumbnails
--readThumbnails = genericDecodeJSON opts

--readThumbnail :: Foreign -> F Thumbnail
--readThumbnail = genericDecodeJSON opts

asyncGet :: ∀ t. String → Aff ( ajax ∷ AJAX | t ) (Either String String)
asyncGet u = (lmap show) <$> attempt do
  response <- get u
  pure response.response

apiKey :: String
apiKey = "AIzaSyBQEt05llzRNjP_wk3M-B4kxUkeTKpu3is"

channelLive :: String -> String
channelLive chan = "https://www.googleapis.com/youtube/v3/search?" <>
                   (encode $ fromArray [ Tuple "part"      (Just "id,snippet")
                                       , Tuple "key"       (Just apiKey)
                                       , Tuple "eventType" (Just "live")
                                       , Tuple "order"     (Just "date")
                                       , Tuple "type"      (Just "video")
                                       , Tuple "channelId" (Just chan) ])

getLiveSearchResultT :: ∀ t232. String → ExceptT String (Aff ( ajax ∷ AJAX | t232 ) ) SearchListResponse
getLiveSearchResultT chan = do
  res <- ExceptT $ asyncGet (channelLive chan)
  --ExceptT $ pure $ runExcept $ withExcept show $ readSearchListResponse res
  ExceptT $ pure $ runExcept $ withExcept show $ genericDecodeJSON opts res

firstSearchResult :: SearchListResponse → Maybe SearchResult
firstSearchResult (SearchListResponse { items: items }) = head items

videoIdFromResult :: SearchResult → String
videoIdFromResult (SearchResult {id: (Video {videoId: videoId}) }) = videoId
