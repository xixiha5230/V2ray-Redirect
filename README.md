# v2ray-Redirect

## 用途：

​	基于openwrt+xray，使用redirect实现v2ray透明代理，使用ipset直连国内ip，并且可以自动在多个节点之间切换。

## 要求：

​	1. openwrt软路由

​	2. 充足的磁盘(128M)和内存(128M)

​	3. 多个v2ray节点(vless+ws+tls)

## 用法：

 1. 使用winscp等工具将本项目文件拷贝到openwet的 `/root` 目录，也就是  `(~) `目录

    

 2. 用xshell等工具连接到openwrt，执行:

    `cd ~/V2ray-Redirect` 到工程目录

    `chmod +x * -R` 修改权限

    

 3. 打开snode.config文件(`nano snode.config`)配置节点的个数，例如有5个节点，从第0个开始，配置如下：

    `num=0`
    `total=5`

    

 4. 修改`xray`文件夹下的`*.json.temp`文件为`*.json`文件，执行：

    `cd  xray` 

    `mv *.json.temp *.json` （*为对应文件名）

    

5. 这些json文件是xray的配置文件，可以按需更改。其中：

   `temp.json`文件是完整的配置文件

   `head.json`文件是配置文件中包含入站和部分出站的配置，不同v2ray节点是可以共用的

   `rule.json`文件是配置文件中包含部分出站和规则的配置，不同v2ray节点是可以共用的

   `0.json` 文件是配置文件中包含`uuid`、 `servername` 和 `host`的配置，不同v2ray节点是不同的，多个节点可依次添加`1.json` `2.json`等。

   

6. 以上配置文件中只有`head.json` `数字.json`  `rule.json` 会被脚本读取，脚本读取三个文件之后会按顺序（`head.json`+`数字.json`+ `rule.json` ）拼接成一个完整的配置文件，可以自行更改每个文件中的内容，来适应v2ray节点要求。

   

7. 脚本命令:

   `./snode.sh start` 启动透明代理

   `./snode.sh stop` 停止透明代理

   `./snode.sh restart` 重启透明代理

   `./snode.sh newrule` 更新代理规则

   `./snode.sh changeNode`  更改v2ray节点

   

8. 使用openwrt计划任务更新规则和定时切换v2ray节点：

   每三小时切换一次节点

   `0 */3 * * * /bin/sh /root/v2rayRedirect/snode.sh changeNode > /dev/null 2>&1 &` 

   每天5点更新一次代理规则

   `0 5 * * * /bin/sh /root/v2rayRedirect/snode.sh newrule > /dev/null 2>&1 &`

   

9. 可以配合openwrt官方https-dns-proxy插件防止dns污染

   

10. 将openwrt设置为网关，即可实现透明代理

     

## 依赖：

  查看`buildOpenwrtDoc\raspBuildOpenwrt.md`文件