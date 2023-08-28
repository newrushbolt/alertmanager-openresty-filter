ngx.req.read_body()
local data = ngx.req.get_body_data()
local project_matchers = {}

function return_error(msg)
    ngx.log(ngx.ERR, msg)
    error_path = ("/errors/" .. msg .. ".html")
    ngx.redirect(error_path)
end

if data then
    local data_json = cjson.decode(data)
    if data_json['matchers'] == nil then
        ngx.exit(ngx.HTTP_BAD_REQUEST)
    else
        for _,matcher in ipairs(data_json['matchers']) do
            if matcher['name'] == 'project' then
                table.insert(project_matchers, matcher)
            end
        end
    end
else
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end

if #project_matchers == 0 then
    return_error('no_project_matcher')
end

if #project_matchers > 1 then
    return_error('several_project_matchers')
end

project_matcher = project_matchers[1]

if project_matcher['isRegex'] then
    return_error('project_matcher_is_regex')
end

-- This is an optional field
if project_matcher['isEqual'] ~= nil then
    if project_matcher['isEqual'] == false then
        return_error('project_matcher_is_inversed')
    end
end

ngx.exit(ngx.OK)
