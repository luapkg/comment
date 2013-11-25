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
<h2><a name="t2"></a>2，主要代码</h2>
<p></p>
<p></p>
<div class="dp-highlighter bg_javascript"><div class="bar"><div class="tools"><b>[javascript]</b> <a href="#" class="ViewSource" title="view plain" onclick="dp.sh.Toolbar.Command('ViewSource',this);return false;">view plain</a><a href="#" class="CopyToClipboard" title="copy" onclick="dp.sh.Toolbar.Command('CopyToClipboard',this);return false;">copy</a><a href="#" class="PrintSource" title="print" onclick="dp.sh.Toolbar.Command('PrintSource',this);return false;">print</a><a href="#" class="About" title="?" onclick="dp.sh.Toolbar.Command('About',this);return false;">?</a><a href="https://code.csdn.net/snippets/81451" target="_blank" title="在CODE上查看代码片" style="text-indent:0;"><img src="https://code.csdn.net/assets/CODE_ico.png" width="12" height="12" alt="在CODE上查看代码片" style="position:relative;top:1px;left:2px;"></a><a href="https://code.csdn.net/snippets/81451/fork" target="_blank" title="派生到我的代码片" style="text-indent:0;"><img src="https://code.csdn.net/assets/ico_fork.svg" width="12" height="12" alt="派生到我的代码片" style="position:relative;top:2px;left:2px;"></a><div style="position: absolute; left: 573px; top: 1765px; width: 26px; height: 14px; z-index: 99;"><div style="display: block; cursor: pointer; text-align: center; width: 26px; height: 14px; top: auto; left: auto; position: static;"><div style="-webkit-transition: opacity 150ms ease-out; transition: opacity 150ms ease-out; background-image: url(chrome-extension://gofhjkjmkpinhpoiabjplobcaignabnl/icon_play.png); text-align: left; opacity: 0.25; border: 1px solid rgb(0, 0, 0); width: 100%; height: 100%; background-color: rgba(193, 217, 244, 0.498039); background-repeat: no-repeat no-repeat;"></div></div><embed id="ZeroClipboardMovie_1" src="http://static.blog.csdn.net/scripts/ZeroClipboard/ZeroClipboard.swf" loop="false" menu="false" quality="best" bgcolor="#ffffff" width="26" height="14" name="ZeroClipboardMovie_1" align="middle" allowscriptaccess="always" allowfullscreen="false" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" flashvars="id=1&amp;width=26&amp;height=14" wmode="transparent" style="display: none !important;"></div></div></div><ol start="1" class="dp-c"><li class="alt"><span><span>local&nbsp;mysql=&nbsp;require(</span><span class="string">"resty.mysql"</span><span>)&nbsp;&nbsp;</span></span></li><li class=""><span>--评论查询.&nbsp;&nbsp;</span></li><li class="alt"><span>local&nbsp;<span class="keyword">function</span><span>&nbsp;query_mysql(sql)&nbsp;&nbsp;</span></span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;local&nbsp;db&nbsp;=&nbsp;mysql:<span class="keyword">new</span><span>()&nbsp;&nbsp;</span></span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;db:connect{&nbsp;&nbsp;</span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;host&nbsp;=&nbsp;<span class="string">"127.0.0.1"</span><span>,&nbsp;&nbsp;</span></span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;port&nbsp;=&nbsp;3306,&nbsp;&nbsp;</span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;database&nbsp;=&nbsp;<span class="string">"test"</span><span>,&nbsp;&nbsp;</span></span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;user&nbsp;=&nbsp;<span class="string">"root"</span><span>,&nbsp;&nbsp;</span></span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;password&nbsp;=&nbsp;<span class="string">"root"</span><span>&nbsp;&nbsp;</span></span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;&nbsp;</span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;local&nbsp;res,&nbsp;err,&nbsp;errno,&nbsp;sqlstate&nbsp;=&nbsp;db:query(sql)&nbsp;&nbsp;</span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;--使用数据库连接池。保持连接.&nbsp;&nbsp;</span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;db:set_keepalive(0,&nbsp;100)&nbsp;&nbsp;</span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">return</span><span>&nbsp;res&nbsp;&nbsp;</span></span></li><li class=""><span>end&nbsp;&nbsp;</span></li><li class="alt"><span>&nbsp;&nbsp;</span></li><li class=""><span>local&nbsp;comment_li&nbsp;=&nbsp;[[&nbsp;&nbsp;</span></li><li class="alt"><span>&nbsp;&nbsp;</span></li><li class=""><span>&lt;li&nbsp;id=<span class="string">"cmt_"</span><span>&nbsp;</span><span class="keyword">class</span><span>=</span><span class="string">"row_1"</span><span>&gt;&nbsp;&nbsp;</span></span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&lt;table&nbsp;width=<span class="string">""</span><span>&gt;&lt;tr&gt;&nbsp;&nbsp;</span></span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;td&nbsp;<span class="keyword">class</span><span>=</span><span class="string">"portrait"</span><span>&gt;&nbsp;&nbsp;</span></span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;a&nbsp;href=<span class="string">""</span><span>&nbsp;name=</span><span class="string">"rpl_277051035"</span><span>&nbsp;</span><span class="keyword">class</span><span>=</span><span class="string">"ShowUserOutline"</span><span>&gt;&lt;img&nbsp;src=</span><span class="string">"http://www.oschina.net/img/portrait.gif"</span><span>&gt;&lt;/a&gt;&nbsp;&nbsp;</span></span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;/td&gt;&nbsp;&nbsp;</span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;td&nbsp;<span class="keyword">class</span><span>=</span><span class="string">"body"</span><span>&gt;&nbsp;&nbsp;</span></span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;div&nbsp;<span class="keyword">class</span><span>=</span><span class="string">"r_title"</span><span>&gt;&nbsp;&nbsp;</span></span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;%s楼：&lt;b&gt;%s&lt;/b&gt;&nbsp;&nbsp;发表于%s&nbsp;&nbsp;</span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;/div&gt;&nbsp;&nbsp;</span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;div&nbsp;<span class="keyword">class</span><span>=</span><span class="string">"r_content&nbsp;TextContent"</span><span>&gt;%s&lt;/div&gt;&nbsp;&nbsp;</span></span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;/td&gt;&lt;/tr&gt;&nbsp;&nbsp;</span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&lt;/table&gt;&nbsp;&nbsp;</span></li><li class=""><span>&lt;/li&gt;&nbsp;&nbsp;</span></li><li class="alt"><span>&nbsp;&nbsp;</span></li><li class=""><span>]]&nbsp;&nbsp;</span></li><li class="alt"><span>&nbsp;&nbsp;</span></li><li class=""><span>--设置顶部内容.&nbsp;&nbsp;</span></li><li class="alt"><span>local&nbsp;comment_html&nbsp;=&nbsp;[[&nbsp;&nbsp;</span></li><li class=""><span>&nbsp;&nbsp;</span></li><li class="alt"><span>&lt;div&nbsp;<span class="keyword">class</span><span>=</span><span class="string">"Comments"</span><span>&nbsp;id=</span><span class="string">"userComments"</span><span>&gt;&nbsp;&nbsp;</span></span></li><li class=""><span>&lt;h2&gt;&nbsp;&nbsp;</span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&lt;a&nbsp;name=<span class="string">"comments"</span><span>&nbsp;href=</span><span class="string">"#"</span><span>&nbsp;</span><span class="keyword">class</span><span>=</span><span class="string">"more"</span><span>&gt;回到顶部&lt;/a&gt;&nbsp;&nbsp;</span></span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;&lt;a&nbsp;href=<span class="string">"#CommentForm"</span><span>&nbsp;</span><span class="keyword">class</span><span>=</span><span class="string">"more"</span><span>&nbsp;style=</span><span class="string">"margin-right:10px;color:#ff3;"</span><span>&gt;发表评论&lt;/a&gt;&nbsp;&nbsp;</span></span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;网友评论，共&nbsp;%s条&nbsp;&nbsp;</span></li><li class=""><span>&lt;/h2&gt;&nbsp;&nbsp;</span></li><li class="alt"><span>&lt;ul&gt;&nbsp;&nbsp;</span></li><li class=""><span>%s&nbsp;&nbsp;</span></li><li class="alt"><span>&lt;/ul&gt;&nbsp;&nbsp;</span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;&lt;ul&nbsp;<span class="keyword">class</span><span>=</span><span class="string">"pager"</span><span>&gt;&nbsp;&nbsp;</span></span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;%s&nbsp;&nbsp;</span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;&lt;/ul&gt;&nbsp;&nbsp;</span></li><li class="alt"><span>&lt;/div&gt;&nbsp;&nbsp;</span></li><li class=""><span>&nbsp;&nbsp;</span></li><li class="alt"><span>]]&nbsp;&nbsp;</span></li><li class=""><span>&nbsp;&nbsp;</span></li><li class="alt"><span>--设置循环li&nbsp;&nbsp;</span></li><li class=""><span>local&nbsp;page_li&nbsp;=&nbsp;[[&nbsp;&nbsp;</span></li><li class="alt"><span>&lt;li&nbsp;<span class="keyword">class</span><span>=</span><span class="string">"page&nbsp;%s"</span><span>&gt;&lt;a&nbsp;href=</span><span class="string">"?start=%s#comments"</span><span>&gt;%s&lt;/a&gt;&lt;/li&gt;&nbsp;&nbsp;</span></span></li><li class=""><span>]]&nbsp;&nbsp;</span></li><li class="alt"><span>--输入参数&nbsp;count&nbsp;start&nbsp;limit&nbsp;，总数，开始，分页限制&nbsp;&nbsp;</span></li><li class=""><span>local&nbsp;<span class="keyword">function</span><span>&nbsp;page(count,start,limit)&nbsp;&nbsp;</span></span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;--print(count,start,limit)&nbsp;&nbsp;</span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;local&nbsp;page&nbsp;=&nbsp;math.ceil(count/limit)&nbsp;&nbsp;</span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;local&nbsp;current_page&nbsp;=&nbsp;math.floor(start/limit)&nbsp;+&nbsp;1&nbsp;&nbsp;</span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;--判断当前页面不超出分页范围.&nbsp;&nbsp;</span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;current_page&nbsp;=&nbsp;math.min(current_page,page)&nbsp;&nbsp;</span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;current_page&nbsp;=&nbsp;math.max(current_page,1)&nbsp;&nbsp;</span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;local&nbsp;is_first&nbsp;=&nbsp;(&nbsp;current_page&nbsp;==&nbsp;1&nbsp;)&nbsp;&nbsp;</span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;local&nbsp;is_last&nbsp;=&nbsp;(&nbsp;current_page&nbsp;==&nbsp;page&nbsp;)&nbsp;&nbsp;</span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;--打印页数，开始，结束.&nbsp;&nbsp;</span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;local&nbsp;page_offset&nbsp;=&nbsp;3&nbsp;&nbsp;</span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;local&nbsp;start_page&nbsp;=&nbsp;math.max(current_page&nbsp;-&nbsp;page_offset&nbsp;,1)&nbsp;&nbsp;</span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;local&nbsp;end_page&nbsp;=&nbsp;math.min(current_page&nbsp;+&nbsp;page_offset&nbsp;,page)&nbsp;&nbsp;</span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;local&nbsp;page_html&nbsp;=&nbsp;<span class="string">""</span><span>&nbsp;&nbsp;</span></span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">if</span><span>&nbsp;not&nbsp;is_first&nbsp;then&nbsp;&nbsp;</span></span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;page_html&nbsp;=&nbsp;page_html..[[&lt;li&nbsp;<span class="keyword">class</span><span>=</span><span class="string">"page&nbsp;prev"</span><span>&gt;&lt;a&nbsp;href="?start=]]&nbsp;&nbsp;</span></span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;page_html&nbsp;=&nbsp;page_html..(current_page-2)*limit&nbsp;&nbsp;</span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;page_html&nbsp;=&nbsp;page_html..[[#comments"&gt;&lt;&lt;/a&gt;&lt;/li&gt;&nbsp;&nbsp;</span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]]&nbsp;&nbsp;</span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;end&nbsp;&nbsp;</span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">for</span><span>&nbsp;i&nbsp;=&nbsp;start_page&nbsp;,&nbsp;end_page&nbsp;&nbsp;</span><span class="keyword">do</span><span>&nbsp;&nbsp;</span></span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;local&nbsp;tmp_current&nbsp;=&nbsp;<span class="string">""</span><span>&nbsp;&nbsp;</span></span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">if</span><span>&nbsp;current_page&nbsp;==&nbsp;i&nbsp;then&nbsp;&nbsp;</span></span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tmp_current&nbsp;=&nbsp;<span class="string">"current"</span><span>&nbsp;&nbsp;</span></span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;end&nbsp;&nbsp;</span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;local&nbsp;tmp_div&nbsp;=&nbsp;string.format(page_li,tmp_current,(i-1)*limit,i)&nbsp;&nbsp;</span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;page_html&nbsp;=&nbsp;page_html..tmp_div&nbsp;&nbsp;</span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;end&nbsp;&nbsp;</span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">if</span><span>&nbsp;not&nbsp;is_last&nbsp;then&nbsp;&nbsp;</span></span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;page_html&nbsp;=&nbsp;page_html..[[&lt;li&nbsp;<span class="keyword">class</span><span>=</span><span class="string">"page&nbsp;next"</span><span>&gt;&lt;a&nbsp;href="?start=]]&nbsp;&nbsp;</span></span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;page_html&nbsp;=&nbsp;page_html..current_page*limit&nbsp;&nbsp;</span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;page_html&nbsp;=&nbsp;page_html..[[#comments"&gt;&gt;&lt;/a&gt;&lt;/li&gt;&nbsp;&nbsp;</span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]]&nbsp;&nbsp;</span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;end&nbsp;&nbsp;</span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">return</span><span>&nbsp;page_html&nbsp;&nbsp;</span></span></li><li class="alt"><span>end&nbsp;&nbsp;</span></li><li class=""><span>&nbsp;&nbsp;</span></li><li class="alt"><span>--接收参数。&nbsp;&nbsp;</span></li><li class=""><span>local&nbsp;uri&nbsp;=&nbsp;ngx.<span class="keyword">var</span><span>.arg_uri&nbsp;&nbsp;</span></span></li><li class="alt"><span>--使用正则过滤url中的参数。&nbsp;&nbsp;</span></li><li class=""><span>local&nbsp;year,item_id&nbsp;=&nbsp;string.match(uri,<span class="string">"/blog/(%d+)/(%d+).html"</span><span>)&nbsp;&nbsp;</span></span></li><li class="alt"><span>local&nbsp;start&nbsp;=&nbsp;string.match(uri,<span class="string">"start=(%d+)"</span><span>)&nbsp;or&nbsp;</span><span class="string">"0"</span><span>&nbsp;&nbsp;</span></span></li><li class=""><span>&nbsp;&nbsp;</span></li><li class="alt"><span>start&nbsp;=&nbsp;tonumber(start)--将字符串转换成数字。&nbsp;&nbsp;</span></li><li class=""><span>local&nbsp;limit&nbsp;=&nbsp;10&nbsp;&nbsp;</span></li><li class="alt"><span>--拼接sql。&nbsp;&nbsp;</span></li><li class=""><span>&nbsp;&nbsp;</span></li><li class="alt"><span>local&nbsp;count_sql&nbsp;=&nbsp;<span class="string">"&nbsp;select&nbsp;count(*)&nbsp;as&nbsp;count&nbsp;from&nbsp;comment&nbsp;where&nbsp;item_id&nbsp;=&nbsp;"</span><span>..item_id&nbsp;&nbsp;</span></span></li><li class=""><span>local&nbsp;count&nbsp;=&nbsp;query_mysql(count_sql)&nbsp;&nbsp;</span></li><li class="alt"><span>&nbsp;&nbsp;</span></li><li class=""><span><span class="keyword">if</span><span>&nbsp;count&nbsp;and&nbsp;#count&nbsp;&gt;&nbsp;0&nbsp;then&nbsp;&nbsp;</span></span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;--对数据进行赋值.&nbsp;&nbsp;</span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;count&nbsp;&nbsp;=&nbsp;count[1].count&nbsp;&nbsp;</span></li><li class="alt"><span><span class="keyword">else</span><span>&nbsp;&nbsp;</span></span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;count&nbsp;=&nbsp;<span class="string">"0"</span><span>&nbsp;&nbsp;</span></span></li><li class="alt"><span>end&nbsp;&nbsp;</span></li><li class=""><span>count&nbsp;=&nbsp;tonumber(count)--将字符串转换成数字。&nbsp;&nbsp;</span></li><li class="alt"><span>&nbsp;&nbsp;</span></li><li class=""><span>local&nbsp;sql&nbsp;=&nbsp;<span class="string">"&nbsp;select&nbsp;id,uid,content,create_time&nbsp;from&nbsp;comment&nbsp;where&nbsp;item_id&nbsp;=&nbsp;"</span><span>..item_id..</span><span class="string">"&nbsp;limit&nbsp;"</span><span>..start..</span><span class="string">","</span><span>..limit&nbsp;&nbsp;</span></span></li><li class="alt"><span>local&nbsp;res&nbsp;=&nbsp;query_mysql(sql)&nbsp;&nbsp;</span></li><li class=""><span>&nbsp;&nbsp;</span></li><li class="alt"><span>local&nbsp;comment_lis&nbsp;=&nbsp;<span class="string">""</span><span>&nbsp;&nbsp;</span></span></li><li class=""><span><span class="keyword">for</span><span>&nbsp;key,val&nbsp;</span><span class="keyword">in</span><span>&nbsp;pairs(res)&nbsp;</span><span class="keyword">do</span><span>&nbsp;&nbsp;</span></span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;local&nbsp;id&nbsp;=&nbsp;val[<span class="string">"id"</span><span>]&nbsp;&nbsp;</span></span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;local&nbsp;uid&nbsp;=&nbsp;val[<span class="string">"uid"</span><span>]&nbsp;&nbsp;</span></span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;local&nbsp;content&nbsp;=&nbsp;val[<span class="string">"content"</span><span>]&nbsp;&nbsp;</span></span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;local&nbsp;create_time&nbsp;=&nbsp;val[<span class="string">"create_time"</span><span>]&nbsp;&nbsp;</span></span></li><li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;--拼接字符串.&nbsp;&nbsp;</span></li><li class=""><span>&nbsp;&nbsp;&nbsp;&nbsp;comment_lis&nbsp;=&nbsp;comment_lis..string.format(comment_li,key,uid,create_time,content)&nbsp;&nbsp;</span></li><li class="alt"><span>end&nbsp;&nbsp;</span></li><li class=""><span>&nbsp;&nbsp;</span></li><li class="alt"><span>local&nbsp;page_lis&nbsp;=&nbsp;page(count,start,limit)&nbsp;&nbsp;</span></li><li class=""><span>local&nbsp;html&nbsp;=&nbsp;string.format(comment_html,count,comment_lis,page_lis)&nbsp;&nbsp;</span></li><li class="alt"><span>ngx.say(html)&nbsp;&nbsp;</span></li></ol></div><pre code_snippet_id="81451" snippet_file_name="blog_20131125_1_5205277" name="code" class="javascript" style="display: none;">local mysql= require("resty.mysql")
--评论查询.
local function query_mysql(sql)
	local db = mysql:new()
	db:connect{
		host = "127.0.0.1",
		port = 3306,
		database = "test",
		user = "root",
		password = "root"
	}
	local res, err, errno, sqlstate = db:query(sql)
	--使用数据库连接池。保持连接.
	db:set_keepalive(0, 100)
	return res
end

local comment_li = [[

&lt;li id="cmt_" class="row_1"&gt;
	&lt;table width=""&gt;&lt;tr&gt;
		&lt;td class="portrait"&gt;
			&lt;a href="" name="rpl_277051035" class="ShowUserOutline"&gt;&lt;img src="http://www.oschina.net/img/portrait.gif"&gt;&lt;/a&gt;
		&lt;/td&gt;
		&lt;td class="body"&gt;
			&lt;div class="r_title"&gt;
				%s楼：&lt;b&gt;%s&lt;/b&gt;  发表于%s
			&lt;/div&gt;
			&lt;div class="r_content TextContent"&gt;%s&lt;/div&gt;
		&lt;/td&gt;&lt;/tr&gt;
	&lt;/table&gt;
&lt;/li&gt;

]]

--设置顶部内容.
local comment_html = [[

&lt;div class="Comments" id="userComments"&gt;
&lt;h2&gt;
	&lt;a name="comments" href="#" class="more"&gt;回到顶部&lt;/a&gt;
	&lt;a href="#CommentForm" class="more" style="margin-right:10px;color:#ff3;"&gt;发表评论&lt;/a&gt;
	网友评论，共 %s条
&lt;/h2&gt;
&lt;ul&gt;
%s
&lt;/ul&gt;
	&lt;ul class="pager"&gt;
		%s
    &lt;/ul&gt;
&lt;/div&gt;

]]

--设置循环li
local page_li = [[
&lt;li class="page %s"&gt;&lt;a href="?start=%s#comments"&gt;%s&lt;/a&gt;&lt;/li&gt;
]]
--输入参数 count start limit ，总数，开始，分页限制
local function page(count,start,limit)
	--print(count,start,limit)
	local page = math.ceil(count/limit)
	local current_page = math.floor(start/limit) + 1
	--判断当前页面不超出分页范围.
	current_page = math.min(current_page,page)
	current_page = math.max(current_page,1)
	local is_first = ( current_page == 1 )
	local is_last = ( current_page == page )
	--打印页数，开始，结束.
	local page_offset = 3
	local start_page = math.max(current_page - page_offset ,1)
	local end_page = math.min(current_page + page_offset ,page)
	local page_html = ""
	if not is_first then
		page_html = page_html..[[&lt;li class="page prev"&gt;&lt;a href="?start=]]
		page_html = page_html..(current_page-2)*limit
		page_html = page_html..[[#comments"&gt;&lt;&lt;/a&gt;&lt;/li&gt;
		]]
	end
	for i = start_page , end_page  do
		local tmp_current = ""
		if current_page == i then
			tmp_current = "current"
		end
		local tmp_div = string.format(page_li,tmp_current,(i-1)*limit,i)
		page_html = page_html..tmp_div
	end
	if not is_last then
		page_html = page_html..[[&lt;li class="page next"&gt;&lt;a href="?start=]]
		page_html = page_html..current_page*limit
		page_html = page_html..[[#comments"&gt;&gt;&lt;/a&gt;&lt;/li&gt;
		]]
	end
	return page_html
end

--接收参数。
local uri = ngx.var.arg_uri
--使用正则过滤url中的参数。
local year,item_id = string.match(uri,"/blog/(%d+)/(%d+).html")
local start = string.match(uri,"start=(%d+)") or "0"

start = tonumber(start)--将字符串转换成数字。
local limit = 10
--拼接sql。

local count_sql = " select count(*) as count from comment where item_id = "..item_id
local count = query_mysql(count_sql)

if count and #count &gt; 0 then
	--对数据进行赋值.
	count  = count[1].count
else
	count = "0"
end
count = tonumber(count)--将字符串转换成数字。

local sql = " select id,uid,content,create_time from comment where item_id = "..item_id.." limit "..start..","..limit
local res = query_mysql(sql)

local comment_lis = ""
for key,val in pairs(res) do
	local id = val["id"]
	local uid = val["uid"]
	local content = val["content"]
	local create_time = val["create_time"]
	--拼接字符串.
	comment_lis = comment_lis..string.format(comment_li,key,uid,create_time,content)
end

local page_lis = page(count,start,limit)
local html = string.format(comment_html,count,comment_lis,page_lis)
ngx.say(html)</pre><br>
代码将功能实现了。后续可以拆分成多个模块。其中生成分页部分比较复杂。
<p></p>
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



<!-- Baidu Button BEGIN -->
<div id="bdshare" class="bdshare_t bds_tools get-codes-bdshare" style="float: right;">
<a class="bds_qzone" title="分享到QQ空间" href="#"></a>
<a class="bds_tsina" title="分享到新浪微博" href="#"></a>
<a class="bds_tqq" title="分享到腾讯微博" href="#"></a>
<a class="bds_renren" title="分享到人人网" href="#"></a>
<a class="bds_t163" title="分享到网易微博" href="#"></a>
<span class="bds_more">更多</span>
<a class="shareCount" href="#" title="累计分享0次">0</a>
</div>
<!-- Baidu Button END -->


<!--192.168.100.34-->
<div class="article_next_prev">
            <li class="prev_article"><span>上一篇：</span><a href="/freewebsys/article/details/16913159">【程序员：你不是真正的快乐】</a></li>
</div>

<!-- Baidu Button BEGIN -->
<script type="text/javascript" id="bdshare_js" data="type=tools&amp;uid=1536434" src="http://bdimg.share.baidu.com/static/js/bds_s_v2.js?cdnversion=384829"></script>

<script type="text/javascript">
    document.getElementById("bdshell_js").src = "http://bdimg.share.baidu.com/static/js/shell_v2.js?cdnversion=" + Math.ceil(new Date()/3600000)
</script>
<!-- Baidu Button END -->

        <div id="digg" articleid="16944917">
            <dl id="btnDigg" class="digg digg_enable">
                <dt>顶</dt>
                <dd>0</dd>
            </dl>
            <dl id="btnBury" class="digg digg_enable">
                <dt>踩</dt>
                <dd>0</dd>
            </dl>
        </div>
</div>
    <div id="ad_cen">
        <script type="text/javascript">            BAIDU_CLB_SLOT_ID = "117306";</script>
        <script type="text/javascript" src="http://cbjs.baidu.com/js/o.js"></script>
    </div>
    <script type="text/javascript">
        //new Ad(4, 'ad_cen');
    </script>
<div id="comment_title" class="panel_head">
    查看评论<a name="comments"></a></div>
<div id="comment_list"><br>&nbsp;&nbsp;暂无评论<br><br><div class="clear"></div></div>
<div id="comment_bar">
</div>
<div id="comment_form"><a name="commentbox"></a><a name="reply"></a><a name="quote"></a><form action="/freewebsys/comment/submit?id=16944917" method="post" onsubmit="return subform(this);"><div class="commentform"><div class="panel_head">发表评论</div><ul><li class="left">用 户 名：</li><li class="right">freewebsys</li></ul><ul><li class="left">评论内容：</li><li class="right" style="position:relative;"><div id="ubbtools"><a href="#insertcode" code="code"><img src="http://static.blog.csdn.net/images/ubb/code.gif" border="0" alt="插入代码" title="插入代码"></a></div><div id="lang_list" style="position: absolute; top: 28px; left: 0px; display: none;"><a class="long_name" href="#html">HTML/XML</a><a class="long_name" href="#objc">objective-c</a><a class="zhong_name" href="#delphi">Delphi</a><a class="zhong_name" href="#ruby">Ruby</a><a href="#php">PHP</a><a class="duan_name" href="#csharp">C#</a><a style=" border-right: none;" class="duan_name" href="#cpp">C++</a><a style=" border-bottom:none;" class="long_name" href="#javascript">JavaScript</a><a style=" border-bottom:none;" class="long_name" href="#vb">Visual Basic</a><a style=" border-bottom:none;" class="zhong_name" href="#python">Python</a><a style=" border-bottom:none;" class="zhong_name" href="#java">Java</a><a style="border-bottom:none;" class="duan_name" href="#css">CSS</a><a style="border-bottom:none;" class="duan_name" href="#sql">SQL</a><a style="border:none;" class="duan_name" href="#plain">其它</a></div><textarea class="comment_content" name="comment_content" id="comment_content" style="width: 400px; height: 200px;"></textarea></li></ul><ul><input type="hidden" id="comment_replyId" name="comment_replyId"><input type="hidden" id="comment_userId" name="comment_userId" value="521203"><input type="hidden" id="commentId" name="commentId" value=""><input type="submit" class="comment_btn" value="提交">&nbsp;&nbsp;<span id="tip_comment" style="color: Red; display: none;"></span></ul></div></form></div>
<div class="announce">
    * 以上用户言论只代表其个人观点，不代表CSDN网站的观点或立场<a name="reply"></a><a name="quote"></a></div>
<script type="text/javascript">
    var fileName = '16944917';
    var commentscount = 0;
    var islock = false
</script>
<script type="text/javascript" src="http://static.blog.csdn.net/scripts/comment.js"></script>
    <div id="ad_bot">
    </div>
    <script type="text/javascript">
    new Ad(5, 'ad_bot');
    </script>
<div id="report_dialog">
</div>
<div id="d-top" style="display: none;">
    <a id="d-top-a" href="#" title="回到顶部">
        <img src="http://static.blog.csdn.net/images/top.png" alt="TOP"></a>
</div>
<script type="text/javascript">
    $(function ()
    {
        var d_top = $('#d-top');
        document.onscroll = function ()
        {
            var scrTop = (document.body.scrollTop || document.documentElement.scrollTop);
            if (scrTop > 500)
            {
                d_top.show();
            } else
            {
                d_top.hide();
            }
        }
        $('#d-top-a').click(function ()
        {
            scrollTo(0, 0);
            this.blur();
            return false;
        });
    });
  
</script>
<style type="text/css">
    .tag_list
    {
        background: none repeat scroll 0 0 #FFFFFF;
        border: 1px solid #D7CBC1;
        color: #000000;
        font-size: 12px;
        line-height: 20px;
        list-style: none outside none;
        margin: 10px 2% 0 1%;
        padding: 1px;
    }
    .tag_list h5
    {
        background: none repeat scroll 0 0 #E0DBD3;
        color: #47381C;
        font-size: 12px;
        height: 24px;
        line-height: 24px;
        padding: 0 5px;
        margin: 0;
    }
    .tag_list h5 a
    {
        color: #47381C;
    }
    .classify
    {
        margin: 10px 0;
        padding: 4px 12px 8px;
    }
    .classify a
    {
        margin-right: 20px;
        white-space: nowrap;
    }
</style>
<div class="tag_list">
    <h5>
        <a href="http://www.csdn.net/tag/" target="_blank">核心技术类目</a></h5>
    <div class="classify">
        <a title="全部主题" href="http://www.csdn.net/tag" target="_blank" onclick="LogClickCount(this,336);">
            全部主题</a> <a title="数据挖掘" href="http://www.csdn.net/tag/数据挖掘" target="_blank" onclick="LogClickCount(this,336);">
                数据挖掘</a> <a title="SOA" href="http://www.csdn.net/tag/soa" target="_blank" onclick="LogClickCount(this,336);">
                    SOA</a> <a title="UML" href="http://www.csdn.net/tag/uml" target="_blank" onclick="LogClickCount(this,336);">
                        UML</a> <a title="开放平台" href="http://www.csdn.net/tag/开放平台" target="_blank" onclick="LogClickCount(this,336);">
                            开放平台</a> <a title="HTML5" href="http://www.csdn.net/tag/HTML5" target="_blank" onclick="LogClickCount(this,336);">
                                HTML5</a> <a title="开源" href="http://www.csdn.net/tag/开源" target="_blank" onclick="LogClickCount(this,336);">
                                    开源</a> <a title="移动开发" href="http://www.csdn.net/tag/移动开发" target="_blank" onclick="LogClickCount(this,336);">
                                        移动开发</a> <a title="iOS" href="http://www.csdn.net/tag/iOS" target="_blank" onclick="LogClickCount(this,336);">
                                            iOS</a> <a title="Android" href="http://www.csdn.net/tag/android" target="_blank" onclick="LogClickCount(this,336);">Android</a>
        <a title="移动游戏" href="http://www.csdn.net/tag/移动游戏" target="_blank" onclick="LogClickCount(this,336);">
            移动游戏</a> <a title="Windows Phone" href="http://www.csdn.net/tag/Windows Phone" target="_blank" onclick="LogClickCount(this,336);">Windows Phone</a> <a title="JavaScript" href="http://www.csdn.net/tag/JavaScript" target="_blank" onclick="LogClickCount(this,336);">JavaScript</a> <a title="CSS" href="http://www.csdn.net/Tag/CSS" target="_blank" onclick="LogClickCount(this,336);">
                        CSS</a> <a title="游戏引擎" href="http://www.csdn.net/tag/游戏引擎" target="_blank" onclick="LogClickCount(this,336);">
                            游戏引擎</a> <a title="云计算" href="http://www.csdn.net/tag/云计算" target="_blank" onclick="LogClickCount(this,336);">
                                云计算</a> <a title="大数据" href="http://www.csdn.net/tag/大数据" target="_blank" onclick="LogClickCount(this,336);">
                                    大数据</a> <a title="Hadoop" href="http://www.csdn.net/tag/Hadoop" target="_blank" onclick="LogClickCount(this,336);">
                                        Hadoop</a> <a title="OpenStack" href="http://www.csdn.net/tag/OpenStack" target="_blank" onclick="LogClickCount(this,336);">OpenStack</a>
        <a title="云平台" href="http://www.csdn.net/tag/云平台" target="_blank" onclick="LogClickCount(this,336);">
            云平台</a> <a title="PHP" href="http://www.csdn.net/tag/PHP" target="_blank" onclick="LogClickCount(this,336);">
                PHP</a> <a title="MongoDB" href="http://www.csdn.net/tag/MongoDB" target="_blank" onclick="LogClickCount(this,336);">MongoDB</a> <a title="JSON" href="http://www.csdn.net/tag/JSON" target="_blank" onclick="LogClickCount(this,336);">JSON</a> <a title="Xcode" href="http://www.csdn.net/tag/Xcode" target="_blank" onclick="LogClickCount(this,336);">Xcode</a>
        <a title="Node.js" href="http://www.csdn.net/tag/Node.js" target="_blank" onclick="LogClickCount(this,336);">
            Node.js</a> <a title="前端开发" href="http://www.csdn.net/tag/前端开发" target="_blank" onclick="LogClickCount(this,336);">
                前端开发</a> <a title="神经网络" href="http://www.csdn.net/tag/神经网络" target="_blank" onclick="LogClickCount(this,336);">
                    神经网络</a> <a title="安全" href="http://www.csdn.net/tag/安全" target="_blank" onclick="LogClickCount(this,336);">
                        安全</a> <a title="Java" href="http://www.csdn.net/tag/Java" target="_blank" onclick="LogClickCount(this,336);">
                            Java</a> <a title=".NET" href="http://www.csdn.net/tag/.NET" target="_blank" onclick="LogClickCount(this,336);">
                                .NET</a> <a title="MySQL" href="http://www.csdn.net/tag/MySQL" target="_blank" onclick="LogClickCount(this,336);">
                                    MySQL</a> <a title="textview" href="http://www.csdn.net/tag/textview" target="_blank" onclick="LogClickCount(this,336);">textview</a>
        <a title="BigTable" href="http://www.csdn.net/tag/BigTable" target="_blank" onclick="LogClickCount(this,336);">
            BigTable</a> <a title="web框架" href="http://www.csdn.net/tag/web框架" target="_blank" onclick="LogClickCount(this,336);">web框架</a> <a title="SQL" href="http://www.csdn.net/tag/SQL" target="_blank" onclick="LogClickCount(this,336);">SQL</a> <a title="Redis" href="http://www.csdn.net/tag/Redis" target="_blank" onclick="LogClickCount(this,336);">Redis</a> <a title="CouchDB" href="http://www.csdn.net/tag/CouchDB" target="_blank" onclick="LogClickCount(this,336);">CouchDB</a>
        <a title="Linux" href="http://www.csdn.net/tag/Linux" target="_blank" onclick="LogClickCount(this,336);">
            Linux</a> <a title="可穿戴计算" href="http://www.csdn.net/tag/可穿戴计算" target="_blank" onclick="LogClickCount(this,336);">
                可穿戴计算</a> <a title="NoSQL" href="http://www.csdn.net/tag/NoSQL" target="_blank" onclick="LogClickCount(this,336);">
                    NoSQL</a> <a title="Ruby" href="http://www.csdn.net/tag/Ruby" target="_blank" onclick="LogClickCount(this,336);">
                        Ruby</a> <a title="API" href="http://www.csdn.net/tag/API" target="_blank" onclick="LogClickCount(this,336);">
                            API</a> <a title="GPL" href="http://www.csdn.net/tag/GPL" target="_blank" onclick="LogClickCount(this,336);">
                                GPL</a> <a title="XAML" href="http://www.csdn.net/tag/XAML" target="_blank" onclick="LogClickCount(this,336);">
                                    XAML</a> <a title="ASP.NET" href="http://www.csdn.net/tag/ASP.NET" target="_blank" onclick="LogClickCount(this,336);">ASP.NET</a> <a title="前端开发" href="http://www.csdn.net/tag/前端开发" target="_blank" onclick="LogClickCount(this,336);">前端开发</a>
        <a title="虚拟化" href="http://www.csdn.net/tag/虚拟化" target="_blank" onclick="LogClickCount(this,336);">
            虚拟化</a> <a title="框架" href="http://www.csdn.net/tag/框架" target="_blank" onclick="LogClickCount(this,336);">
                框架</a> <a title="机器学习" href="http://www.csdn.net/tag/机器学习" target="_blank" onclick="LogClickCount(this,336);">
                    机器学习</a> <a title="数据中心" href="http://www.csdn.net/tag/数据中心" target="_blank" onclick="LogClickCount(this,336);">
                        数据中心</a> <a title="IE10" href="http://www.csdn.net/tag/IE10" target="_blank" onclick="LogClickCount(this,336);">
                            IE10</a> <a title="敏捷" href="http://www.csdn.net/tag/敏捷" target="_blank" onclick="LogClickCount(this,336);">
                                敏捷</a> <a title="集群" href="http://www.csdn.net/tag/集群" target="_blank" onclick="LogClickCount(this,336);">
                                    集群</a>
    </div>
</div>

                    <div class="clear">
                    </div>
                </div>
