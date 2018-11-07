import xlib, x
converter toCint(x: TKeyCode): cint = x.cint
converter int32toCUint(x: int32): cuint = x.cuint
converter toTBool(x: bool): TBool = x.TBool
converter toBool(x: TBool): bool = x.bool

type XWindowInfo = object
  display*: PDisplay
  attr*: TXWindowAttributes
  start*: TXButtonEvent
  ev*: TXEvent

proc initXWIndowInfo(winInfo: var XWindowInfo): XWIndowInfo =
  winInfo.display = XOpenDisplay(nil)
  if winInfo.display == nil:
    quit "Failed to open display"
  
  discard XGrabKey(winInfo.display, XKeysymToKeycode(winInfo.display, XStringToKeysym("F1")), Mod1Mask,
    DefaultRootWindow(winInfo.display), true, GrabModeAsync, GrabModeAsync)
  discard XGrabButton(winInfo.display, 1, Mod1Mask, DefaultRootWindow(winInfo.display), true,
    ButtonPressMask, GrabModeAsync, GrabModeAsync, None, None)
  discard XGrabButton(winInfo.display, 3, Mod1Mask, DefaultRootWindow(winInfo.display), true,
    ButtonPressMask, GrabModeAsync, GrabModeAsync, None, None)
  
  winInfo.start.subwindow = None

  return winInfo

when isMainModule:

  var winInfo: XWindowInfo
  
  winInfo = initXWIndowInfo(winInfo)

  while true:
    discard XNextEvent(winInfo.display, winInfo.ev.addr)
  
    if winInfo.ev.theType == KeyPress:
      var kev = cast[PXKeyEvent](winInfo.ev.addr)[]
      if not kev.subwindow.addr.isNil:
        discard XLowerWindow(winInfo.display, kev.subwindow)

    elif winInfo.ev.theType == ButtonPress:
      var bev = cast[PXButtonEvent](winInfo.ev.addr)[]
      if not bev.subwindow.addr.isNil:
        discard XGrabPointer(winInfo.display, bev.subwindow, true,
          PointerMotionMask or ButtonReleaseMask, GrabModeAsync,
          GrabModeAsync, None, None, CurrentTime)
        discard XGetWindowAttributes(winInfo.display, bev.subwindow, winInfo.attr.addr);
        winInfo.start = bev;
    elif winInfo.ev.theType == MotionNotify:
      var mnev = cast[PXMotionEvent](winInfo.ev.addr)[]
      var bev = cast[PXButtonEvent](winInfo.ev.addr)[]
      while XCheckTypedEvent(winInfo.display, MotionNotify, winInfo.ev.addr):
        continue
      var
        xdiff = bev.x_root - winInfo.start.x_root
        ydiff = bev.y_root - winInfo.start.y_root
      discard XMoveResizeWindow(winInfo.display, mnev.window,
        winInfo.attr.x + (if winInfo.start.button==1: xdiff else: 0),
        winInfo.attr.y + (if winInfo.start.button==1: ydiff else: 0),
        max(1, winInfo.attr.width + (if winInfo.start.button==3: xdiff else: 0)),
        max(1, winInfo.attr.height + (if winInfo.start.button==3: ydiff else: 0)))

    elif winInfo.ev.theType == ButtonRelease:
      discard XUngrabPointer(winInfo.display, CurrentTime)
    else:
      continue
