import XMonad
import System.Exit

import XMonad.Actions.OnScreen
import XMonad.Actions.UpdatePointer

-- import XMonad.Hooks.DynamicLog
import XMonad.Hooks.DynamicProperty
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.WindowSwallowing

import XMonad.Layout.Dwindle as Dwindle
import XMonad.Layout.IndependentScreens
import XMonad.Layout.MouseResizableTile
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Renamed
import XMonad.Layout.Spacing
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns

import XMonad.Util.Cursor
import XMonad.Util.ClickableWorkspaces
import XMonad.Util.EZConfig
import XMonad.Util.Font
import XMonad.Util.Loggers
import XMonad.Util.NamedActions
import XMonad.Util.SpawnOnce
import XMonad.Util.WorkspaceCompare

import qualified XMonad.StackSet as W
import qualified Data.Map as M

import Data.Maybe (maybeToList, fromMaybe)
import Control.Monad ( join, when )

import XProp ( xProp )
import NamedActionsHelpers ( subtitle', showKeybindings )
import PolybarHelpers ( fixNetWmViewport, createPolybar, logScreenLayouts )

-- Vars
myTerminal :: String
myTerminal = "st"

-- Colors
foreground            = xProp "*foreground"
background            = xProp "*background"
backgroundSecondary   = xProp "*backgroundsecondary"
active                = xProp "*borderselected"
inactive              = xProp "*borderinactive"

-- Window Rules
myManageHook = composeAll
             [ className =? "Gimp"                                       --> doFloat
             , className =? "Xmessage"                                   --> doCenterRectFloat
             , className =? "Yad"                                        --> doCenterRectFloat
             , title     =? "Microsoft Teams Notification"               --> doFloat
             , className =? "Microsoft Teams - Preview"                  --> doShift "2_2"
             , className =? "discord"                                    --> insertPosition Master Newer <+> doShift "1_1"
             , className =? "Steam" <&&> title =? "Friends List"         --> insertPosition End    Newer <+> doShift "1_1"
             , className =? "Steam" <&&> title =? "Steam - Self Updater" --> doFloat <+> doShift "1_1"
             ]
             where
                  doCenterRectFloat = doRectFloat (W.RationalRect (1 / 4) (1 / 4) (1 / 2) (1 / 2))

-- Do on Startup
myStartupHook :: X ()
myStartupHook = do
                logScreenLayouts
                windows $ greedyViewOnScreen 1 "1_1"
                windows $ greedyViewOnScreen 2 "2_1"
                windows $ greedyViewOnScreen 0 "0_1"
                windows $ W.view "0_1"
                spawn     "xsetroot -cursor_name left_ptr"
                spawn     "xmodmap -e 'add mod4 = Menu'"
                spawnOnce "discord"
                spawnOnce "vivaldi-stable"

-- Layouts config
myLayoutHook = lessBorders Screen
             $ onWorkspace "1_1" (bigMasterStack ||| secondaryLayouts)
             $ masterStack ||| secondaryLayouts
             where
                 secondaryLayouts   = dwindle ||| tabs ||| bottomStack ||| monocle ||| centeredMaster 
                 masterStack        = renamed [Replace "[]="] $ spacing                $ mouseResizableTile { draggerType = FixedDragger 0 20, slaveFrac = ratio, nmaster = nmaster, masterFrac = ratio, fracIncrement = delta }
                 bottomStack        = renamed [Replace "TTT"] $ spacing                $ mouseResizableTile { draggerType = FixedDragger 0 20, slaveFrac = ratio, nmaster = nmaster, masterFrac = ratio, fracIncrement = delta, isMirrored = True }
                 bigMasterStack     = renamed [Replace "[]|"] $ spacing $ smartBorders $ mouseResizableTile { draggerType = FixedDragger 0 20, slaveFrac = ratio, nmaster = nmaster, masterFrac = 0.8, fracIncrement = delta }
                 dwindle            = renamed [Replace "[@]"] $ spacing $ smartBorders $ Dwindle R Dwindle.CW 1 1.1
                 centeredMaster     = renamed [Replace "|M|"] $ spacing $ smartBorders $ ThreeColMid nmaster delta ratio
                 tabs               = renamed [Replace "[T]"]                          $ tabbed shrinkText myTabTheme
                 monocle            = renamed [Replace "[M]"]           $ noBorders    $ Full
                 spacing            = spacingRaw True (Border gap 0 gap 0) True (Border 0 gap 0 gap) True
                 gap                = 10    -- Default gap size between windows
                 nmaster            = 1     -- Default number of windows in master
                 ratio              = 1/2   -- Default proportion of master/stack
                 delta              = 3/100 -- Percent of screen to increment by when resizing panes

myTabTheme = def 
             { decoHeight           = 16
             , activeColor          = backgroundSecondary
             , inactiveColor        = background
             , activeBorderColor    = active
             , inactiveBorderColor  = inactive
             }

-- Shift active window to workspace on current screen and switch to it
shiftAndView :: Int -> X ()
shiftAndView n = do
                 windows $ onCurrentScreen W.greedyView (workspaces' myConfig !! (n - 1))
                         . onCurrentScreen W.shift      (workspaces' myConfig !! (n - 1))
                 logScreenLayouts

-- View workspace on current screen
viewWorkspace :: Int -> X ()
viewWorkspace n = do 
                  windows $ onCurrentScreen W.greedyView (workspaces' myConfig !! (n - 1))
                  logScreenLayouts

shiftScreenAndView i = W.view i . W.shift i

toggleFullscreenFloat :: Window ->  X ()
toggleFullscreenFloat w = windows $ \s -> if M.member w (W.floating s)
                                              then W.sink w s
                                              else (W.float w (W.RationalRect 0 0 1 1) s)

nextLayout :: X ()
nextLayout = do
             sendMessage NextLayout
             logScreenLayouts


myKeys :: XConfig l0 -> [((KeyMask, KeySym), NamedAction)]
myKeys c =
    let subKeys str ks = subtitle' str : mkNamedKeymap c ks in
    subKeys "Core"
    [ ("M-S-q",        addName "Quit XMonad"                     $ io (exitWith ExitSuccess))
    , ("M-S-r",        addName "Restart XMonad"                  $ spawn "xmonad --restart")
    , ("M-C-r",        addName "Recompile XMonad"                $ spawn "xmonad --recompile")
    , ("M-<Return>",   addName "Spawn Terminal"                  $ spawn myTerminal)
    , ("M-q",          addName "Kill Focused Window"             $ kill)
    ]
    ^++^ subKeys "Focus"
    [ ("M-S-<Return>", addName "Swap Active Window to Master"    $ windows W.swapMaster)
    , ("M-j",          addName "Focus Down"                      $ windows W.focusDown)
    , ("M-k",          addName "Focus Up"                        $ windows W.focusUp)
    , ("M-S-j",        addName "Swap Down"                       $ windows W.swapDown)
    , ("M-S-k",        addName "Swap Up"                         $ windows W.swapUp)
    ]
    ^++^ subKeys "Layout"
    [ ("M-<Space>",    addName "Next Layout"                     $ nextLayout)
    , ("M-f",          addName "Fullscreen Active Window"        $ withFocused toggleFullscreenFloat)
    , ("M-l",          addName "Expand Master Area"              $ sendMessage Expand)
    , ("M-h",          addName "Shrink Master Area"              $ sendMessage Shrink)
    , ("M-S-o",        addName "Decrease Spacing"                $ decScreenWindowSpacing 2)
    , ("M-S-p",        addName "Increase Spacing"                $ incScreenWindowSpacing 2)
    , ("M-t",          addName "Sink Floating Window to Tiled"   $ withFocused $ windows . W.sink)
    ]
    ^++^ subKeys "Workspace Switching"
    [ ("M-1",          addName "Switch to Workspace 1"            $ viewWorkspace 1)
    , ("M-2",          addName "Switch to Workspace 2"            $ viewWorkspace 2)
    , ("M-3",          addName "Switch to Workspace 3"            $ viewWorkspace 3)
    , ("M-4",          addName "Switch to Workspace 4"            $ viewWorkspace 4)
    , ("M-5",          addName "Switch to Workspace 5"            $ viewWorkspace 5)
    , ("M-6",          addName "Switch to Workspace 6"            $ viewWorkspace 6)
    , ("M-7",          addName "Switch to Workspace 7"            $ viewWorkspace 7)
    , ("M-8",          addName "Switch to Workspace 8"            $ viewWorkspace 8)
    , ("M-9",          addName "Switch to Workspace 9"            $ viewWorkspace 9)
    ]
    ^++^ subKeys "Move and Switch to Workspace"
    [ ("M-S-1",        addName "Move and Switch To Workspace 1"   $ shiftAndView  1)
    , ("M-S-2",        addName "Move and Switch To Workspace 2"   $ shiftAndView  2)
    , ("M-S-3",        addName "Move and Switch To Workspace 3"   $ shiftAndView  3)
    , ("M-S-4",        addName "Move and Switch To Workspace 4"   $ shiftAndView  4)
    , ("M-S-5",        addName "Move and Switch To Workspace 5"   $ shiftAndView  5)
    , ("M-S-6",        addName "Move and Switch To Workspace 6"   $ shiftAndView  6)
    , ("M-S-7",        addName "Move and Switch To Workspace 7"   $ shiftAndView  7)
    , ("M-S-8",        addName "Move and Switch To Workspace 8"   $ shiftAndView  8)
    , ("M-S-9",        addName "Move and Switch To Workspace 9"   $ shiftAndView  9)
    ]
    ^++^ subKeys "Switch to Screen"
    [ ("M-,",          addName "Switch to Left Screen"            $ screenWorkspace 2 >>= flip whenJust (windows . W.view))
    , ("M-.",          addName "Switch to Middle Screen"          $ screenWorkspace 0 >>= flip whenJust (windows . W.view))
    , ("M-/",          addName "Switch to Right Screen "          $ screenWorkspace 1 >>= flip whenJust (windows . W.view))
    ]
    ^++^ subKeys "Move Window to Screen and Focus"
    [
      ("M-S-,",        addName "Move and Switch to Left Screen"   $ screenWorkspace 2 >>= flip whenJust (windows . shiftScreenAndView))
    , ("M-S-.",        addName "Move and Switch to Middle Screen" $ screenWorkspace 0 >>= flip whenJust (windows . shiftScreenAndView))
    , ("M-S-/",        addName "Move and Switch to Right Screen"  $ screenWorkspace 1 >>= flip whenJust (windows . shiftScreenAndView))
    ]

-- Workspaces config
myWorkspaces = withScreens 3 ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

-- Swallowing
myHandleEventHook  = swallowEventHook (className =? "St" <||> className =? "Alacritty") (return True)
                 <+> fixNetWmViewport
                 <+> dynamicTitle (title ~? "Vivaldi Settings"    --> doCenterRectFloat)
                 where
                      doCenterRectFloat = doRectFloat (W.RationalRect (1 / 4) (1 / 6) (1 / 2) (2 / 3))


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
     . addDescrKeys' ((mod4Mask, xK_F1), showKeybindings) myKeys
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
