comment
=======

使用ngin +  lua 实现的评论模块。

http://blog.csdn.net/freewebsys/article/details/16944917

前言：
参考了下ngx_lua，Node.js，PHP三个进行的压测对比。
http://bluehua.org/demo/php.node.lua.html

ngx_lua   Time per request: 3.065 [ms]
Node.js   Time per request: 3.205 [ms]
PHP	      Time per request: 5.747 [ms]

从各种性能测试来说ngx_lua似乎在CPU和内存上更胜一筹，同时
ngx_lua出奇的资源消耗比较稳定，不像php那样波动比较大。
ngx_lua和Node.js几乎比php快接近1倍。
同时ngx_lua模型也是单线程的异步的事件驱动的，工作原理和nodejs相同，
代码甚至比nodejs的异步回调更好写一些。
对于ngx的运维和配置相对比nodejs来说更加熟悉和有经验。


1，总体设计思路
完全基于nginx层实现，nginx要开启ssi。
（Server Side Includes：http://wiki.nginx.org/HttpSsiModule）
以最快的速度展示页面，使用ssi直接读取数据，不是ajax返回。
服务端使用lua读取数据库内容并显示。

对应用的评论，使用mysql分区，按照itme_id进行hash。
设置成1024个分区，以后方便进行拆库。保证每一个表的数据都不是很大。
（1024）是mysql能设置的最大分区数量。

ningx 请求 /blog/201311/127.html（博客内容已经静态化了。）

	↓
	
使用ssi将url里面的参数获得调用lua评论模块

	↓
	
lua评论模块，读取数据库。（如果压力大，可以进行拆库，做cache）

2，nginx配置
参考：
http://wiki.nginx.org/HttpSsiModule
http://wiki.nginx.org/HttpCoreModule

    gzip  on;
    ssi on;
    root /data/comment;
	location /blog/list_comment {
		default_type 'text/html';
		content_by_lua_file '/data/comment/list_comment.lua';
    }
	location /blog/save_comment {
		default_type 'text/html';
		content_by_lua_file '/data/comment/save_comment.lua';
    }


在静态页面中增加ssi代码
<!--# include virtual="/blog/list_comment?uri=$request_uri" -->


3，mysql修改打开文件数
因为开启了分区，所以读取文件数量肯定会多。
用ulimit -n查看打开文件数量。如果是1024，修改配置：
/etc/security/limits.conf
*	soft    noproc  65536
*	hard    noproc  65536
*	soft    nofile  65536
*	hard    nofile  65536
重启系统，然后修改my.conf配置文件：
vi /etc/my.cnf 

[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
user=mysql
symbolic-links=0
open_files_limit=65536

重启mysql生效，查看参数：
mysql> show variables like 'open%';
+------------------+-------+
| Variable_name    | Value |
+------------------+-------+
| open_files_limit | 65536 |
+------------------+-------+
1 row in set (0.00 sec)

数据库表
<div>
CREATE TABLE `comment` (
  `id` int(11) NOT NULL auto_increment COMMENT '主键',
  `item_id` int(11) NOT NULL COMMENT '评论项id',
  `uid` int(11) NOT NULL default '0' COMMENT '评论用户',
  `content` text NOT NULL COMMENT '内容',
  `create_time` datetime NOT NULL  COMMENT '创建时间',
  PRIMARY KEY  (`item_id`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8
PARTITION BY HASH (`item_id`)
PARTITIONS 1024;

</div>
插入数据
insert into comment(`item_id`,content,create_time) values(127,CONCAT("conent test ",RAND()*1000),now());

