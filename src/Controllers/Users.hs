{-# LANGUAGE DeriveGeneric, OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

module Controllers.Users 
    where

import Control.Monad (when)
import Control.Monad.Trans
import Data.Aeson (eitherDecode )
import Database.PostgreSQL.Simple
import Data.Hash.MD5
import Data.Pool (Pool)
import qualified Data.Text.Lazy as TL
-- import Data.UUID
-- import Data.UUID.V4
import GHC.Generics
import Network.HTTP.Types
import Web.Scotty
-- import Web.Scotty.Trans
import Web.Scotty.Internal.Types

-- import Core
-- import Persistence.Accounts
import Config
import Models.User
import Db
import Token
-- import Serializers.Account
-- import Serializers.Response

routes :: Pool Connection -> ScottyM ()
routes pool = do
  post "/user" $ do
    b <- body
    let parsedBody = eitherDecode b :: Either String UserIn

    -- fail with 400 if the request body is not correct
    case parsedBody of
      Left e -> do
        status badRequest400
        json ()
      Right correctlyParsedBody -> do
        exL <- liftIO $ existLogin pool (login correctlyParsedBody)
        case exL of
          False -> do
            insertUser pool correctlyParsedBody        
            idAdm <- liftIO $ findUserByLogin pool 
                     (login correctlyParsedBody) 
                     (Models.User.password correctlyParsedBody)
            timeStr <- liftIO expirationTime
            let tokenMb =  creatToken idAdm timeStr 
            token <- createdToken tokenMb        
            return token
          True -> do
            status (Status 405 "Login exist")
            json ()
        
        -- json $ Success $ AccountSerializer account

  get "/user/:token" $ do
    token   <- param "token" :: ActionM String
    curtime <- liftIO $ curTimeStr "%Y%m%d%H%M%S"
    case  (testToken token curtime) of
      Left st -> do
        status st
        json ()
      Right id -> do
        status (Status 200 "OK")
        userMb <- liftIO $ findUserByID pool id
        user <- createdUser userMb     
        return user
        
  get "/token" $ do
    login    <- param "login" :: ActionM String
    password <- param "password" :: ActionM String
    idAdm    <- liftIO $ findUserByLogin pool login password
    timeStr <- liftIO expirationTime    
    let tokenMb =  creatToken idAdm timeStr
    when  (tokenMb == Nothing)  $ do
       status (Status 405 "Password wrong")    
    token <- createdToken tokenMb        
    return token   
        

    
              -- get    "/articles/:id" $ do id <- param "id" :: ActionM TL.Text -- get the article id from the request
                                          -- maybeArticle <- liftIO $ findArticle pool id -- get the article from the DB
                                          -- viewArticle maybeArticle            -- show the article if it was found

    -- if not UUID, it's not an account ID, so 404
    -- let maybeUuid = fromString accId
    -- case maybeUuid of
      -- Nothing -> accountNotFound
      -- Just accUuid -> do

        -- returns the account if it exists
        -- maybeAccount <- fetchDb $ getAccount accUuid

        -- case maybeAccount of
          -- Nothing -> accountNotFound
          -- Just acc -> json $ Success $ AccountSerializer acc

-- Cory type AppActionM = ActionT Text (ReaderT (TVar DB.Database) IO)
-- scotty newtype ActionT e m a
-- accountNotFound :: AppActionM ()
-- accountNotFound = do
-- scotty status :: Status -> ActionM ()
  -- status notFound404
  -- json $ Error "Account not found"
 
insertUser :: Pool Connection -> UserIn -> ActionT TL.Text IO ()
insertUser pool (UserIn name surname avatar login password) = do
     c_date <- liftIO $ curTimeStr "%Y-%m-%d %H:%M:%S"
     liftIO $ execSqlT pool [name, surname, avatar, login, (md5s $ Str password), c_date, "FALSE"]
              "INSERT INTO users (name, surname, avatar, login, password, c_date, admin) VALUES(?,?,?,?,?,?,?)"
     return ()

existLogin :: Pool Connection -> String -> IO Bool
existLogin pool login = do
    res <- liftIO $ fetch pool (Only login) 
           "SELECT user_id, password FROM users WHERE login=?" :: IO [(Integer, String)]
    return $ pass res
         where pass [(id, passw)] = True
               pass _ = False 

findUserByLogin :: Pool Connection -> String -> String -> IO (Maybe (Integer, Bool))
findUserByLogin pool login password = do
         res <- liftIO $ fetch pool (Only login) 
                "SELECT user_id, password, admin  FROM users WHERE login=?" ::
                IO [(Integer, String, Bool)]
         return $ pass res
         where 
           pass [(id, passw, adm)] = if passw == (md5s $ Str password) then Just (id, adm)
                                     else Nothing
           pass _ = Nothing 

findUserByID :: Pool Connection -> Integer -> IO (Maybe UserOut)
findUserByID pool id = do
         res <- liftIO $ fetch pool (Only id) 
                "SELECT user_id, name, surname, avatar, login, c_date::varchar, admin  FROM users WHERE user_id=?" ::
                IO [(Integer, String, String, String, String, String, Bool)]
         return $ pass res
         where pass [(id, n, sn, av, log, dat, adm)] = Just (UserOut id n sn av log dat adm)
               pass _ = Nothing 
                              
createdToken :: Maybe Token -> ActionM ()
createdToken Nothing = json ()
createdToken (Just token) = json token

createdUser :: Maybe UserOut -> ActionM ()
createdUser Nothing = json ()
createdUser (Just user) = json user

