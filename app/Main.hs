{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE Strict #-}
module Main where

import Control.Monad
import qualified Data.ByteString as B
import Data.ByteString.Builder (hPutBuilder)
import Djot ( ParseOptions(..), RenderOptions(..),
              parseDoc, renderHtml, renderDjot )
import System.Environment (getArgs)
import System.IO (stderr, stdout, hPutStrLn)
import System.Exit ( ExitCode(ExitFailure, ExitSuccess), exitWith )
import Text.DocLayout (render)
import qualified Data.Text.IO as TIO

data OutputFormat = Html | Djot | Ast

data Opts =
      Opts{ format :: OutputFormat
          , files :: [FilePath] }

parseOpts :: [String] -> IO Opts
parseOpts = foldM go Opts{ format = Html, files = [] }
 where
   go opts "--djot" = pure $ opts{ format = Djot }
   go opts "--ast" = pure $ opts{ format = Ast }
   go opts "--html" = pure $ opts{ format = Html }
   go _opts ('-':xs) = do
     hPutStrLn stderr $ "Unknown option " <> ('-':xs)
     exitWith $ ExitFailure 1
   go opts f = pure $ opts{ files = files opts ++ [f] }

main :: IO ()
main = do
  opts <- getArgs >>= parseOpts
  bs <- case files opts of
          [] -> B.getContents
          fs  -> mconcat <$> mapM B.readFile fs
  let popts = ParseOptions
  let ropts = RenderOptions { preserveSoftBreaks = True }
  case parseDoc popts bs of
    Right doc -> do
      case format opts of
        Html -> hPutBuilder stdout $ renderHtml ropts doc
        Djot -> TIO.putStr $ render Nothing (renderDjot ropts doc)
        Ast -> print doc
      exitWith ExitSuccess
    Left e -> do
      hPutStrLn stderr e
      exitWith $ ExitFailure 1
