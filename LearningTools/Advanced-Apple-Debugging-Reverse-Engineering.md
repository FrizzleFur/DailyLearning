
# Advanced Apple Debugging Reverse Engineering


For example, try attaching LLDB to the Finder application.Open up a Terminal window and look for the Finder process, like so:

```lldb -n Finder
```
You’ll notice the following error: 
 
```
 error: attach failed: cannot attach to process due to System IntegrityProtection
```

### Disabling Rootless
Disabling RootlessTo disable Rootless, perform the following steps:1. RestartyourmacOSmachine.2. Whenthescreenturnsblank,holddownCommand+RuntiltheAppleboot logo appears. This will put your computer into Recovery Mode.3. Now,findtheUtilitiesmenufromthetopandthenselectTerminal.4. WiththeTerminalwindowopen,type:  csrutil disable; reboot5. YourcomputerwillrestartwithRootlessdisabled.You can verify if you successfully disabled Rootless by trying the same command in Terminal again once you log into your account.lldb -n FinderLLDB should now attach itself to the current Finder process. The output of asuccessful attach should look like this


![](http://oc98nass3.bkt.clouddn.com/2017-07-04-14991598265621.jpg)

Attaching LLDB to XcodeNow you’ve disabled Rootless, and you can attach LLDB to processes, it’s time to start your whirlwind tour in debugging. You’re first going to look into an application you frequently use in your day-to-day development: Xcode!Open a new Terminal window. Next, edit the Terminal tab’s title by pressing ⌘ + Shift + I. A new popup window will appear. Edit the Tab Title to be LLDB.

From
![](http://oc98nass3.bkt.clouddn.com/2017-07-04-14991600960053.jpg)
to

Note: You might notice some output on the Xcode stderr Terminal window; this is due to content logged by the authors of Xcode via NSLog or another stderr console printing function.

![](http://oc98nass3.bkt.clouddn.com/2017-07-04-14991619418698.jpg)


#### `help` and `apropos`

* help：      命令解释
* apropos：   查找包含搜寻的字符的命令信息




![](http://oc98nass3.bkt.clouddn.com/2017-07-05-14992242080249.jpg)




### Helpful Links

1. [Advanced Apple Debugging & Reverse Engineering](https://www.raywenderlich.com/161106/introducing-advanced-apple-debugging-reverse-engineering)
2. [Advanced Apple Debugging & Reverse Engineering](https://videos.raywenderlich.com/courses/82-rwdevcon-2017-vault-workshops/lessons/1)
3. [Advanced App Architecture](https://videos.raywenderlich.com/courses/82-rwdevcon-2017-vault-workshops/lessons/2)

