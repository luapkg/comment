
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
	print(page,current_page,is_first,is_last,start_page,end_page)
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

local function main()

	print("#############")
	print(page(30,0,10))
	print("#############")
	print(page(30,20,10))
	print("#############")
	print(page(29,0,10))
	print("#############")
	print(page(100,0,10))
	print("#############")
	print(page(100,10,10))
	print("#############")
	print(page(100,20,10))
	print("#############")
	print(page(100,30,10))
	print("#############")
	print(page(100,40,10))
	print("#############")
	print(page(100,50,10))
	print("#############")
	print(page(100,60,10))
	print("#############")
	print(page(100,70,10))
	print("#############")
	print(page(100,80,10))
	print("#############")
	print(page(100,90,10))
	print("#############")
	print(page(100,100,10))
	print("#############")
	print(page(100,-100,10))
end
main()
