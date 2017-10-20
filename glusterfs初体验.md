## GlusterFS初体验



#### 简介

>    GlusterFS总体架构与组成部分，它主要由存储服务器（BrickServer）、客户端以及NFS/Samba 存储网关组成。**GlusterFS 架构中没有元数据服务器组件**，这是其最大的设计这点，对于提升整个系统的性能、可靠性和稳定性都有着决定性的意义。GlusterFS 支持TCP/IP 和InfiniBandRDMA 高速网络互联，**客户端可通过原生Glusterfs 协议访问数据，其他没有运行GlusterFS客户端的终端可通过NFS/CIFS 标准协议通过存储网关访问数据。**



#### 实验环境

准备三台机器,一台做客户端,两台做gluster存储节点.

```shell
192.168.0.1 client
192.168.0.2 node1
192.168.0.3 node2
```



1. 准备安装

   **准备环境的时候把存储数据的硬盘和系统分区分开,单独将一个分区挂在为存储文件的目录.**

   分别在两个服务端执行`yum -y install glusterfs-server`安装服务. 相关的关联都会自动安装.

   然后启动`systemctl start glusterd`.

   ```shell
   [root@node1 ~]# yum install centos-release-gluster38
   [root@node1 ~]# yum install glusterfs-server
   [root@node1 ~]# systemctl start glusterd
   [root@node1 ~]# systemctl status glusterd
   ● glusterd.service - GlusterFS, a clustered file-system server
      Loaded: loaded (/usr/lib/systemd/system/glusterd.service; disabled; vendor preset: disabled)
      Active: active (running) since Fri 2017-10-20 17:12:47 CST; 10s ago
     Process: 3064 ExecStart=/usr/sbin/glusterd -p /var/run/glusterd.pid --log-level $LOG_LEVEL $GLUSTERD_OPTIONS (code=exited, status=0/SUCCESS)
    Main PID: 3065 (glusterd)
      CGroup: /system.slice/glusterd.service
              └─3065 /usr/sbin/glusterd -p /var/run/glusterd.pid --log-level INFO

   Oct 20 17:12:47 tracker systemd[1]: Starting GlusterFS, a clustered file-system server...
   Oct 20 17:12:47 tracker systemd[1]: Started GlusterFS, a clustered file-system server.
   ```

2. 服务端配置

   添加节点形成集群 `gluster peer probe [ip|name]` , 在一个节点上操作就可以了.

   ```shell
   [root@node1 ~]# gluster peer probe 192.168.0.3
   peer probe: success. 
   [root@node1 ~]# gluster peer status
   Number of Peers: 1

   Hostname: 192.168.0.3
   Uuid: c694d4b8-1875-468e-8ed2-b920a941e071
   State: Peer in Cluster (Connected)

   ```

   这时在node2上查看节点信息.

   ```shell
   [root@node2 ~]# gluster peer status
   Number of Peers: 1

   Hostname: 192.168.0.2
   Uuid: 77c3601d-31ab-4677-b963-18095ba4837e
   State: Peer in Cluster (Connected)

   ```

   创建存储的卷

   ```shell
   [root@node1 ~]# mkdir /home/gfs/
   [root@node1 ~]# gluster volume create def 192.168.93.101:/home/gfs/def 192.168.93.102:/home/gfs/def
   volume create: def: success: please start the volume to access data
   [root@node1 ~]# gluster volume info def
    
   Volume Name: def
   Type: Distribute
   Volume ID: 880e2d57-1fd9-42ba-b515-13c7ebd74e82
   Status: Created
   Snapshot Count: 0
   Number of Bricks: 2
   Transport-type: tcp
   Bricks:
   Brick1: 192.168.0.2:/home/gfs/def
   Brick2: 192.168.0.3:/home/gfs/def
   Options Reconfigured:
   transport.address-family: inet
   performance.readdir-ahead: on
   nfs.disable: on
   [root@node1 ~]# gluster volume start def
   volume start: def: success
   ```

   上面可以看到我们创建了一个分布式存储的卷并且启动了它.

3. 客户端安装

   `yum install glusterfs-client-xlators`

   安装之后可以mount挂载, 随便挂载集群中的一个就可以.

   ```shell
   [root@client ~]# mount.glusterfs 192.168.93.101:/def /mnt/
   [root@client ~]# mount
   ...
   192.168.0.2:/def on /mnt type fuse.glusterfs (rw,relatime,user_id=0,group_id=0,default_permissions,allow_other,max_read=131072)
   fusectl on /sys/fs/fuse/connections type fusectl (rw,relatime)

   ```

   然后就可以向操作普通的文件夹一样操作了.

   ​