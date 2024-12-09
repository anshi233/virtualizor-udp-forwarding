# virtualizor-udp-forwarding
A hook script to automatically create UDP forwarding rule according VPS's domain forwarding setting.
The script is created by ChatGPT.

The script will read the content of /etc/haproxy/haproxy.cfg , then create coressponding socat command for UDP port forwarding.

#Usage

1. Put set_udp.sh to any location you like.
2. For each Virtualizor slave server, make sure ```socat``` is installed in the server.
3. For each Virtualizor slave server, find the systemd file of the haproxy (e.g. For Debian and proxmox, it should be ```/lib/systemd/system/haproxy.service```)
4. In the systemd file, add following lines:
- After ExecStart, add new line with content ```ExecStartPost=/bin/bash YOUR_ABSOULTE_PATH_TO_THE_set_udp.sh```
- After ExecReload, add new line with content ```ExecReload=/bin/bash YOUR_ABSOULTE_PATH_TO_THE_set_udp.sh```
- Example content:
  ```
  ...
  [Service]
  EnvironmentFile=-/etc/default/haproxy
  EnvironmentFile=-/etc/sysconfig/haproxy
  BindReadOnlyPaths=/dev/log:/var/lib/haproxy/dev/log
  Environment="CONFIG=/etc/haproxy/haproxy.cfg" "PIDFILE=/run/haproxy.pid" "EXTRAOPTS=-S /run/haproxy-master.sock"
  ExecStart=/usr/sbin/haproxy -Ws -f $CONFIG -p $PIDFILE $EXTRAOPTS
  ExecStartPost=/bin/bash YOUR_ABSOULTE_PATH_TO_THE_set_udp.sh
  ExecReload=/usr/sbin/haproxy -Ws -f $CONFIG -c -q $EXTRAOPTS
  ExecReload=/bin/kill -USR2 $MAINPID
  ExecReload=/bin/bash YOUR_ABSOULTE_PATH_TO_THE_set_udp.sh
  KillMode=mixed
  Restart=always
  SuccessExitStatus=143
  Type=notify
  ```
5. reload the systemd configurations by running e,g for debian and proxmox, run ```systemctl daemon-reload```
6. Set some domain forwarding for your VPS, use ```ps aux | grep socat``` to check is UDP port forwarding rule automatically set with coressponding TCP port forwarding rule.
