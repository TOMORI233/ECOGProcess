function untitled(rootPath, keyword)
temp = dir(strcat(rootPath, "\**\*"));
mPath = string({temp.name}');
dirIndex = ~cellfun(@isempty, regexp(mPath, keyword)) & vertcat(temp.isdir);
fileIndex =  ~cellfun(@isempty, regexp(mPath, keyword)) & ~vertcat(temp.isdir);
% delete folders
cellfun(@(x) rmdir(x, "s"), cellstr(mPath(dirIndex)), "uni", false);
% delete files
cellfun(@(x) delete(x, "s"), mPath(fileIndex), "uni", false);
end

