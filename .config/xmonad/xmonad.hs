import XMonad
import System.Exit

import XMonad.Actions.OnScreen
import XMonad.Actions.UpdatePointer

import XMonad.Hooks.DynamicProperty
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.StatusBar
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.WindowSwallowing

import XMonad.Layout.Dwindle as Dwindle
import XMonad.Layout.Grid
import XMonad.Layout.IndependentScreens
import XMonad.Layout.MouseResizableTile
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Renamed
import XMonad.Layout.Spacing
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns

import XMonad.Util.EZConfig
import XMonad.Util.NamedActions
import XMonad.Util.NamedScratchpad
import XMonad.Util.SpawnOnce
import XMonad.Util.WorkspaceCompare ( filterOutWs )

import qualified XMonad.StackSet as W
import qualified Data.Map as M

import XProp ( xProp )
import NamedActionsHelpers ( subtitle', showKeybindings )
import PolybarHelpers ( fixNetWmViewport, createPolybar, logScreenLayouts )

-- Quick Config
myTerminal :: String
myTerminal = "alacritty"

spawnOnceOnStart :: [String]
spawnOnceOnStart =  [ "discord"
                    , "vivaldi-stable"
                    ]

spawnOnStart :: [String]
spawnOnStart =  [ "xsetroot -cursor_name left_ptr"
                , "xmodmap -e 'add mod4 = Menu'"
                ]

-- XResources Colors
foreground            = xProp "*foreground"
background            = xProp "*background"
backgroundSecondary   = xProp "*background-alt"
active                = xProp "*active"
inactive              = xProp "*inactive"

-- Scratchpad Config
myScratchpads = [ createNS "scratch-term" ""
                ]
                where
                     spawnTerm cls        = myTerminal ++ " --class " ++ cls
                     spawnTermCmd cls cmd = myTerminal ++ " --class " ++ cls ++ " -e " ++ cmd
                     createNS name cmd    = case cmd of
                                                [] -> NS name (spawnTerm name)        (className =? name) defaultFloating
                                                _  -> NS name (spawnTermCmd name cmd) (className =? name) defaultFloating

-- Window Rules
myManageHook = composeOne 
             [ transience
             , className =? "Yad" <&&> title  =? "Calendar"              -?> doFocus <+> doFloatAt 0.87 0.025
             , className =? "Yad"                                        -?> doCenterRectFloat
             , title     =? "Microsoft Teams Notification"               -?> doFloat
             , className =? "Microsoft Teams - Preview"                  -?> doShift "2_2"
             , className =? "Steam" <&&> title =? "Friends List"         -?> insertPosition End    Newer <+> doShift "1_1"
             , className =? "Steam" <&&> title ^? "Steam"                -?> doShift "0_5"
             , className =? "discord"                                    -?> insertPosition Master Newer <+> doShift "1_1"
             , className =? "Vampire_Survivors"                          -?> doFullFloat
             ]
             <+> composeAll
             [ className =? "Gimp"                                       --> doFloat
             , className =? "Xmessage"                                   --> doCenterRectFloat
             ]
             <+> namedScratchpadManageHook myScratchpads
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
                mapM_ spawn     spawnOnStart
                mapM_ spawnOnce spawnOnceOnStart

-- Layouts config
myLayoutHook = lessBorders Screen
             $ onWorkspace "1_1" (bigMasterStack ||| secondaryLayouts)
             $ masterStack ||| secondaryLayouts
             where
                 secondaryLayouts   = grid ||| dwindle ||| tabs ||| bottomStack ||| monocle ||| centeredMaster 
                 masterStack        = renamed [Replace "[]="] $ spacing                $ mouseResizableTile { draggerType = FixedDragger 0 20, slaveFrac = ratio, nmaster = nmaster, masterFrac = ratio, fracIncrement = delta }
                 bottomStack        = renamed [Replace "TTT"] $ spacing                $ mouseResizableTile { draggerType = FixedDragger 0 20, slaveFrac = ratio, nmaster = nmaster, masterFrac = ratio, fracIncrement = delta, isMirrored = True }
                 bigMasterStack     = renamed [Replace "[]|"] $ spacing $ smartBorders $ mouseResizableTile { draggerType = FixedDragger 0 20, slaveFrac = ratio, nmaster = nmaster, masterFrac = 0.8, fracIncrement = delta }
                 dwindle            = renamed [Replace "[@]"] $ spacing $ smartBorders $ Dwindle R Dwindle.CW 1 1.1
                 centeredMaster     = renamed [Replace "|M|"] $ spacing $ smartBorders $ ThreeColMid nmaster delta ratio
                 tabs               = renamed [Replace "[T]"]                          $ tabbed shrinkText myTabTheme
                 monocle            = renamed [Replace "[M]"]           $ noBorders    $ Full
                 grid               = renamed [Replace "HHH"] $ spacing $ smartBorders $ Grid
                 spacing            = spacingRaw False (Border gap 0 gap 0) True (Border 0 gap 0 gap) True
                 gap                = 20    -- Default gap size between windows
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

toggleFloat :: Window -> X ()
toggleFloat w = windows $ \s -> if M.member w $ W.floating s
                                    then W.sink w s
                                    else (W.float w (W.RationalRect (1 / 6) (1 / 6) (2 / 3) (2 / 3)) s)

nextLayout :: X ()
nextLayout = do
             sendMessage NextLayout
             logScreenLayouts

toggleAllSpacing :: X ()
toggleAllSpacing = do
                   toggleSmartSpacing
                   toggleWindowSpacingEnabled
                   toggleScreenSpacingEnabled

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
    , ("M-p",          addName "Toggle Spacing"                  $ toggleAllSpacing)
    , ("M-t",          addName "Toggle Floating"                 $ withFocused toggleFloat)
    , ("M-b",          addName "Toggle Statusbar"                $ sendMessage ToggleStruts)
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
    ^++^ subKeys "Workspace Switching"
    [ (key, func) | n <- [1..9]
                  , let name = "Switch to Workspace " ++ show n
                  , let key  = "M-" ++ show n
                  , let func = addName name $ viewWorkspace n
    ]
    ^++^ subKeys "Move and Switch to Workspace"
    [ (key, func) | n <- [1..9]
                  , let name = "Move and Switch To Workspace " ++ show n
                  , let key  = "M-S-" ++ show n
                  , let func = addName name $ shiftAndView n
    ]
    ^++^ subKeys "Scratchpads" (
    [ ("M-<F1>",       addName "Toggle Terminal Scratchpad"       $ namedScratchpadAction myScratchpads "scratch-term")
    , ("M-0",          addName "Switch to Scratchpad Workspace"   $ windows $ W.view scratchpadWorkspaceTag)
    ] ++
    [ (key, func) | n <- [1..4]
                  , (mod, fn, prefix) <- [ ("S-<F", \s -> withFocused $ toggleDynamicNSP s, "Create")
                                         , ("<F"  , \s -> dynamicNSPAction s              , "Toggle")]
                  , let name = prefix ++ " Dynamic Scratchpad " ++ show n
                  , let key  = "M-s " ++ mod ++ show n ++ ">"
                  , let func = addName name $ fn ("dyn-scratchpad-" ++ show n)
    ])

-- Workspaces config
myWorkspaces = withScreens 3 ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

-- Swallowing
myHandleEventHook  = swallowEventHook (className =? "St" <||> className =? "Alacritty") (return True)
                 <+> fixNetWmViewport
                 <+> dynamicTitle (title ~? "Vivaldi Settings"    --> doCenterRectFloat)
                 where
                      doCenterRectFloat = doRectFloat (W.RationalRect (1 / 4) (1 / 6) (1 / 2) (2 / 3))


myConfig = def
         { terminal           = myTerminal
         , modMask            = mod4Mask
         , workspaces         = myWorkspaces
         , borderWidth        = 3
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

main :: IO ()
main = do
     xmonad
     . ewmhFullscreen
     . ewmh
     . setEwmhActivateHook doAskUrgent
     . addEwmhWorkspaceRename (pure $ \s _ -> [last s])
     . addEwmhWorkspaceSort (pure $ filterOutWs [scratchpadWorkspaceTag])
     . addDescrKeys' ((mod4Mask, xK_F12), showKeybindings) myKeys
     . withEasySB (createPolybar "left" <> createPolybar "middle" <> createPolybar "right") defToggleStrutsKey
     $ myConfig
