
local mysql= require("resty.mysql")
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

<li id="cmt_" class="row_1">
	<table width=""><tr>
		<td class="portrait">
			<a href="" name="rpl_277051035" class="ShowUserOutline"><img src="http://www.oschina.net/img/portrait.gif"></a>
		</td>
		<td class="body">
			<div class="r_title">
				%s楼：<b>%s</b>  发表于%s
			</div>
			<div class="r_content TextContent">%s</div>
		</td></tr>
	</table>
</li>

]]

--设置顶部内容.
local comment_html = [[

<div class="Comments" id="userComments">
<h2>
	<a name="comments" href="#" class="more">回到顶部</a>
	<a href="#CommentForm" class="more" style="margin-right:10px;color:#ff3;">发表评论</a>
	网友评论，共 %s条
</h2>
<ul>
%s
</ul>
	<ul class="pager">
		%s
    </ul>
</div>

]]

--设置循环li
local page_li = [[
<li class="page %s"><a href="?start=%s#comments">%s</a></li>
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
		page_html = page_html..[[<li class="page prev"><a href="?start=]]
		page_html = page_html..(current_page-2)*limit
		page_html = page_html..[[#comments">&lt;</a></li>
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
		page_html = page_html..[[<li class="page next"><a href="?start=]]
		page_html = page_html..current_page*limit
		page_html = page_html..[[#comments">&gt;</a></li>
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

if count and #count > 0 then
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
ngx.say(html)
