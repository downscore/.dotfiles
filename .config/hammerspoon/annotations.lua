-- Full-screen canvases keyed by screen ID.
local canvasByScreenId = {}

-- The start coordinates and screen ids for drawing some annotations.
local arrowStart = nil
local arrowScreenId = nil
local rectStart = nil
local rectScreenId = nil

-- Get or create a canvas for the screen the mouse is currently in.
local function getCanvasForCurrentScreen()
  local screen = hs.mouse.getCurrentScreen()
  if not screen then
    screen = hs.screen.mainScreen()
  end
  -- Throw an error if there is no screen.
  if not screen then
    error("No screen found")
  end
  local screenId = screen:id()
  local canvas = canvasByScreenId[screenId]
  if not canvas then
    canvas = hs.canvas.new(screen:fullFrame())
    canvasByScreenId[screenId] = canvas
  end
  return canvas
end

-- Clear all annotations on all screens.
function AnnotationsClearAll()
  for _, canvas in pairs(canvasByScreenId) do
    canvas:delete()
  end
  canvasByScreenId = {}
  arrowStart = nil
  arrowScreenId = nil
  rectStart = nil
  rectScreenId = nil
end

-- Draw a circle around the current mouse location.
function AnnotationsDrawCircle(radius)
  local canvas = getCanvasForCurrentScreen()
  local mousePos = hs.mouse.getRelativePosition()
  canvas:appendElements({
    type = "circle",
    action = "stroke",
    strokeColor = { red = 0, green = 0, blue = 0, alpha = 1 },
    strokeWidth = 9,
    radius = radius,
    center = { x = mousePos.x, y = mousePos.y },
  }, {
    type = "circle",
    action = "stroke",
    strokeColor = { red = 1, green = 0, blue = 0, alpha = 1 },
    strokeWidth = 5,
    radius = radius,
    center = { x = mousePos.x, y = mousePos.y },
  })
  canvas:show()
end

-- Draw a rectangle. Needs to be callled twice to draw the full rectangle. The first time, the mouse
-- coords are stored. On the second call, the rectangle is drawn from the stored coords to the
-- current mouse coords.
function AnnotationsDrawRectangle()
  local mousePos = hs.mouse.getRelativePosition()
  local screen = hs.mouse.getCurrentScreen()
  if not screen then
    screen = hs.screen.mainScreen()
  end
  if not rectStart or rectScreenId ~= screen:id() then
    rectStart = mousePos
    rectScreenId = screen:id()
    return
  end

  -- Get rect coordinates.
  local topLeft = { x = math.min(rectStart.x, mousePos.x), y = math.min(rectStart.y, mousePos.y) }
  local bottomRight =
    { x = math.max(rectStart.x, mousePos.x), y = math.max(rectStart.y, mousePos.y) }

  local canvas = getCanvasForCurrentScreen()
  canvas:appendElements({
    type = "rectangle",
    action = "stroke",
    strokeColor = { red = 0, green = 0, blue = 0, alpha = 1 },
    strokeWidth = 9,
    frame = {
      x = topLeft.x,
      y = topLeft.y,
      w = bottomRight.x - topLeft.x,
      h = bottomRight.y - topLeft.y,
    },
  }, {
    type = "rectangle",
    action = "stroke",
    strokeColor = { red = 1, green = 0, blue = 0, alpha = 1 },
    strokeWidth = 5,
    frame = {
      x = topLeft.x,
      y = topLeft.y,
      w = bottomRight.x - topLeft.x,
      h = bottomRight.y - topLeft.y,
    },
  })
  canvas:show()

  rectStart = nil
  rectScreenId = nil
end

-- Draw an arrow. Needs to be called twice to draw the full arrow. The first time, the mouse coords
-- are stored. On the second call, the arrow is drawn from the stored coords to the current mouse
-- coords.
function AnnotationsDrawArrow()
  local mousePos = hs.mouse.getRelativePosition()
  local screen = hs.mouse.getCurrentScreen()
  if not screen then
    screen = hs.screen.mainScreen()
  end
  if not arrowStart or arrowScreenId ~= screen:id() then
    arrowStart = mousePos
    arrowScreenId = screen:id()
    return
  end

  -- Compute coordinates for a triangular arrow head.
  local startX = arrowStart.x
  local startY = arrowStart.y
  local endX = mousePos.x
  local endY = mousePos.y
  local arrowHeadSize = 15
  local angle = math.atan2(endY - startY, endX - startX)
  local arrowPoint1 = { x = endX, y = endY }
  local arrowPoint2 = {
    x = endX - arrowHeadSize * math.cos(angle - math.pi / 6),
    y = endY - arrowHeadSize * math.sin(angle - math.pi / 6),
  }
  local arrowPoint3 = {
    x = endX - arrowHeadSize * math.cos(angle + math.pi / 6),
    y = endY - arrowHeadSize * math.sin(angle + math.pi / 6),
  }

  -- Append outline, then shape.
  local canvas = getCanvasForCurrentScreen()
  canvas:appendElements({
    type = "segments",
    action = "stroke",
    strokeColor = { red = 0, green = 0, blue = 0, alpha = 1 },
    strokeWidth = 12,
    coordinates = { arrowPoint1, arrowPoint2, arrowPoint3, arrowPoint1 },
  }, {
    type = "segments",
    action = "stroke",
    strokeColor = { red = 0, green = 0, blue = 0, alpha = 1 },
    strokeWidth = 9,
    coordinates = { arrowStart, mousePos },
  }, {
    type = "circle",
    action = "fill",
    fillColor = { red = 0, green = 0, blue = 0, alpha = 1 },
    radius = 6,
    center = { x = endX, y = endY },
  }, {
    type = "segments",
    action = "stroke",
    strokeColor = { red = 1, green = 0, blue = 0, alpha = 1 },
    strokeWidth = 8,
    coordinates = { arrowPoint1, arrowPoint2, arrowPoint3, arrowPoint1 },
  }, {
    type = "segments",
    action = "stroke",
    strokeColor = { red = 1, green = 0, blue = 0, alpha = 1 },
    strokeWidth = 5,
    coordinates = { arrowStart, mousePos },
  }, {
    type = "circle",
    action = "fill",
    fillColor = { red = 1, green = 0, blue = 0, alpha = 1 },
    radius = 4,
    center = { x = endX, y = endY },
  })
  canvas:show()

  arrowStart = nil
  arrowScreenId = nil
end
