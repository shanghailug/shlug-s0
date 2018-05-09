{-# LANGUAGE DeriveGeneric #-}

module Type where

import Data.Aeson
import GHC.Generics

import Data.Text(Text)

data S0Rec = S0Rec { name :: !Text
                   , email :: !Text
                   , ip :: !Text
                   , date :: Int -- milliseconds
                   , value :: Int
                   , code :: String
                   , confirmed :: Bool
                   } deriving (Eq, Ord, Show, Read, Generic)

instance FromJSON S0Rec
instance ToJSON S0Rec
