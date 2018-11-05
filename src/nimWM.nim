import xlib, x
converter toCint(x: TKeyCode): cint = x.cint
converter int32toCUint(x: int32): cuint = x.cuint
converter toTBool(x: bool): TBool = x.TBool
converter toBool(x: TBool): bool = x.bool

var
  attr: TXWindowAttributes
  start:TXButtonEvent
  ev:TXEvent

var display = XOpenDisplay(nil)
if display == nil:
  quit "Failed to open display"

discard XGrabKey(display, XKeysymToKeycode(display, XStringToKeysym("F1")), Mod1Mask,
  DefaultRootWindow(display), true, GrabModeAsync, GrabModeAsync)
discard XGrabButton(display, 1, Mod1Mask, DefaultRootWindow(display), true,
  ButtonPressMask, GrabModeAsync, GrabModeAsync, None, None)
discard XGrabButton(display, 3, Mod1Mask, DefaultRootWindow(display), true,
  ButtonPressMask, GrabModeAsync, GrabModeAsync, None, None)

start.subwindow = None

while true:
  discard XNextEvent(display,ev.addr)

  if ev.theType == KeyPress and ev.xkey.subwindow != None:
    discard XRaiseWindow(display, ev.xkey.subwindow);
  elif ev.theType == ButtonPress and ev.xkey.subwindow != None:
    discard XGetWindowAttributes(display, ev.xbutton.subwindow, attr.addr);
    start = ev.xbutton;
  elif ev.theType == MotionNotify and start.subwindow != None:
    var
       xdiff = ev.xbutton.x_root - start.x_root
       ydiff = ev.xbutton.y_root - start.y_root

    discard XMoveResizeWindow(display, start.subwindow,
      attr.x + (if start.button==1: xdiff else: 0),
      attr.y + (if start.button==1: ydiff else: 0),
      max(1, attr.width + (if start.button==3: xdiff else: 0)),
      max(1, attr.height + (if start.button==3: ydiff else: 0)))

  elif ev.theType == ButtonRelease:
    start.subwindow = None
