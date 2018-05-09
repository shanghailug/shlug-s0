{-# LANGUAGE DeriveGeneric #-}

module S0 (readS0Rec, addS0Rec) where

import Data.Aeson
import GHC.Generics

import Data.Text (Text)
import Data.Maybe (listToMaybe)
import Control.Monad (join)
import System.Directory (listDirectory, createDirectoryIfMissing)

import Type (S0Rec(..))
import qualified Type as T

import Data.Time.Clock.POSIX (getPOSIXTime)
import Data.Char (ord, chr)

import Data.List (sort)

import System.Random (randomRIO)

todoDir = "todo"
doneDir = "done"

-- read s0 records in dir
readS0RecDir :: FilePath -> IO [S0Rec]
readS0RecDir dir = do
  createDirectoryIfMissing True dir

  files <- listDirectory dir
  fmap join $ mapM (\f -> readFile (dir ++ "/" ++ f) >>=
                          (return . take 2000) >>=
                          (return . fmap fst . reads)) files


readS0Rec :: FilePath -> IO [S0Rec]
readS0Rec dir = do
  let todo = dir ++ "/" ++ todoDir
  let done = dir ++ "/" ++ doneDir

  todoRec <- readS0RecDir todo >>= (return . fmap (\x -> x { T.confirmed = False }))
  doneRec <- readS0RecDir done >>= (return . fmap (\x -> x { T.confirmed = True }))
  return $ doneRec ++ todoRec

incCode :: String -> String
incCode "" = "a"
incCode (x : xs) =
  if y > 'z' then 'a' : incCode xs else y : xs
  where y = chr $ ord x + 1

-- create a record in todo dir
addS0Rec' :: FilePath -> Text -> Text -> Text -> IO S0Rec
addS0Rec' dir name email ip = do
   t <- (round . (* 1000)) <$> getPOSIXTime
   -- NOTE: should cache, here just read files again
   codes <- readS0Rec dir >>= (return . map T.code)

   let code = if null codes then "aaa" else incCode $ last $ sort codes

   ridx <- randomRIO (0, 14)
   let value = [2,2,2,2,2,2,2,2
               ,4,4,4,4
               ,8,8
               ,16] !! ridx

   let r = S0Rec { T.name = name
                 , T.email = email
                 , T.ip = ip
                 , T.value = value
                 , T.code = code
                 , T.date = t
                 , T.confirmed = False }

   -- write to file
   writeFile (dir ++ "/" ++ todoDir ++ "/" ++ code) $ show r

   return r

addS0Rec :: FilePath -> Text -> Text -> Text -> IO (Bool, S0Rec)
addS0Rec dir name email ip = do
   list <- readS0Rec dir
   case filter (\f -> (T.name f == name) &&
                      (T.email f == email) &&
                      (T.ip f == ip)) list of
        r : _ -> return (False, r)
        []    -> addS0Rec' dir name email ip >>= (\x -> return (True, x))
