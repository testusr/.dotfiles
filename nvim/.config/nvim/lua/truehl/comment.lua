print ("hello from comment")
local setup, comment = pcall(require, "Comment")
if not setup then
  return
end

comment.setup()
