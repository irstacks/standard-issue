> http://serverfault.com/questions/447686/mac-osx-server-command-equivalent-for-dhclient


```bash
$ sudo ipconfig setverbose 1
$ tail -f /var/log/system.log
$ sudo ipconfig setverbose 0
```