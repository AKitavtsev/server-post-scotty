{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE DeriveAnyClass    #-}
{-# LANGUAGE OverloadedStrings #-}

module Token
    where

-- import Db (fetch)

-- import Control.Monad.Trans
-- import Database.PostgreSQL.Simple
-- import Data.Pool (Pool)
-- import Network.HTTP.Types.Status

import Data.Aeson
import Data.Char (isDigit)
import Data.Hash.MD5
import Data.Time.Clock
import GHC.Generics
import Network.HTTP.Types.Status
import Web.Scotty


import qualified Data.Time as Time


data Token = Token {token :: String}  
             deriving (Eq, Show, Generic, FromJSON, ToJSON)

curTimeStr :: String -> IO String
curTimeStr form = do
    utc <- Time.getCurrentTime
    return (Time.formatTime Time.defaultTimeLocale form utc)
    
expirationTime :: IO String
expirationTime = do
    ct <- Time.getCurrentTime
    let et = addUTCTime  (86400 :: NominalDiffTime) ct
    return (Time.formatTime Time.defaultTimeLocale "%Y%m%d%H%M%S" et)

creatToken :: Maybe (Integer, Bool) -> String -> Maybe Token
creatToken (Just (id, adm))  time = 
    Just (Token (idAdmTime  ++ (md5s $ Str idAdmTime)))
    where admStr = if adm then  "1" else "0"
          idAdmTime = show id ++ "." ++ admStr ++ time
creatToken Nothing _ =  Nothing

idAdmFromToken :: String -> Maybe (Integer, Bool)
idAdmFromToken tok = case (takeWhile isDigit tok) of
                      [] -> Nothing
                      xs -> Just (read xs :: Integer, adm)
    where adm = case (dropWhile isDigit tok) of
                      ('.':'1':_) -> True
                      _           -> False
                      
timeFromToken :: String -> String
timeFromToken tok = case (dropWhile isDigit tok) of                      
                      ('.':_:xs) -> take 14 xs
                      _ -> []

testToken :: String -> String -> Either Status (Integer, Bool)
testToken tok ct = case (creatToken  iat tt) of 
                     Nothing -> Left (Status 401 "Bad token")
                     Just (Token tok') ->
                       if (not (tok == tok')) then Left (Status 402 "Bad token")
                       else if (tt < ct) then Left (Status 403 "Old token")
                            else Right iat'
   where tt  = timeFromToken tok
         iat  = idAdmFromToken tok
         iat' = iatFromMb $ idAdmFromToken tok
         iatFromMb (Just i) = i                 


