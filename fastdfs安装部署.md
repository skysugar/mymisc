###fastdfs 安装部署

####简介

> fastdfs是知名大神**YuQing**开发的一款文件管理系统,此系统由跟踪器,存储节点,客户端组成.适合存放0~500M的文件. 对于有大量图片和视频需求是一个不不错的选择.每个文件都会存放到所以节点上,负载均衡,冗余备份都可以在这个系统上面开展实施.
>
> 缺点是需要自己记录导入此系统文件的存储位置.存储的容量取决于单个节点的容量.

#### 部署

> 环境简介:
>
> 一台做tracker, 两台做storage. 客户端测试在tracker上面做.

* 安装程序

  所以服务器都需要做这些操作.

  ```shell
  #安装libfastcommon库
  git clone  https://github.com/happyfish100/libfastcommon.git
  cd libfastcommon
  ./make.sh
  ./make.sh install
  #安装fastdfs
  git clone https://github.com/happyfish100/fastdfs.git
  cd fastdfs/
  ./make.sh
  ./make.sh install
  ```

* 配置启动

  1. tracker配置

     在**/etc/fdfs/**目录下面拷贝**tracker.conf.sample**为**tracker.conf**

     然后修改其中的配置 *base_path=一个存在路径*

     最后启动  `/etc/init.d/fdfs_trackerd start`

     查看端口已经监听22122端口

  2. storage配置

     在**/etc/fdfs/**目录下面拷贝**storage.conf.sample**为**storage.conf**

     开始修改配置

     ```shell
     #存储的组名
     group_name=group1
     #base存储路径
     base_path=/home/fastdfs/base
     #文件上传后的存储路径
     store_path0=/home/fastdfs/storage
     #tracker的地址,多个tracker写多行
     tracker_server=192.168.0.1:22122
     #http端口,后面做nginx访问,需要和这个端口一致
     http.server_port=8888
     ```

     最后启动  `/etc/init.d/fdfs_storage start`

  3. client配置

     在**/etc/fdfs/**目录下面拷贝**client.conf.sample**为**client.conf**

     修改这一行就行了**tracker_server=192.168.0.1:22122**

  4. 测试

     ```shell
     #查看系统的运行状态
     [root@localhost ~]# fdfs_monitor /etc/fdfs/client.conf
     #上次文件,将会返回存储的路径, 比如这样的 组名/M00/00/00/xxx.jpg
     [root@localhost ~]# fdfs_upload_file /etc/fdfs/client.conf file_path
     #删除文件
     [root@localhost ~]# fdfs_delete_file /etc/fdfs/client.conf 路径(组名/M00/00/00/xxx.jpg)
     ```

#### FastDFS + Nginx 组合

>通过http来访问资源,这里就需要按照nginx和nginx的fastdfs的模块.

* 安装

  ```shell
  [root@localhost ~]# git clone https://github.com/happyfish100/fastdfs-nginx-module.git
  [root@localhost ~]# wget -S http://nginx.org/download/nginx-1.12.1.tar.gz
  [root@localhost ~]# tar zxvf nginx-1.12.1.tar.gz
  [root@localhost ~]# cd nginx-1.12.1
  [root@localhost ~]# ./configure --prefix=/usr/local/nginx --add-module=../fastdfs-nginx-module/src
  ```

  安装nginx需要一下关联的包,可以用下面命令安装

  `yum install gcc gcc-c++ make automake autoconf libtool pcre* zlib openssl openssl-devel -y`

  不出意外就安装成功的

  为了可以正常访问,需要将相关配置拷入*/etc/fdfs/*目录下面.

  ```shell
  #fastdfs-nginx-module源码目录下面的mod_fastdfs.conf
  [root@localhost ~]# cp fastdfs-nginx-module/src/mod_fastdfs.conf /etc/fdfs/
  #fastdfs源码目录下面的http.conf 和 mime.types
  [root@localhost ~]# cp conf/http.conf /etc/fdfs/
  [root@localhost ~]# cp conf/mime.types /etc/fdfs/
  ```

* 配置

  修改**/etc/fdfs/http.conf**配置文件

  ```shell
  #修改base_path的值,要和/etc/fdfs/storage.conf里面的值一样
  base_path=/home/fastdfs/base
  #tracker的地址,多个写多行
  tracker_server=192.168.0.1:22122
  #group的名字,fdfs里面有配置保持一致
  group_name=group1
  #在访问过程中url中带组的名字
  url_have_group_name = true
  #存储文件的路径,和fdfs里面的一致
  store_path0=/home/fastdfs/storage
  #当本节点没有访问的资源,返回让客户端跳转到有资源的节点.
  #这里可能有疑问上面说了既然文件会到村到所以节点,这里怎么就会不存在呢.其实有这样的情况,就是文件还没有及时同步过来就有客户端来请求资源了.
  response_mode=redirect
  ```

  修改**/usr/local/nginx/conf/nginx.conf**配置文件

  ```shell
  user root;
  worker_processes auto;

  events {
      worker_connections 65500;
  }

  http {
      include mime.types;
      default_type application/octet-stream;
      sendfile on;
      keepalive_timeout 65;
      access_log off;

      server {
          listen 8888;
          server_name _;

          location ~ /group[0-9]/ {
              ngx_fastdfs_module;
          }

          error_page 500 502 503 504 /50x.html;
          location = /50x.html {
              root html;
          }
      }
  }
  ```

  然后启动nginx.

* 这样就可以通过http来访问资源了.

  格式是 *http://服务器地址:端口/fastdfs客户端上次文件后方面的值*

  比如    *http://192.168.0.2:8888/group/M00/00/00/xxxxxxx.jpg*

