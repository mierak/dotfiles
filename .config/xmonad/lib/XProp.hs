module XProp where

import Data.Bifunctor (bimap)
import Data.Char as DC
import Data.List as DL
import Data.Maybe (catMaybes, fromMaybe)
import System.IO.Unsafe (unsafePerformIO)
import XMonad.Core (installSignalHandlers)
import XMonad.Util.Run (runProcessWithInput)

splitAtColon :: String -> Maybe (String, String)
splitAtColon str = splitAtTrimming str <$> DL.elemIndex ':' str
  where
    splitAtTrimming :: String -> Int -> (String, String)
    splitAtTrimming s idx = bimap trim (trim . tail) $ splitAt idx s
    trim :: String -> String
    trim = DL.dropWhileEnd DC.isSpace . DL.dropWhile DC.isSpace

getFromXres :: String -> IO String
getFromXres key = do
  installSignalHandlers
  fromMaybe "" . findValue key <$> runProcessWithInput "xrdb" ["-query"] ""
  where
    findValue :: String -> String -> Maybe String
    findValue xresKey xres =
      snd <$>
      DL.find ((== xresKey) . fst) (catMaybes $ splitAtColon <$> lines xres)

xProp :: String -> String
xProp = unsafePerformIO . getFromXres

