<div class="main">
                    <link href="http://static.blog.csdn.net/css/comment1.css" type="text/css" rel="stylesheet">
<link href="http://static.blog.csdn.net/css/style1.css" type="text/css" rel="stylesheet">
<div id="article_details" class="details">
    

    
<div class="tag2box"><a href="http://www.csdn.net/tag/nginx" target="_blank">nginx</a><a href="http://www.csdn.net/tag/lua" target="_blank">lua</a></div>

    
<div style="clear:both"></div><div style="border:solid 1px #ccc; background:#eee; float:left; min-width:200px;padding:4px 10px;"><p style="text-align:right;margin:0;"><span style="float:left;">目录<a href="#" title="系统根据文章中H1到H6标签自动生成文章目录">(?)</a></span><a href="#" onclick="javascript:return openct(this);" title="展开">[+]</a></p><ol style="display:none;margin-left:14px;padding-left:14px;line-height:160%;"><li><a href="#t0">前言</a></li><li><a href="#t1">总体设计思路</a></li><li><a href="#t2">主要代码</a></li><li><a href="#t3">nginx配置</a></li><li><a href="#t4">mysql修改打开文件数</a></li></ol></div><div style="clear:both"></div><div id="article_content" class="article_content">

<p>开发这个模块，是为了解决项目中的实际问题，思考设计的 。<br>
<br>
</p>
<p></p>
<h2><a name="t0"></a>前言：</h2>
<br>
参考了下ngx_lua，Node.js，PHP三个进行的压测对比。<br>
<a target="_blank" href="http://bluehua.org/demo/php.node.lua.html">http://bluehua.org/demo/php.node.lua.html</a><br>
<br>
ngx_lua &nbsp; Time per request: 3.065 [ms]<br>
Node.js &nbsp; Time per request: 3.205 [ms]<br>
PHP<span style="white-space:pre"> </span>&nbsp; &nbsp; &nbsp;Time per request: 5.747 [ms]<br>
<br>
<br>
<br>
从各种性能测试来说ngx_lua似乎在CPU和内存上更胜一筹，同时<br>
ngx_lua出奇的资源消耗比较稳定，不像php那样波动比较大。<br>
ngx_lua和Node.js几乎比php快接近1倍。<br>
同时ngx_lua模型也是单线程的异步的事件驱动的，工作原理和nodejs相同，<br>
代码甚至比nodejs的异步回调更好写一些。<br>
对于ngx的运维和配置相对比nodejs来说更加熟悉和有经验。<br>
<br>
<br>
<h2><a name="t1"></a>1，总体设计思路</h2>
<br>
<br>
<strong>完全基于nginx层实现，nginx要开启ssi。</strong><br>
（Server Side Includes：<a target="_blank" href="http://wiki.nginx.org/HttpSsiModule">http://wiki.nginx.org/HttpSsiModule</a>）<br>
以最快的速度展示页面，使用ssi直接读取数据，不是ajax返回。<br>
服务端使用lua读取数据库内容并显示。<br>
<br>
<br>
<br>
<br>
<strong>对应用的评论，使用mysql分区，按照itme_id进行hash。</strong><br>
设置成1024个分区，以后方便进行拆库。保证每一个表的数据都不是很大。<br>
（1024）是mysql能设置的最大分区数量。<br>
<br>
<br>
<strong>流程：<br>
<br>
ningx 请求 /blog/201311/127.html（博客内容已经静态化了。）</strong><br>
<br>
<span style="white-space:pre"></span>↓<br>
<span style="white-space:pre"></span><br>
<strong>使用ssi将url里面的参数获得调用lua评论模块</strong><br>
<p></p>
<p><span style="white-space:pre"></span>↓<br>
<span style="white-space:pre"></span><br>
<strong>lua评论模块，读取数据库。（如果压力大，可以进行拆库，做cache）</strong><br>
<br>
<br>
</p>

<p>运行效果：使用了oschina的页面样式。</p>
<p><strong>其中/blog/201311/127.html是静态html页面。</strong></p>
<p><strong>速度超级快。</strong></p>
<p><img src="http://img.blog.csdn.net/20131125165756390?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvZnJlZXdlYnN5cw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast" alt=""><br>
<br>
</p>
<h2><a name="t3"></a>3，nginx配置</h2>
参考：<br>
<a target="_blank" href="http://wiki.nginx.org/HttpSsiModule">http://wiki.nginx.org/HttpSsiModule</a><br>
<a target="_blank" href="http://wiki.nginx.org/HttpCoreModule">http://wiki.nginx.org/HttpCoreModule</a><br>
<br>
<br>
<div class="dp-highlighter bg_plain"><div class="bar"><div class="tools"><b>[plain]</b> <a href="#" class="ViewSource" title="view plain" onclick="dp.sh.Toolbar.Command('ViewSource',this);return false;">view plain</a><a href="#" class="CopyToClipboard" title="copy" onclick="dp.sh.Toolbar.Command('CopyToClipboard',this);return false;">copy</a><a href="#" class="PrintSource" title="print" onclick="dp.sh.Toolbar.Command('PrintSource',this);return false;">print</a><a href="#" class="About" title="?" onclick="dp.sh.Toolbar.Command('About',this);return false;">?</a><a href="https://code.csdn.net/snippets/81451" target="_blank" title="在CODE上查看代码片" style="text-indent:0;"><img src="https://code.csdn.net/assets/CODE_ico.png" width="12" height="12" alt="在CODE上查看代码片" style="position:relative;top:1px;left:2px;"></a><a href="https://code.csdn.net/snippets/81451/fork" target="_blank" title="派生到我的代码片" style="text-indent:0;"><img src="https://code.csdn.net/assets/ico_fork.svg" width="12" height="12" alt="派生到我的代码片" style="position:relative;top:2px;left:2px;"></a><div style="position: absolute; left: 542px; top: 5359px; width: 26px; height: 14px; z-index: 99;"><div style="display: block; cursor: pointer; text-align: center; width: 26px; height: 14px; top: auto; left: auto; position: static;"><div style="-webkit-transition: opacity 150ms ease-out; transition: opacity 150ms ease-out; background-image: url(chrome-extension://gofhjkjmkpinhpoiabjplobcaignabnl/icon_play.png); text-align: left; opacity: 0.25; border: 1px solid rgb(0, 0, 0); width: 100%; height: 100%; background-color: rgba(193, 217, 244, 0.498039); background-repeat: no-repeat no-repeat;"></div></div><embed id="ZeroClipboardMovie_2" src="http://static.blog.csdn.net/scripts/ZeroClipboard/ZeroClipboard.swf" loop="false" menu="false" quality="best" bgcolor="#ffffff" width="26" height="14" name="ZeroClipboardMovie_2" align="middle" allowscriptaccess="always" allowfullscreen="false" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" flashvars="id=2&amp;width=26&amp;height=14" wmode="transparent" style="display: none !important;"></div></div></div><ol start="1"><li class="alt"><span><span>&nbsp;&nbsp;&nbsp;&nbsp;gzip&nbsp;&nbsp;on;&nbsp;&nbsp;</span></span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;ssi&nbsp;on;&nbsp;&nbsp;</span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;root&nbsp;/data/comment;&nbsp;&nbsp;</span></li><li class=""><span>location&nbsp;/blog/list_comment&nbsp;{&nbsp;&nbsp;</span></li><li class="alt"><span>default_type&nbsp;'text/html';&nbsp;&nbsp;</span></li><li class=""><span>content_by_lua_file&nbsp;'/data/comment/list_comment.lua';&nbsp;&nbsp;</span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;&nbsp;</span></li><li class=""><span>location&nbsp;/blog/save_comment&nbsp;{&nbsp;&nbsp;</span></li><li class="alt"><span>default_type&nbsp;'text/html';&nbsp;&nbsp;</span></li><li class=""><span>content_by_lua_file&nbsp;'/data/comment/save_comment.lua';&nbsp;&nbsp;</span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;&nbsp;</span></li></ol></div><pre code_snippet_id="81451" snippet_file_name="blog_20131125_2_8462387" name="code" class="plain" style="display: none;">    gzip  on;
    ssi on;
    root /data/comment;
location /blog/list_comment {
default_type 'text/html';
content_by_lua_file '/data/comment/list_comment.lua';
    }
location /blog/save_comment {
default_type 'text/html';
content_by_lua_file '/data/comment/save_comment.lua';
    }</pre><br>
<br>
<br>
<br>
<strong>在静态页面中增加ssi代码，这样就可以把uri当做参数传递了。</strong><br>
&lt;!--# include virtual="/blog/list_comment?uri=$request_uri" --&gt;<br>
<br>
<h2><a name="t4"></a>4，mysql修改打开文件数</h2>
因为开启了分区，所以读取文件数量肯定会多。<br>
用ulimit -n查看打开文件数量。如果是1024，修改配置：
<p></p>
<p><br>
<strong>/etc/security/limits.conf 然后重启系统</strong><br>
*<span style="white-space:pre"> </span>soft &nbsp; &nbsp;noproc &nbsp;65536<br>
*<span style="white-space:pre"> </span>hard &nbsp; &nbsp;noproc &nbsp;65536<br>
*<span style="white-space:pre"> </span>soft &nbsp; &nbsp;nofile &nbsp;65536<br>
*<span style="white-space:pre"> </span>hard &nbsp; &nbsp;nofile &nbsp;65536</p>
<p><strong>然后修改my.conf配置文件：</strong><br>
vi /etc/my.cnf&nbsp;<br>
<br>
[mysqld]<br>
datadir=/var/lib/mysql<br>
socket=/var/lib/mysql/mysql.sock<br>
user=mysql<br>
symbolic-links=0<br>
<strong>open_files_limit=65536</strong><br>
<br>
<br>
重启mysql生效，查看参数：<br>
mysql&gt; show variables like 'open%';<br>
+------------------+-------+<br>
| Variable_name &nbsp; &nbsp;| Value |<br>
+------------------+-------+<br>
| open_files_limit | 65536 |<br>
+------------------+-------+<br>
1 row in set (0.00 sec)<br>
<br>
<strong>数据库表，按照设计成分区表。将数据分散。</strong></p>
<p><br>
</p><div class="dp-highlighter bg_sql"><div class="bar"><div class="tools"><b>[sql]</b> <a href="#" class="ViewSource" title="view plain" onclick="dp.sh.Toolbar.Command('ViewSource',this);return false;">view plain</a><a href="#" class="CopyToClipboard" title="copy" onclick="dp.sh.Toolbar.Command('CopyToClipboard',this);return false;">copy</a><a href="#" class="PrintSource" title="print" onclick="dp.sh.Toolbar.Command('PrintSource',this);return false;">print</a><a href="#" class="About" title="?" onclick="dp.sh.Toolbar.Command('About',this);return false;">?</a><a href="https://code.csdn.net/snippets/81451" target="_blank" title="在CODE上查看代码片" style="text-indent:0;"><img src="https://code.csdn.net/assets/CODE_ico.png" width="12" height="12" alt="在CODE上查看代码片" style="position:relative;top:1px;left:2px;"></a><a href="https://code.csdn.net/snippets/81451/fork" target="_blank" title="派生到我的代码片" style="text-indent:0;"><img src="https://code.csdn.net/assets/ico_fork.svg" width="12" height="12" alt="派生到我的代码片" style="position:relative;top:2px;left:2px;"></a><div style="position: absolute; left: 530px; top: 6623px; width: 26px; height: 14px; z-index: 99;"><div style="display: block; cursor: pointer; text-align: center; width: 26px; height: 14px; top: auto; left: auto; position: static;"><div style="-webkit-transition: opacity 150ms ease-out; transition: opacity 150ms ease-out; background-image: url(chrome-extension://gofhjkjmkpinhpoiabjplobcaignabnl/icon_play.png); text-align: left; opacity: 0.25; border: 1px solid rgb(0, 0, 0); width: 100%; height: 100%; background-color: rgba(193, 217, 244, 0.498039); background-repeat: no-repeat no-repeat;"></div></div><embed id="ZeroClipboardMovie_3" src="http://static.blog.csdn.net/scripts/ZeroClipboard/ZeroClipboard.swf" loop="false" menu="false" quality="best" bgcolor="#ffffff" width="26" height="14" name="ZeroClipboardMovie_3" align="middle" allowscriptaccess="always" allowfullscreen="false" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" flashvars="id=3&amp;width=26&amp;height=14" wmode="transparent" style="display: none !important;"></div></div></div><ol start="1" class="dp-sql"><li class="alt"><span><span class="keyword">CREATE</span><span>&nbsp;</span><span class="keyword">TABLE</span><span>&nbsp;`comment`&nbsp;(&nbsp;&nbsp;</span></span></li><li class=""><span>&nbsp;&nbsp;`id`&nbsp;<span class="keyword">int</span><span>(11)&nbsp;</span><span class="op">NOT</span><span>&nbsp;</span><span class="op">NULL</span><span>&nbsp;auto_increment&nbsp;COMMENT&nbsp;</span><span class="string">'主键'</span><span>,&nbsp;&nbsp;</span></span></li><li class="alt"><span>&nbsp;&nbsp;`item_id`&nbsp;<span class="keyword">int</span><span>(11)&nbsp;</span><span class="op">NOT</span><span>&nbsp;</span><span class="op">NULL</span><span>&nbsp;COMMENT&nbsp;</span><span class="string">'评论项id'</span><span>,&nbsp;&nbsp;</span></span></li><li class=""><span>&nbsp;&nbsp;`uid`&nbsp;<span class="keyword">int</span><span>(11)&nbsp;</span><span class="op">NOT</span><span>&nbsp;</span><span class="op">NULL</span><span>&nbsp;</span><span class="keyword">default</span><span>&nbsp;</span><span class="string">'0'</span><span>&nbsp;COMMENT&nbsp;</span><span class="string">'评论用户'</span><span>,&nbsp;&nbsp;</span></span></li><li class="alt"><span>&nbsp;&nbsp;`content`&nbsp;text&nbsp;<span class="op">NOT</span><span>&nbsp;</span><span class="op">NULL</span><span>&nbsp;COMMENT&nbsp;</span><span class="string">'内容'</span><span>,&nbsp;&nbsp;</span></span></li><li class=""><span>&nbsp;&nbsp;`create_time`&nbsp;datetime&nbsp;<span class="op">NOT</span><span>&nbsp;</span><span class="op">NULL</span><span>&nbsp;&nbsp;COMMENT&nbsp;</span><span class="string">'创建时间'</span><span>,&nbsp;&nbsp;</span></span></li><li class="alt"><span>&nbsp;&nbsp;<span class="keyword">PRIMARY</span><span>&nbsp;</span><span class="keyword">KEY</span><span>&nbsp;&nbsp;(`item_id`,`id`)&nbsp;&nbsp;</span></span></li><li class=""><span>)&nbsp;ENGINE=MyISAM&nbsp;<span class="keyword">DEFAULT</span><span>&nbsp;CHARSET=utf8&nbsp;&nbsp;</span></span></li><li class="alt"><span>PARTITION&nbsp;<span class="keyword">BY</span><span>&nbsp;HASH&nbsp;(`item_id`)&nbsp;&nbsp;</span></span></li><li class=""><span>PARTITIONS&nbsp;1024;&nbsp;&nbsp;</span></li></ol></div><pre code_snippet_id="81451" snippet_file_name="blog_20131125_3_8255427" name="code" class="sql" style="display: none;">CREATE TABLE `comment` (
  `id` int(11) NOT NULL auto_increment COMMENT '主键',
  `item_id` int(11) NOT NULL COMMENT '评论项id',
  `uid` int(11) NOT NULL default '0' COMMENT '评论用户',
  `content` text NOT NULL COMMENT '内容',
  `create_time` datetime NOT NULL  COMMENT '创建时间',
  PRIMARY KEY  (`item_id`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8
PARTITION BY HASH (`item_id`)
PARTITIONS 1024;</pre><br>
<br>
<br>
<strong>插入测试数据：</strong><br>
insert into comment(`item_id`,content,create_time) values(127,CONCAT("conent test ",RAND()*1000),now());<br>
<br>
<strong>源代码放到github上了。</strong><p></p>
<p><strong><br>
</strong><a target="_blank" href="https://github.com/luapkg/comment/">https://github.com/luapkg/comment/</a><br>
</p>
<p>继续完善评论模块。</p>

</div>

 
