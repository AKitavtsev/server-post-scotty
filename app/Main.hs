module Main where

import Config
import Db
import qualified Controllers.Users
-- вроде base
-- import Control.Concurrent.STM
-- import Control.Monad.Reader
-- import Network.Wai.Middleware.RequestLogger
-- import System.Environment
import Data.Pool(Pool, createPool, withResource)
import Database.PostgreSQL.Simple
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
  pool <- createPool (newConn config) close 1 40 10
  scotty 3000 (routes pool)

routes pool = do
  Controllers.Users.routes pool
  -- Controllers.AccountResources.routes
  -- Controllers.Operations.routes


