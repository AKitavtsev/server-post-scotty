{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE QuasiQuotes #-}


module Migrations
    where

import Control.Monad (forM_, void, when)
import Data.FileEmbed
import Data.Function 
import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.Types   (Query (..))

-- import Migration
import Database.PostgreSQL.Simple
import Data.Pool
import qualified Data.ByteString as BS 

import qualified Data.List as L
import qualified Data.ByteString as BS


sortedMigrations :: [(FilePath, BS.ByteString)]
sortedMigrations =
  let unsorted = $(embedDir "sql")
  in L.sortBy (compare `on` fst) unsorted
  
runMigrations :: Pool Connection -> IO ()
runMigrations pool = do
    withResource pool $ \conn -> do
      forM_ sortedMigrations (executeMigration conn False) 
          
executeMigration :: Connection -> Bool -> (String, BS.ByteString) -> IO ()
executeMigration con verbose (name, contents)  = do
            void $ execute_ con (Query contents)
            when verbose $ putStrLn $ "Execute:\t" ++ name
            return () 

            
