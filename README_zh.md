# vmware-exporter

这是一个简单的Prometheus导出器，用于从vCenter收集各种指标。

## 使用方法

在Docker容器中运行导出器（或作为进程启动）并提供所有必要的设置。然后进行指标抓取。

### 非Docker安装方式

1. 将编译好的二进制文件复制到`/opt/exporter/vmware-exporter/vmware-exporter`
2. 在`/etc/systemd/system/vmware-exporter.service`创建systemd服务文件，内容如下：

```ini
[Unit]
Description=VMware Exporter
After=network.target

[Service]
User=exporter
Group=exporter
WorkingDirectory=/opt/exporter/vmware-exporter
ExecStart=/opt/exporter/vmware-exporter/vmware-exporter \
    -vmware.vcenter=your_vcenter_address \
    -vmware.username=your_username \
    -vmware.password=your_password
Restart=always

[Install]
WantedBy=multi-user.target
```

3. 启用并启动服务：
```bash
sudo systemctl daemon-reload
sudo systemctl enable vmware-exporter
sudo systemctl start vmware-exporter
```

当使用/metrics路径时，导出器会抓取单个vCenter主机。使用/probe路径时可以抓取多个vCenter主机，但这些vCenter主机必须共享相同的凭据。

### 配置选项

导出器可以通过命令行选项、环境变量、yaml配置文件或三者组合进行配置。环境变量的设置会被配置文件内容覆盖，而配置文件内容又会被启动时设置的任何命令行选项覆盖。

可用选项如下：

| 选项 | 描述 |
| --- | --- |
| -envflag.enable | 告诉导出器使用环境变量进行配置 |
| -envflag.prefix | 允许为环境变量添加前缀 |
| -file | yaml配置文件的路径，遵循命令行选项的结构 |
| -http.address | 导出器绑定的地址和端口，格式为host:port (默认: ":9169") |
| -log.format | 日志格式，可以是json或logfmt (默认: logfmt) |
| -log.level | 日志级别：debug、info、warn或error (默认: debug) - 不要期望太多.. |
| -prim.maxRequests | 最大并发抓取请求数 (默认: 20) |
| -disable.exporter.metrics | 禁用导出器进程指标 |
| -disable.exporter.target | 禁用导出器默认目标 - /metrics将只返回导出器数据 - 使用/probe |
| -disable.default.collectors | 禁用所有默认启用的收集器 |
| -collector.datacenter | 启用或禁用数据中心指标收集 (默认: 启用) |
| -collector.cluster | 启用或禁用集群指标收集 (默认: 启用) |
| -collector.datastore | 启用或禁用数据存储指标收集 (默认: 启用) |
| -collector.host | 启用或禁用主机指标收集 (默认: 启用) |
| -collector.vm | 启用或禁用虚拟机指标收集 (默认: 启用) |
| -collector.esxcli.host.nic | 使用通过vCenter调用的esxcli收集ESXi网卡固件信息 (默认: 禁用) |
| -collector.esxcli.storage | 使用通过vCenter调用的esxcli收集ESXi存储固件信息 (默认: 禁用) |
| -vmware.username | 登录vCenter服务器的用户名 |
| -vmware.password | 上述用户的密码 |
| -vmware.vcenter | vCenter服务器地址，格式为host:port。这不是vCenter管理控制台 |
| -vmware.schema | 使用HTTP或HTTPS (默认: "https") |
| -vmware.ssl | 验证vCenter SSL或信任 (默认: false) |
| -vmware.interval | 数据收集频率，单位为秒 (默认: 20) |
| -vmware.granularity | 采样数据的频率，单位为秒 (默认: 20) |

### 使用示例

```bash
./vmware-exporter \
    -vmware.vcenter=host:port \
    -vmware.username=your_username \
    -vmware.password=your_password \
    -vmware.ssl=true
```

esxcli收集器是一个非常特定的用例，可能大多数人都不需要。这里保留代码作为示例，展示如何通过vCenter SOAP API远程使用esxcli命令工具收集自定义信息。