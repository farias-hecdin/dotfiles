local uv = vim.uv or vim.loop
local tmpdir = assert(uv.fs_mkdtemp(uv.os_tmpdir() .. '/XXXXXX'))
local nfiles = 1e3

-- Create files
for i = 1, nfiles, 1 do
  local fd = assert(
    uv.fs_open(
      tmpdir .. '/' .. tostring(i),
      uv.constants.O_CREAT + uv.constants.O_EXCL,
      511
    )
  )

  assert(uv.fs_close(fd))
end

local t = uv.hrtime()

for i = 1, nfiles, 1 do
  local _stat = assert(uv.fs_stat(tmpdir .. '/' .. tostring(i)))
end

print(
  'time to stat ' .. tostring(nfiles) .. ' files (sync):',
  (uv.hrtime() - t) / 1e6,
  'ms'
)

local cnt = 0

local function proc_stat(err, stat)
  cnt = cnt + 1
  if cnt == nfiles then
    print(
      'time to stat ' .. tostring(nfiles) .. ' files (async):',
      (uv.hrtime() - t) / 1e6,
      'ms'
    )
    vim.schedule(function() vim.fn.delete(tmpdir, 'rf') end)
  end
  assert(stat, err)
end

t = uv.hrtime()

for i = 1, nfiles, 1 do
  uv.fs_stat(tmpdir .. '/' .. tostring(i), proc_stat)
end
