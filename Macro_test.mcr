/*
FileName:		test_tool_cn.ms
Creator:			ZZS
Date:			2019-2-28 11:34
Comment:			mcr
KnownBugs:		
FixLogs:		
				
*/

macroScript Macro_Check
	category:"_ZZS_Skin_Util"
	toolTip:"check model"
(
	if doesFileExist "$scripts\\test_tool_cn.ms" do(
		FileIn "$scripts\\test_tool_cn.ms"
	)
)
