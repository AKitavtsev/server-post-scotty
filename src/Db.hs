{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module Db (newConn, fetch, execSqlT) where

import Config
-- import Domain

-- import Web.Scotty.Internal.Types (ActionT)
-- import GHC.Generics (Generic)
-- import Control.Monad.IO.Class
import Database.PostgreSQL.Simple
-- import Data.Pool(Pool, createPool, withResource)
-- import qualified Data.Text.Lazy as TL
-- import qualified Data.Text.Lazy.Encoding as TL
-- import qualified Data.ByteString.Lazy.Char8 as BL
-- import qualified Data.Text as T
import GHC.Int
import Data.Pool

-- DbConfig contains info needed to connect to MySQL server
-- data DbConfig = DbConfig {
     -- dbName :: String,
     -- dbUser :: String,
     -- dbPassword :: String
     -- }
     -- deriving (Show, Generic)

-- The function knows how to create new DB connection
-- It is needed to use with resource pool
newConn :: Config -> IO Connection
newConn conf = connect defaultConnectInfo
                       { connectUser = user conf
                       , connectPassword = password conf
                       , connectDatabase = name conf
                       }

--------------------------------------------------------------------------------
-- Utilities for interacting with the DB.
-- No transactions.
--
-- Accepts arguments
fetch :: (FromRow r, ToRow q) => Pool Connection -> q -> Query -> IO [r]
fetch pool args sql = withResource pool retrieve
      where retrieve conn = query conn sql args

-- No arguments -- just pure sql
-- fetchSimple :: FromRow r => Pool Connection -> Query -> IO [r]
-- fetchSimple pool sql = withResource pool retrieve
       -- where retrieve conn = query_ conn sql

-- Update database
-- execSql :: ToRow q => Pool Connection -> q -> Query -> IO Int64
-- execSql pool args sql = withResource pool ins
       -- where ins conn = execute conn sql args

-------------------------------------------------------------------------------
-- Utilities for interacting with the DB.
-- Transactions.
--
-- Accepts arguments
-- fetchT :: (FromRow r, ToRow q) => Pool Connection -> q -> Query -> IO [r]
-- fetchT pool args sql = withResource pool retrieve
      -- where retrieve conn = withTransaction conn $ query conn sql args

-- No arguments -- just pure sql
-- fetchSimpleT :: FromRow r => Pool Connection -> Query -> IO [r]
-- fetchSimpleT pool sql = withResource pool retrieve
       -- where retrieve conn = withTransaction conn $ query_ conn sql

-- Update database
execSqlT :: ToRow q => Pool Connection -> q -> Query -> IO Int64
execSqlT pool args sql = withResource pool ins
       where ins conn = withTransaction conn $ execute conn sql args

--------------------------------------------------------------------------------

-- findUserByLogin :: Pool Connection -> String -> IO (Maybe String)
-- findUserByLogin pool login = do
         -- res <- liftIO $ fetch pool (Only login) "SELECT * FROM users WHERE login=?" :: IO [(Integer, String, String)]
         -- return $ password res
         -- where password [(_, _, pwd)] = Just pwd
               -- password _ = Nothing

--------------------------------------------------------------------------------

-- listArticles :: Pool Connection -> IO [Article]
-- listArticles pool = do
     -- res <- fetchSimple pool "SELECT * FROM article ORDER BY id DESC" :: IO [(Integer, TL.Text, TL.Text)]
     -- return $ map (\(id, title, bodyText) -> Article id title bodyText) res
   
-- findArticle :: Pool Connection -> TL.Text -> IO (Maybe Article)
-- findArticle pool id = do
     -- res <- fetch pool (Only id) "SELECT * FROM article WHERE id=?" :: IO [(Integer, TL.Text, TL.Text)]
     -- return $ oneArticle res
     -- where oneArticle ((id, title, bodyText) : _) = Just $ Article id title bodyText
           -- oneArticle _ = Nothing


-- insertArticle :: Pool Connection -> Maybe Article -> ActionT TL.Text IO ()
-- insertArticle pool Nothing = return ()
-- insertArticle pool (Just (Article id title bodyText)) = do
     -- liftIO $ execSqlT pool [title, bodyText]
                            -- "INSERT INTO article(title, bodyText) VALUES(?,?)"
     -- return ()

-- updateArticle :: Pool Connection -> Maybe Article -> ActionT TL.Text IO ()
-- updateArticle pool Nothing = return ()
-- updateArticle pool (Just (Article id title bodyText)) = do
     -- liftIO $ execSqlT pool [title, bodyText, (TL.decodeUtf8 $ BL.pack $ show id)]
                            -- "UPDATE article SET title=?, bodyText=? WHERE id=?"
     -- return ()

-- deleteArticle :: Pool Connection -> TL.Text -> ActionT TL.Text IO ()
-- deleteArticle pool id = do
     -- liftIO $ execSqlT pool [id] "DELETE FROM article WHERE id=?"
     -- return ()
