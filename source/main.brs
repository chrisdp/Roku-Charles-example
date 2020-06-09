sub Main(inputArguments as object)
  screen = createObject("roSGScreen")
  m.port = createObject("roMessagePort")
  screen.setMessagePort(m.port)
  scene = screen.CreateScene("MainScene")
  screen.show()
  scene.observeField("appExit", m.port)
  scene.setFocus(true)

  while true
    msg = wait(0, m.port)
    msgType = type(msg)

    if msgType = "roSGScreenEvent" then
      if msg.isScreenClosed() then
        return
      else if msgType = "roSGNodeEvent" then
        field = msg.getField()
        if field = "appExit" then
          return
        end if
      end if
    end if
  end while
end sub
