{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings    #-}
{-# LANGUAGE QuasiQuotes          #-}
{-# LANGUAGE TemplateHaskell      #-}
{-# LANGUAGE TypeFamilies         #-}
import Yesod

import S0
import qualified Type as T

import Network.Wai (remoteHost, requestHeaders)
import Network.SockAddr
import Data.Maybe (fromMaybe)
import Data.Text (pack)

import Data.ByteString.Char8(unpack)

data App = App

mkYesod "App" [parseRoutes|
/ HomeR GET
/s0/j S0Json GET
/s0/h S0Html GET
/s0   S0Stat GET
|]

instance Yesod App

getHomeR  = return $ object ["msg" .= "世界，你好！"]

----------------
dataDir = "."

-----------------
readStat :: IO [T.S0Rec]
readStat = do
  l <- readS0Rec dataDir
  return $ (\x -> x { T.ip = "0.0.0.0" }) <$> l

getIP :: Handler String
getIP = do
   headers <- requestHeaders <$> waiRequest
   let ip' = lookup "X-Real-IP" headers
   case ip' of
        Just str -> return $ unpack str
        _        -> do raddr <- remoteHost <$> waiRequest
                       return $ showSockAddr raddr

getS0Json :: Handler Value
getS0Json = do
   addHeader "Access-Control-Allow-Origin" "*"

   -- add
   ip <- getIP

   name  <- fromMaybe "" <$> lookupGetParam "name"
   email <- fromMaybe "" <$> lookupGetParam "email"

   -- liftIO $ print (ip, name, email)

   -- success add or not?
   -- current add record
   (succ, curr) <- liftIO $ addS0Rec dataDir name email (pack ip)

   l <- liftIO $ readStat

   return $ object [ "succ" .= succ, "curr" .= curr, "list" .= l ]

getS0Html :: Handler Html
getS0Html = defaultLayout [whamlet|Hello World!|]

-- get current status
getS0Stat :: Handler Value
getS0Stat = do
   addHeader "Access-Control-Allow-Origin" "*"

   list <- liftIO readStat

   return $ object [ "list" .= list ]


main = warp 3000 App
