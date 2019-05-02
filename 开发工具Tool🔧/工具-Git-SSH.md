# 工具-Git-SSH

## 背景

ssh是指Secure Shell，安全外壳协议，简称SSH，是一种加密的网络传输协议，可在不安全的网络中为网络服务提供安全的传输环境[Secure Shell - 维基百科，自由的百科全书](https://zh.wikipedia.org/wiki/Secure_Shell)

* SSH通过在网络中创建安全隧道来实现SSH客户端与服务器之间的连接
* 虽然任何网络服务都可以通过SSH实现安全传输，SSH最常见的用途是远程登录系统，
* 人们通常利用SSH来传输命令行界面和远程执行命令。
* 使用频率最高的场合类Unix系统，但是Windows操作系统也能有限度地使用SSH

### SSH代理

SSH-agent

* ssh-agent是一个程序，用于保存用于公钥认证的私钥（RSA，DSA，ECDSA）。我们的想法是在X-session或登录会话开始时启动ssh-agent，并且所有其他窗口或程序作为ssh-agent程序的客户端启动。通过使用环境变量，可以使用ssh（1）登录到其他计算机时定位代理并自动用于身份验证。
* SSH代理为您处理身份验证数据的签名。在对服务器进行身份验证时，您需要使用私钥对某些数据进行签名，以证明你是你。
* SSH代理从不将这些密钥交给客户端程序，而只是提供一个套接字，客户端可以通过该套接字向其发送数据，并通过该套接字响应签名数据。这样做的另一个好处是，即使您不完全信任的程序，也可以使用私钥。


### SSH的安全验证

在客户端来看，SSH提供两种级别的安全验证。

* 第一种级别（基于**密码**的安全验证），知道帐号和密码，就可以登录到远程主机，并且所有传输的数据都会被加密。但是，可能会有别的服务器在冒充真正的服务器，无法避免被“中间人”攻击。
* 第二种级别（基于**密钥**的安全验证），需要依靠密钥，也就是你必须为自己创建一对密钥，并把公有密钥放在需要访问的服务器上。客户端软件会向服务器发出请求，请求用你的密钥进行安全验证。服务器收到请求之后，先在你在该服务器的用户根目录下寻找你的公有密钥，然后把它和你发送过来的公有密钥进行比较。如果两个密钥一致，服务器就用公有密钥加密“质询”（challenge）并把它发送给客户端软件。从而避免被“中间人”攻击。

在服务器端，SSH也提供安全验证。

* 在第一种方案中，主机将自己的公用密钥分发给相关的客户端，客户端在访问主机时则使用该主机的公开密钥来加密数据，主机则使用自己的私有密钥来解密数据，从而实现主机密钥认证，确保数据的保密性。 
* 在第二种方案中，存在一个密钥认证中心，所有提供服务的主机都将自己的公开密钥提交给认证中心，而任何作为客户端的主机则只要保存一份认证中心的公开密钥就可以了。**在这种模式下，客户端必须访问认证中心然后才能访问服务器主机**。



## SSH密钥生成

粘贴下面的文本，替换您的电子邮件地址。


```
$ ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

这将使用提供的电子邮件作为标签创建一个新的ssh密钥。


**如果您使用的是macOS Sierra 10.12.2或更高版本，则需要修改~/.ssh/config文件以自动将密钥加载到ssh-agent中并在密钥链中存储密码。**

```
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_rsa
```

将SSH私钥添加到ssh-agent并将密码存储在密钥链中。如果使用其他名称创建密钥，或者要添加具有不同名称的现有密钥，请将命令中的id_rsa替换为私钥文件的名称。


```
$ ssh-add -K ~/.ssh/id_rsa
```

注意：该-K选项是Apple的标准版本ssh-add，当您将ssh密钥添加到ssh-agent时，它会将密码链存储在您的钥匙串中。

如果您没有安装Apple的标准版本，则可能会收到错误消息。有关解决此错误的详细信息，请参阅“ 错误：ssh-add：非法选项 - K”。




## 参考

1. [Secure Shell - 维基百科，自由的百科全书](https://zh.wikipedia.org/wiki/Secure_Shell)
2. [openssh - what's the purpose of ssh-agent? - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/72552/whats-the-purpose-of-ssh-agent)
3. [Generating a new SSH key and adding it to the ssh-agent - GitHub Help](https://help.github.com/en/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key)
