## 解析-puppeteer


## 对Carbon的上传限制

    [[WIP] feat: expose updateCode method for headless browser by axetroy · Pull Request #644 · dawnlabs/carbon](https://github.com/dawnlabs/carbon/pull/644)


why expose this?
Third-party jumps to https://carbon.now.sh will be restricted due to URL restrictions.

Unable to generate more code

So another idea is to use the headless browser to open https://carbon.now.sh, paste the code, and then generate a screenshot

So we need to expose a method that can change the code in codemirror

Description


Or globally expose a carbon object

It encapsulates some common methods.

eg. Change Code / Change Theme / Change Code Language

const carbon = {}

carbon.updateCode = function () { // ...}
carbon.changeTheme = function () { // ...}
carbon.changeLanguage = function () { // ...}
carbon.downloadImage = function () { // ...}
// ... and so on

window.carbon = carbon
I am waiting for the discussion plan to be feasible


[Add file explore menu item to capture entire file · Issue #14 · ericadamski/vscode-carbon_now_sh](https://github.com/ericadamski/vscode-carbon_now_sh/issues/14)
## 参考

* [puppeteer - npm](https://www.npmjs.com/package/puppeteer)
* [Getting Started with Headless Chrome  |  Web  |  Google Developers](https://developers.google.com/web/updates/2017/04/headless-chrome)