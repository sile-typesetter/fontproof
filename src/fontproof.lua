local bin = arg[0]
local sile = "sile"

local args = table.concat(arg, " ")

local _, status, signal = os.execute(("%s -e 'print(%s)' -e 'os.exit(1)' %s"):format(sile, 44, args))

if status == "exit" then
	os.exit(signal)
else
	error(("Interupted with signal %s"):format(signal))
	os.exit(1)
end
