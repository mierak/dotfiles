import XMonad
import System.Exit

import XMonad.Actions.OnScreen
import XMonad.Actions.UpdatePointer

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.WindowSwallowing

import XMonad.Layout.IndependentScreens
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.Spacing
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns

import XMonad.Util.ClickableWorkspaces
import XMonad.Util.EZConfig
import XMonad.Util.Font
import XMonad.Util.Loggers
import XMonad.Util.SpawnOnce
import XMonad.Util.WorkspaceCompare

import qualified XMonad.StackSet as W
import qualified Data.Map as M

import Data.Monoid
import Data.Maybe (maybeToList)
import Control.Monad ( join, when )
import Data.List ( intercalate )

import XProp ( xProp )

-- Colors
foreground            = xProp "*foreground"
background            = xProp "*background"
backgroundSecondary   = xProp "*backgroundsecondary"
active                = xProp "*borderselected"
inactive              = xProp "*borderinactive"

-- Rules
myManageHook = composeAll
             [ className =? "Gimp"                               --> doFloat
             , title     =? "Microsoft Teams Notification"       --> doFloat
             , className =? "discord"                            --> doShift "1_1"
             , className =? "Microsoft Teams - Preview"          --> doShift "2_2"
             , className =? "Steam" <&&> title =? "Friends List" --> insertPosition End Newer <+> doShift "1_1"
             ]

-- Startup Hook
myStartupHook :: X ()
myStartupHook = do
                windows $ greedyViewOnScreen 1 "1_1"
                windows $ greedyViewOnScreen 2 "2_1"
                windows $ greedyViewOnScreen 0 "0_1"
                windows $ W.view "0_1"
                spawnOnce "discord"
                spawnOnce "vivaldi-stable"

-- Gaps config
gap = 10
myLayoutHook = lessBorders Screen $ spacingRaw True (Border gap 0 gap 0) True (Border 0 gap 0 gap) True 
             $ myLayouts

-- Layouts config
myLayouts = tiled ||| tabs ||| Mirror tiled ||| noBorders Full ||| threeCol
    where
        tiled       = smartBorders $ Tall nmaster delta ratio
        threeCol    = smartBorders $ ThreeColMid nmaster delta ratio
        tabs        = tabbed shrinkText myTabTheme
        nmaster     = 1     -- Default number of windows in master
        ratio       = 1/2   -- Default proportion of master/stack
        delta       = 3/100 -- Percent of screen to increment by when resizing panes

myTabTheme = def 
             { decoHeight           = 16
             , activeColor          = backgroundSecondary
             , inactiveColor        = background
             , activeBorderColor    = active
             , inactiveBorderColor  = inactive
             }

-- Shift active window to workspace on current screen and switch to it
shiftAndView :: Int -> X ()
shiftAndView n = windows $ onCurrentScreen W.greedyView (workspaces' myConfig !! (n - 1))
                         . onCurrentScreen W.shift      (workspaces' myConfig !! (n - 1))

-- View workspace on current screen
viewWorkspace :: Int -> X ()
viewWorkspace n = windows $ onCurrentScreen W.greedyView (workspaces' myConfig !! (n - 1))

shiftScreenAndView i = W.view i . W.shift i

toggleFullscreenFloat w = windows $ \s -> if M.member w (W.floating s)
                                              then W.sink w s
                                              else (W.float w (W.RationalRect 0 0 1 1) s)

myKeys = 
    [ -- Core keybinds
      (("M-S-r"),        spawn "xmonad --restart")
    , (("M-C-r"),        spawn "xmonad --recompile")
    , (("M-f"),          withFocused toggleFullscreenFloat)
    , (("M-<Return>"),   spawn "st")
    , (("M-q"),          kill)
    , (("M-S-q"),        io (exitWith ExitSuccess))
      -- Focus
    , (("M-S-<Return>"), windows W.swapMaster)
      -- Workspace switching
    , (("M-1"),          viewWorkspace 1)
    , (("M-2"),          viewWorkspace 2)
    , (("M-3"),          viewWorkspace 3)
    , (("M-4"),          viewWorkspace 4)
    , (("M-5"),          viewWorkspace 5)
    , (("M-6"),          viewWorkspace 6)
    , (("M-7"),          viewWorkspace 7)
    , (("M-8"),          viewWorkspace 8)
    , (("M-9"),          viewWorkspace 9)
      -- Move window and switch to workspace
    , (("M-S-1"),        shiftAndView  1)
    , (("M-S-2"),        shiftAndView  2)
    , (("M-S-3"),        shiftAndView  3)
    , (("M-S-4"),        shiftAndView  4)
    , (("M-S-5"),        shiftAndView  5)
    , (("M-S-6"),        shiftAndView  6)
    , (("M-S-7"),        shiftAndView  7)
    , (("M-S-8"),        shiftAndView  8)
    , (("M-S-9"),        shiftAndView  9)
      -- Switch to screen
    , (("M-,"),          screenWorkspace 2 >>= flip whenJust (windows . W.view))
    , (("M-."),          screenWorkspace 0 >>= flip whenJust (windows . W.view))
    , (("M-/"),          screenWorkspace 1 >>= flip whenJust (windows . W.view))
      -- Move window to screen and switch
    , (("M-S-,"),        screenWorkspace 2 >>= flip whenJust (windows . shiftScreenAndView))
    , (("M-S-."),        screenWorkspace 0 >>= flip whenJust (windows . shiftScreenAndView))
    , (("M-S-/"),        screenWorkspace 1 >>= flip whenJust (windows . shiftScreenAndView))
    ]

-- Workspaces config
myWorkspaces = withScreens 3 ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

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

-- Swallowing
myHandleEventHook  = swallowEventHook (className =? "St") (return True) 
                  <> fixNetWmViewport

-- Spawns polybar for use with Easy SB. Possible options are: [left, middle, right]
createPolybar s = statusBarGeneric ("polybar " ++ show s) mempty

myConfig = def
    { terminal           = "st"
    , modMask            = mod4Mask
    , workspaces         = myWorkspaces
    , borderWidth        = 4
    , focusFollowsMouse  = True
    , clickJustFocuses   = False
      -- Hooks
    , layoutHook         = myLayoutHook
    , manageHook         = myManageHook
    , handleEventHook    = myHandleEventHook
    , logHook            = updatePointer (0.5, 0.5) (0, 0)
    , startupHook        = myStartupHook

      -- Borders
    , normalBorderColor  = inactive
    , focusedBorderColor = active
    } 
    `additionalKeysP` myKeys

-- Rename EWMH workspaces. Strip screen prefix
renameWs s _ = [last s]

main :: IO ()
main = do
     xmonad
     . ewmhFullscreen
     . ewmh
     . setEwmhActivateHook doAskUrgent
     . addEwmhWorkspaceRename (pure renameWs)
     -- . withEasySB (createXMobar 0 <> createXMobar 1 <> createXMobar 2) defToggleStrutsKey
     . withEasySB (createPolybar "left" <> createPolybar "middle" <> createPolybar "right") defToggleStrutsKey
     $ myConfig

-- XMobar config
{- Currently not needed as we are using polybar with EWMH
myXmobarPP screen = def
    { ppSep             = foreground " • "
    , ppTitleSanitize   = xmobarStrip
    , ppCurrent         = activeWsBorder . activeWsColor . pad
    , ppHidden          = foreground . pad
    , ppHiddenNoWindows = inactive . pad
    , ppVisible         = pad
    , ppUrgent          = urgentWsBorder . urgentWsColor . pad
    , ppOrder           = \(ws : _ : _ : extras) -> ws : extras
    , ppExtras          = [ logLayoutOnScreen screen
                          , logTitlesOnScreen screen formatFocused formatUnfocused
                          ]
    }
  where
    formatFocused   = wrap (white    "[") (white    "]") . foreground . ppWindow
    formatUnfocused = wrap (lowWhite "[") (lowWhite "]") . inactive   . ppWindow
    ppWindow        = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten 80
    activeWsBorder  = xmobarBorder "Full" "#363a4f" 4
    activeWsColor   = xmobarColor "#CAD3F5" "#363a4f"
    urgentWsBorder  = xmobarBorder "Full" "#ED8796" 4
    urgentWsColor   = xmobarColor "#24273A" "#ED8796"
    white           = xmobarColor "#f8f8f2" ""
    red             = xmobarColor "#ED8796" ""
    yellow          = xmobarColor "#f1fa8c" ""
    lowWhite        = xmobarColor "#bbbbbb" ""
    foreground      = xmobarColor "#CAD3F5" ""
    active          = xmobarColor "#B7BDF8" ""
    inactive        = xmobarColor "#6E738D" ""

marshallMyPP screen = clickablePP $ marshallPP screen $ myXmobarPP screen
createXMobar screen = do
                      statusBarPropTo ("XMONAD_LOG_" ++ show screen) ("xmobar -x " ++ show screen ++ " ~/.config/xmobar/xmobarrc" ++ show screen)
                      $ marshallMyPP (S screen)
-}
