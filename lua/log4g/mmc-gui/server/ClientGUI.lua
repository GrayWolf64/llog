--- Server-side processing of the Client GUI requests.
-- @script ClientGUI
-- @license Apache License 2.0
-- @copyright GrayWolf64
local NetUtil = include("log4g/core/util/NetUtil.lua")
local AddNetworkStrsViaTbl, WriteDataSimple = NetUtil.AddNetworkStrsViaTbl, NetUtil.WriteDataSimple
local GetAllCtx = Log4g.Core.LoggerContext.GetAll
local pairs = pairs
local table_count = table.Count
local TableToJson = util.TableToJSON
local file_read = file.Read
local constraint_gettable = constraint.GetTable

AddNetworkStrsViaTbl({
    [1] = "Log4g_CLReq_ChkConnected",
    [2] = "Log4g_CLRcv_ChkConnected",
    [3] = "Log4g_CLReq_SVSummaryData",
    [4] = "Log4g_CLRcv_SVSummaryData",
    [5] = "Log4g_CLReq_SVConfigurationFiles",
    [6] = "Log4g_CLRcv_SVConfigurationFiles"
})

net.Receive("Log4g_CLReq_ChkConnected", function(_, ply)
    net.Start("Log4g_CLRcv_ChkConnected")
    net.WriteBool(IsValid(ply) == ply:IsConnected() == true)
    net.Send(ply)
end)

net.Receive("Log4g_CLReq_SVSummaryData", function(_, ply)
    net.Start("Log4g_CLRcv_SVSummaryData")
    net.WriteFloat(collectgarbage("count"))
    net.WriteUInt(ents.GetCount(), 14)
    net.WriteUInt(ents.GetEdictCount(), 13)
    net.WriteUInt(table_count(net.Receivers), 12)
    net.WriteUInt(table_count(debug.getregistry()), 32)
    local constraintcount = 0

    for _, v in pairs(ents.GetAll()) do
        constraintcount = constraintcount + table_count(constraint_gettable(v))
    end

    net.WriteUInt(constraintcount, 16)
    net.WriteDouble(SysTime())
    net.WriteUInt(table_count(_G), 32)
    net.Send(ply)
end)

net.Receive("Log4g_CLReq_SVConfigurationFiles", function(_, ply)
    net.Start("Log4g_CLRcv_SVConfigurationFiles")
    local map = {}

    for _, v in pairs(GetAllCtx()) do
        local src = v:GetConfigurationSource()

        if src then
            local path = v:GetConfigurationSource().source:sub(2)

            if not map[path] then
                map[path] = file_read(path, "GAME")
            end
        end
    end

    WriteDataSimple(TableToJson(map), 32)
    net.Send(ply)
end)