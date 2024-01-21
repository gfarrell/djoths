{-# LANGUAGE CPP                 #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TupleSections #-}
import Test.Tasty.Bench
import Data.Functor.Identity  -- base >= 4.8
import qualified Data.ByteString as B
import Djot ( ParseOptions(..), parseDoc, renderHtml, renderDjot )
import Data.ByteString.Builder ( toLazyByteString )
import Text.DocLayout (render)
import System.Directory
import System.FilePath (takeExtension, (</>))
import qualified Data.ByteString.Lazy as BL

main :: IO ()
main = do
  fns <- filter ((== ".dj") . takeExtension) <$> listDirectory "benchmark"
  files <- mapM (\fn -> (fn,) <$> B.readFile ("benchmark" </> fn)) fns
  defaultMain $
   map (\(fn, bs) ->
     bench ("parse " <> fn) $ whnf (parseDoc ParseOptions{ optSourcePositions = False }) bs)
     files
   ++
   map (\(fn, bs) ->
     let doc = either error id $ parseDoc ParseOptions{ optSourcePositions = False } bs
     in bench ("renderHtml " <> fn) $ nf (BL.toStrict . toLazyByteString . renderHtml) doc)
     files
   ++
   map (\(fn, bs) ->
     let doc = either error id $ parseDoc ParseOptions{ optSourcePositions = False } bs
     in bench ("renderDjot " <> fn) $ nf (render (Just 72) . renderDjot) doc)
     files
