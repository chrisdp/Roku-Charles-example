# Roku-Charles-example
This is a simple app showing how you can view the network traffic in your Roku channel.

- [Roku-Charles-example](#roku-charles-example)
  - [Requirements](#requirements)
  - [Charles Setup](#charles-setup)
      - [Rewrite](#rewrite)
      - [Settings](#settings)
  - [Roku Setup](#roku-setup)
  - [Conclusion](#conclusion)
  - [TODO](#todo)

## Requirements
- __Both__ the computer and the Roku need to be on the same network
- If your computer IP is not static you will need to update the Charles rewrite rule and the proxy IP on Roku to match the new IP (steps below).

## Charles Setup
In the project root there will be a file called [CharlesRewrites.xml](CharlesRewrites.xml). We will use this file to import the required rewrites into Charles. We will also need to make sure a few settings are enabled in Charles.

#### Rewrite
In Charles go to Tools > Rewrite > Import. From here navigate to the project root and open the [CharlesRewrites.xml](CharlesRewrites.xml).
Once open you should see something like this:
![CharlesImportExample](/READMEImages/CharlesImportExample.png)

Next we will need to make a small update to the rewrite. Click on `Roku Proxy` then in the bottom box double click the `Body` option:

![CharlesRewriteRokuProxy](/READMEImages/CharlesRewriteRokuProxy.png)
![CharlesRewriteRokuProxyHostIp](/READMEImages/CharlesRewriteRokuProxyHostIp.png)

In the above image you can see I have the `192.168.8.185` highlighted. We need to update this to be the IP of your computer running Charles on. For example mine would look like this: `http://192.168.8.185:8888/;$1`. It is also worth noting that if you have changed the port Charles is running on you will need to update the `8888` value to what ever you have configured in Charles.

#### Settings
Now that we have the rewrite in place we need to change a few settings in Charles. First we need to enable HTTP proxy. Do so by going to Proxy > Proxy Settings and in the `HTTP Proxy` area you will need to turn on the following:

- `Support HTTP/2` (if you are using HTTP2)
- `Enable transparent HTTP proxying`

At this time if you want to change the port Charles runs on you can do that here in the `Port` field. Make sure if you do change this that you update all the references to default port, `8888`, in your rewrite and in your channel code.

![CharlesProxySetting](/READMEImages/CharlesProxySetting.png)

## Roku Setup
Now that Charles is setup and ready to receive requests from your Roku we need to get your channel sending the requests to it. We can do this by making sure we always run our main requests though a function like this:

```
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
```

If set up correctly the first time your Roku sends a request to Charles it will ask you to approve the connection. Just click `Allow` and you should be good to go.

![CharlesAllowConnection](/READMEImages/CharlesAllowConnection.png)

## Conclusion

Assuming everything is set up correctly you should now be able to restart the channel and see all the application traffic in Charles.

*TIP:* If you are seeing a lot of local traffic you can turn off the `macOS Proxy` by going to Proxy > Proxy Settings > macOS and un-checking the following and restarting Charles:
- `Enable macOS proxy`
- `Enable macOS proxy on launch`

## TODO
- add an example prelaunch task showing how you could pull the prox ip from an `.env` file
- add some more explanations as to what this rewrite is doing
