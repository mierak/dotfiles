module PolybarHelpers where

import XMonad
import Data.List ( intercalate )
import XMonad.Hooks.StatusBar
import Data.Monoid
import qualified XMonad.StackSet as W

-- Hacky event hook to fix all EWMH workspaces showing on all screens.
-- Sets _NET_DESKTOP_VIEWPORT with monitor positions as defined.
-- middleMon rightMon and leftMon have to be manually changed to the correct screen geometry
middleMon   = intercalate ", " $ replicate 9 "1920, 0"
rightMon    = intercalate ", " $ replicate 9 "3840, 210"
leftMon     = intercalate ", " $ replicate 9 "0, 210"
viewportStr = intercalate ", " [middleMon, rightMon, leftMon]
setXpropCmd = "xprop -root -format _NET_DESKTOP_VIEWPORT 32c -set _NET_DESKTOP_VIEWPORT \"" ++ viewportStr ++ "\""
fixNetWmViewport :: Event -> X All
fixNetWmViewport _ = do
                     spawn setXpropCmd 
                     return $ All True

-- Spawns polybar for use with Easy SB. Possible options are: [left, middle, right]
createPolybar s = statusBarGeneric ("polybar " ++ show s) mempty

-- Logs the name of current layout on each screen to file for polybar to use
logScreenLayouts :: X ()
logScreenLayouts = do
                   winset <- gets windowset
                   let screens = W.screens $ winset
                   mapM_ logScreenLayout screens

logScreenLayout screen = do
                         let screenId = toInteger . W.screen $ screen
                         let layoutName  = description . W.layout . W.workspace $ screen
                         io $ writeFile ("/tmp/.xmonad-layout-" ++ show screenId) $ layoutName
                         spawn $ "polybar-msg action layout-" ++ show screenId ++ " hook 0 > /dev/null"

