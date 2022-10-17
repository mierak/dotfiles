module NamedActionsHelpers where

import XMonad
import XMonad.Util.NamedActions
import System.IO ( hPutStr, hClose )
import XMonad.Util.Run ( spawnPipe )
import Data.Char ( toUpper )
import XProp ( xProp )

foreground            = xProp "*foreground"
background            = xProp "*background"

subtitle' ::  String -> ((KeyMask, KeySym), NamedAction)
subtitle' x = ((0,0), NamedAction $ map toUpper $ sep ++ "\n-- " ++ x ++ " --\n" ++ sep)
              where
                  sep = replicate (6 + length x) '-'

showKeybindings :: [((KeyMask, KeySym), NamedAction)] -> NamedAction
showKeybindings x = addName "Show Keybindings" $ io $ do
                    h <- spawnPipe $ "yad --text-info --fontname=\"JetBrainsMono Nerd Font Mono 12\" --fore=" ++ foreground ++ " --back=" ++ background ++ " --center --geometry=1200x800 --title \"XMonad keybindings\""
                    hPutStr h (unlines $ showKmSimple x) -- showKmSimple doesn't add ">>" to subtitles
                    hClose h
                    return ()
