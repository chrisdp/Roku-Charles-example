sub init()
  m.imagePoster = m.top.findNode("imagePoster")
  m.itemCursor = m.top.findNode("itemCursor")
  m.labelGroup = m.top.findNode("labelGroup")
  m.titleLabel = m.top.findNode("titleLabel")
  m.descriptionLabel = m.top.findNode("descriptionLabel")
  m.maxWidth = 1880
  m.top.maxLabelWidth = m.maxWidth
end sub

sub onItemContentChange()
  m.itemContent = m.top.itemContent
  m.titleLabel.text = m.itemContent.title
  m.descriptionLabel.text = m.itemContent.description

  image = m.top.itemContent.SDPOSTERURL
  if image = "" then
    m.imagePoster.visible = false
    m.labelGroup.translation = [0, 0]
    m.maxLabelWidth = m.maxLabelWidth
  else
    m.imagePoster.uri = m.top.itemContent.SDPOSTERURL + "?width=" + m.imagePoster.width.toStr() + "&crop=smart&auto=webp"
    m.imagePoster.visible = true
    m.labelGroup.translation = [m.imagePoster.width + 20, 0]
    m.top.maxLabelWidth = m.maxWidth - (m.imagePoster.width + 20 + 40)
  end if
end sub

sub onFocusPercentChange()
  m.itemCursor.opacity = m.top.focusPercent
end sub
