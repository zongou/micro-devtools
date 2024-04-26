VERSION               = "2.0.0"

local config          = import("micro/config")
local shell           = import("micro/shell")
local filepath        = import("path/filepath")
local micro           = import("micro")
local buffer          = import("micro/buffer")

local PLUG_NAME       = "devtools"
local FORMAT_ON_SAVE  = "formatOnSave"
local RUN_INTERACTIVE = "interactiveShell"
local FORMATTER       = "formatter"
local RUNNER          = "runner"
local runnerPane      = nil

function plugLog(str) micro.Log(string.format("%s:%s", PLUG_NAME, str)) end

function plugMsg(str) micro.InfoBar():Message(string.format("%s:%s", PLUG_NAME, str)) end

function plugErr(str) micro.InfoBar():Error(string.format("%s:%s", PLUG_NAME, str)) end

-- Register option on buffer open
function onBufferOpen(buf)
    local ft = buf:FileType()
    if ft ~= "unknown" then
        config.RegisterCommonOption(PLUG_NAME, string.format("%s.%s", FORMATTER, ft), "")
        config.RegisterCommonOption(PLUG_NAME, string.format("%s.%s", RUNNER, ft), "")
    end
end

function onSave(bp)
    local optVal = getOption(string.format("%s.%s", PLUG_NAME, FORMAT_ON_SAVE), bp)
    if optVal then
        doFormat(bp)
    end
end

function onQuit(bp)
    if bp == runnerPane then
        runnerPane = nil
    end
end

-- Output to buffer pane
function outputToPane(output)
    if runnerPane ~= nil then
        runnerPane:Quit()
    end
    -- New bufferPane
    local runnerBuffer = buffer.NewBuffer(output, RUNNER)
    runnerBuffer.Type.Scratch = true
    runnerBuffer.Type.Readonly = true
    local activePane = micro.CurPane()
    micro.CurPane():HSplitIndex(runnerBuffer, true)
    activePane:SetActive(true)
    runnerPane = micro.CurPane()
end

function getOption(key, bp)
    local value = bp.Buf.Settings[key] or config.GetGlobalOption(key)
    plugLog(string.format("getOption: %s=%s", key, value))
    return value
end

-- Save and format
function doFormat(bp)
    local formatterCommand = getOption(string.format("%s.%s.%s", PLUG_NAME, FORMATTER, bp.Buf:FileType()), bp)
    if formatterCommand ~= "" then
        local fmtTool = formatterCommand:gsub("%s+.+", "")
        local _, err = shell.ExecCommand("sh", "-c", string.format("command -v %s", fmtTool))
        if err == nil then
            local dirPath, _ = filepath.Split(bp.Buf.AbsPath)
            bp:Save()
            plugLog(string.format("doFormat: sh -c cd \"%s\" && %s \"%s\"", dirPath, formatterCommand, bp.Buf.AbsPath))
            local output, err = shell.ExecCommand("sh", "-c",
                string.format("cd \"%s\" && %s \"%s\"", dirPath, formatterCommand, bp.Buf.AbsPath))
            if err == nil then
                bp.Buf:ReOpen()
                plugMsg("Formatted")
            else
                -- if bp.Buf:FileType() ~= 'shell' then
                plugErr(output)
                -- end
            end
        else
            plugErr(string.format("%s not found in $PATH", fmtTool))
        end
    end
end

-- Run and output to runner pane
function doRun(bp)
    local runnerCommand = getOption(string.format("%s.%s.%s", PLUG_NAME, RUNNER, bp.Buf:FileType()), bp)
    if runnerCommand ~= "" then
        bp:Save()
        local dirPath, _ = filepath.Split(bp.Buf.AbsPath)
        local cmd = string.format("%s \"%s\"", runnerCommand, bp.Buf.AbsPath)
        plugLog(string.format("doRun: %s", cmd))

        local output, err = shell.RunCommand(cmd)
        outputToPane(output)
        if err ~= nil then
            plugErr(err:Error())
        end
    end
end

-- Run in interactive shell
function doRunInteractive(bp)
    local runnerCommand = getOption(string.format("%s.%s.%s", PLUG_NAME, RUNNER, bp.Buf:FileType()), bp)
    if runnerCommand ~= "" then
        bp:Save()
        local dirPath, _ = filepath.Split(bp.Buf.AbsPath)
        local cmd = string.format("%s \"%s\"", runnerCommand, bp.Buf.AbsPath)
        plugLog(string.format("doRunInteractive: %s", cmd))

        local waitForInput = true
        local getOutout = false
        local output, err = shell.RunInteractiveShell(cmd, waitForInput, getOutout)
        if err ~= nil then
            plugErr(err:Error())
        end
    end
end

function init()
    config.RegisterCommonOption(PLUG_NAME, FORMAT_ON_SAVE, false)
    config.RegisterCommonOption(PLUG_NAME, RUN_INTERACTIVE, false)
    config.MakeCommand("f", doFormat, config.NoComplete)
    config.MakeCommand("x", doRun, config.NoComplete)
    config.MakeCommand("xi", doRunInteractive, config.NoComplete)
    config.AddRuntimeFile(PLUG_NAME, config.RTHelp, string.format("help/%s.md", PLUG_NAME))
end
