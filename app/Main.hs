module Main where

import Config
import Db
import Migrations

import qualified Controllers.Users
-- вроде base
-- import Control.Concurrent.STM
-- import Control.Monad.Reader
-- import Network.Wai.Middleware.RequestLogger
-- import System.Environment
import Data.Pool(Pool, createPool, withResource)
import Database.PostgreSQL.Simple
import Control.Monad (when)
import System.Environment
import Web.Scotty.Trans
import Web.Scotty


import qualified Data.Configurator as C
import qualified Data.Text as T


-- import Core

-- import qualified Controllers.Accounts
-- import qualified Controllers.AccountResources
-- import qualified Controllers.Operations
-- import qualified Persistence.Database as DB

-- start the server and load the routes from the controllers
main :: IO ()
main = do

  config <- getConfig
  
  conn <- newConn config
  pool <- createPool (newConn config) close 1 40 10
  
  mig <- getArgs
  when (mig == ["-m"]) $ do
    begin conn
    runMigrations pool
    commit  conn

  scotty 3000 (routes pool)

  
routes pool = do

  Controllers.Users.routes pool
  -- Controllers.AccountResources.routes
  -- Controllers.Operations.routes


