# <div align="center"> 一键部署 v2ray 到 Heroku </div>
**本程序[以GPL-3.0开源许可开源](https://github.com/mnixry/v2ray-heroku-fix/blob/master/LICENSE#L591),仅供学习交流参考使用,对于使用本程序造成的一切后果作者概不承担!**

![](https://github.com/mnixry/v2ray-heroku-fix/workflows/V2ray%20Heroku%20Docker%20Image/badge.svg)

---

## 停止维护

**由于Heroku的用户协议禁止作为代理使用，本项目停止更新**

**正在研究采用kubesail提供的服务实现类似功能**


## 部署方法
1. 点击下方按钮跳转Heroku部署(需要注册账号)
    - [![Deploy](https://www.herokucdn.com/deploy/button.png)](https://dashboard.heroku.com/new?template=https://github.com/mnixry/v2ray-heroku-fix)

2. 跟着提示走吧（逃

3. 服务端部署后，点 `open app`,能正常显示反代理的网页,地址补上V2ray路径后访问显示`Bad Request`,表示部署成功。

4. 更新 v2ray 版本
    - 访问 https://dashboard.heroku.com/apps 选择部署好v2ray的app
    - 直接选择`More` --> `Restart all dynos`

## 参考链接:
> [V2ray-Core](https://github.com/v2ray/v2ray-core)

> [v2ray-heroku](https://github.com/wangyi2005/v2ray-heroku)

> [v2ray-heroku-undone](https://github.com/1715173329/v2ray-heroku-undone)
