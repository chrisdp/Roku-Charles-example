#const PROXY = true

sub init()
  m.top.functionName = "fetch"
end sub

sub fetch()
  timeSpan = createObject("roTimeSpan")
  listContent = createObject("roSGNode", "ContentNode")

  ' NOTE: The key to this approach is to always run your requests though the urlProxy function
  url = urlProxy("https://www.reddit.com" + m.top.subReddit + "/.json")
  print "Formatted Url:", url

  request = createObject("roUrlTransfer")
  request.setCertificatesFile("common:/certs/ca-bundle.crt")
  request.initClientCertificates()
  request.setUrl(url)
  response = request.getToString()
  json = parseJson(response)

  createRowItems(json, listContent)
  m.top.content = listContent
  print "Task took: " + timeSpan.TotalMilliseconds().ToStr()
end sub

sub createRowItems(json as object, listContent as object)
  for each postDataContainer in json.data.children
    postData = postDataContainer.data
    post = {
      title: postData.title,
      selfText: postData.selfText,
      thumbnail: postData.thumbnail,
      isVideo: postData.is_video,
      url: postData.url,
      isSelf: postData.isSelf
    }

    if post.isVideo then
      itemContent = listContent.createChild("ContentNode")
      itemContent.update({ isSelf: post.isSelf }, true)
      itemContent.title = post.title
      itemContent.description = post.selfText
      itemContent.url = post.url

      if post.thumbnail <> "self" and post.thumbnail <> "default" and post.thumbnail <> "image" then
        itemContent.SDPosterUrl = post.thumbnail
      end if

      if post.isVideo then
        itemContent.url = post.url + "/DASHPlaylist.mpd"
        itemContent.streamformat = "dash"
      end if

      if postData.media <> invalid and postData.media.type = "youtube.com" then
        itemContent.videoUrl = postData.url
        itemContent.streamFormat = "youtube"
      end if

      extension = right(postData.url, 4)
      if extension = ".png" or extension = ".jpg" then
        itemContent.SDPosterUrl = postData.url
      end if

      itemContent.update({
        isRedditVideo: (postData.media <> invalid and postData.media.reddit_video <> invalid)
      }, true)
    end if
  end for
end sub

function urlProxy(url as string) as string
  #if PROXY
    if left(url, 4) <> "http" then return url
    ' This address is <HOST_RUNNING_CHARLES>:<CHARLES_PORT>
    proxyAddress = "192.168.8.185:8888"

    ' Make sure we have not already formatted this url
    ' This can lead to a recursive address
    if not url.inStr(proxyAddress) > -1 then
      if url <> invalid and proxyAddress <> invalid
        proxyPrefix = "http://" + proxyAddress + "/;"
        currentUrl = url

        ' Double check again. You really don't want a recursive address
        if currentUrl.inStr(proxyPrefix) = 0 then
          return url
        end if

        ' Combine the addresses together resulting in the following format:
        ' <HOST_RUNNING_CHARLES>:<CHARLES_PORT>;<ORIGINAL_ADDRESS>
        proxyUrl = proxyPrefix + currentUrl
        return proxyUrl
      end if
    end if
  #end if

  return url
end function
