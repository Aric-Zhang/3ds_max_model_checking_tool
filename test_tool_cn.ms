/*
FileName：		test_tool_cn.ms
Creator：		张子石
Date：			2019-2-28 11:34
Comment：		模型检查工具
KnownBugs：		
FixLogs:			2019-3-19 15:40
				修复了重置旋转、位置的功能错误
				
*/

global fn_check_units
global fn_custom_units
global fn_assign_smooth_group_to_all_faces
global fn_assign_mat_id_to_all_faces
global fn_weld_all_verts
global fn_delete_iso_verts
global fn_check_medit_mat_valid
global fn_force_correct_opacity_map_on_obj
global fn_reset_xform
global fn_reset_pos
global fn_reset_rotation
global fn_reset_scale
global fn_epoly_err_process

old_rollout = Rollout_tool

rollout Rollout_tool "测试工具" width:162 height:520
(

	button btn_check_unit_settings "检查单位设置" pos:[10,25] width:142 height:20
	button btn_corrent_unit_settings "修正单位设置" pos:[10,50] width:142 height:20
	GroupBox unit_group_box "单位设置" pos:[5,5] width:152 height:72
	GroupBox grp2 "可编辑多边形设置" pos:[5,86] width:152 height:78

	button btn_mat_id "设置材质ID为1" pos:[10,107] width:142 height:20
	button btn_smooth_grp "设置平滑组为1" pos:[10,132] width:142 height:20

	GroupBox grp_weld_verts "焊接顶点" pos:[4,172] width:152 height:67
	button btn_weld_verts "焊接模型上的顶点" pos:[10,189] width:142 height:20
	spinner spn_weld_threshold "焊接阈值:" pos:[10,216] width:142 range:[0,100,0.01] height:16 scale:0.01 fieldwidth:30
	
	GroupBox grp_clear "清理" pos:[5,248] width:152 height:70
	button btn_remove_iso_verts "移除孤点" pos:[10,265] width:142 height:20
	button btn_remove_unused_mat "移除多余的材质及检查贴图" pos:[10,290] width:142 height:20
		
	GroupBox grp_transform_op "变换" pos:[5,325] width:152 height:93 enabled:true
	button btn_rexform_and_collapse "重置XForm并塌陷" pos:[10,342] width:142 height:20
	button btn_reset_transform "重置变换" pos:[10,367] width:142 height:20
	checkbox chk_pos "位置" pos:[12,392] width:43 height:20
	checkbox chk_rotation "旋转" pos:[62,392] width:45 height:20
	checkbox chk_scale "缩放" pos:[113,392] width:40 height:20
	
	GroupBox grp_auto_modify "检查和自动修正" pos:[6,424] width:151 height:90
	radiobuttons rdo_selection "应用于以下" pos:[10,440] width:128 height:46 labels:#("Selected", "All in Geometry") default:1 columns:1
	button btn_auto_run "自动修正以上所有选项" pos:[10,489] width:142 height:20
	
	--Delegate
	fn fn_invoke fn_name = (
		-----------------
		param = $
		if rdo_selection.state == 2 then (
			param = Geometry
		)
		-----------------
		try(
			--fn_name param
			if rdo_selection.state == 1 then(
				if classof param == ObjectSet then(
					for g in param do(
						try(
							fn_name g
						)
						catch(
							fn_epoly_err_process noMessage:true
						)
					)
				)
				else(
					try(
						fn_name param
					)
					catch(				
						fn_epoly_err_process()
					)
				)
			)
			else if rdo_selection.state == 2 then(
				for g in Geometry do(
					try(
						fn_name g
					)
					catch(
						fn_epoly_err_process noMessage:true
					)
				)
			)
			else(
				print rdo_selection.state
			)
		)
		catch(
			local ARGUMENT_0_ERR = "wanted 0, got 1"
			err = getCurrentException()
			if (findString err ARGUMENT_0_ERR)!=undefined then (
				fn_name()
			)
			else(
				print err
				throw()
			)
		)
	)
	
	on btn_check_unit_settings pressed do
	(
		fn_check_units()	
	)
	on btn_corrent_unit_settings pressed do
	(
		undo "Custom Units" on(
			fn_custom_units()
		)
	)
	on btn_mat_id pressed do
	(
		undo "Assign Mat ID" on(
			fn_invoke fn_assign_mat_id_to_all_faces
		)
	)
	on btn_smooth_grp pressed do
	(
		undo "Assign Smooth Group" on(
			fn_invoke fn_assign_smooth_group_to_all_faces
		)
	)
	on btn_weld_verts pressed do
	(
		undo "Weld All Verts"on(
			fn_invoke fn_weld_all_verts
		)
	)
	on btn_remove_iso_verts pressed do
	(
		undo "Remove Iso Verts"on(
			fn_invoke fn_delete_iso_verts
		)
	)
	on btn_remove_unused_mat pressed do
	(
		undo "Check Mat"on(
			fn_check_medit_mat_valid()
			fn_invoke fn_force_correct_opacity_map_on_obj
		)
	)
	on btn_rexform_and_collapse pressed do
	(
		undo "ReXForm and Collapse"on(
			fn_invoke fn_reset_xform
		)
		print $
	)
	on btn_reset_transform pressed do
	(
		undo "Reset Transform"on(
			if chk_pos.checked then(
				fn_invoke fn_reset_pos
			)
			if chk_rotation.checked then(
				fn_invoke fn_reset_rotation
			)
			if chk_scale.checked then(	
				fn_invoke fn_reset_scale
			)
		)
	)
	on btn_auto_run pressed do
	(
		undo "Auto Run All"on(
			fn_custom_units()
			fn_invoke fn_assign_mat_id_to_all_faces
			fn_invoke fn_assign_smooth_group_to_all_faces
			fn_invoke fn_weld_all_verts
			fn_invoke fn_delete_iso_verts
			fn_check_medit_mat_valid()
			fn_invoke fn_force_correct_opacity_map_on_obj
			fn_invoke fn_reset_xform
		
			if chk_pos.checked then(
				fn_invoke fn_reset_pos
			)
			if chk_rotation.checked then(
				fn_invoke fn_reset_rotation
			)
			if chk_scale.checked then(	
				fn_invoke fn_reset_scale
			)
		)
		messagebox "Done."
	)
)

print rollout_tool.open

--处理以及显示EPoly相关的错误
fn fn_epoly_err_process noMessage:false = (
	
	local OBJ_UNDEFINED_ERR = "requires a node"
	local OBJ_UNDEFINED_ERR_CN = OBJ_UNDEFINED_ERR
	local NOT_EPOLY_ERR = "EPoly operation on non-Editable Poly"
	local NOT_EPOLY_ERR_CN = "对不可编辑的多边形执行 EPoly 操作"
	local NOT_SELECTED_ERR = "in undefined"
	local NOT_SELECTED_ERR_CN = "位于 undefined"
	
	err = getCurrentException()
	
	if noMessage then(
		if (findString err NOT_EPOLY_ERR)!=undefined or (findString err NOT_EPOLY_ERR_CN)!=undefined then (
			print  ("Operation requires EditablePoly!\n错误信息:"+err)
		)
		else if (findString err OBJ_UNDEFINED_ERR)!=undefined then(
			print ("No object specified!\n"+err)
		)
		else if (findString err NOT_SELECTED_ERR)!=undefined or (findString err NOT_SELECTED_ERR_CN)!=undefined then(
			print ("No object selected!\n"+err)
		)
		else(
			print err
			return throw err
		)
		return ()
	)
	
	if (findString err NOT_EPOLY_ERR)!=undefined or (findString err NOT_EPOLY_ERR_CN)!=undefined then (
		messagebox  ("操作需要EditablePoly类型!\n错误信息:"+err)
	)
	else if (findString err OBJ_UNDEFINED_ERR)!=undefined then(
		messagebox ("没有指定对象!\n错误信息:"+err)
	)
	else if (findString err NOT_SELECTED_ERR)!=undefined or (findString err NOT_SELECTED_ERR_CN)!=undefined  then(
		messagebox ("没有对象被选中!\n错误信息:"+err)
	)
	else(
		print err
		throw err
	)
)

--??EPoly??????
fn fn_select_all_faces obj = (
	obj.EditablePoly.SetSelection #Face #{1..getNumFaces obj}
)

--??EPoly??????
fn fn_get_all_faces obj = (
	#{1..getNumFaces obj}
)

--Set SmoothGroup of all faces 1
fn fn_assign_smooth_group_to_all_faces obj  = (
	polyOp.setFaceSmoothGroup obj obj.faces 1

)

--将所有面的材质ID设置为1
fn fn_assign_mat_id_to_all_faces obj = (
	polyOp.setFaceMatID obj obj.faces 1

)

--焊接所有在阈值内的可焊接的顶点
fn fn_weld_all_verts obj = (

	if classof obj != Editable_Poly and obj != undefined then(
		throw("EPoly operation on non-Editable Poly")
	)
	obj.weldThreshold = rollout_tool.spn_weld_threshold.value
	print obj.weldThreshold
	polyOp.weldVertsByThreshold obj obj.verts

)

--删除孤点
fn fn_delete_iso_verts obj = (
	polyOp.deleteIsoVerts obj
)

--修改单位设置
fn fn_custom_units = (
	units.SystemType = #inches
	units.DisplayType = #Metric
	units.MetricType = #centimeters
)

--弹出单位设置的对话框
fn fn_check_units =(
	info = "系统单位: "
	info += units.SystemType as string
	info += "\n显示单位: "
	info += units.DisplayType as string
	
	print units.displaytype
	
	case units.DisplayType of (
		#Metric :info += "\n米制单位类型: " + units.MetricType as string
		#Generic : (print 0)
		#US : (print 1)
		#custom : (print 2)
		default: (print 3)		
	)	
	messagebox info
)

--Reset XForm and collapse
fn fn_reset_xform obj = (
	if obj == undefined do return (messagebox "在重置XForm时未指定对象!")
	if classof obj == ObjectSet then(
		for sub_obj in obj do(
			ResetXForm sub_obj
			maxOps.CollapseNode sub_obj on
		)
	)
	else(
		ResetXForm obj
		maxOps.CollapseNode obj on
	)
	convertTo obj PolyMeshObject
)


--Reset Rotation of the node's pivot
fn fn_reset_rotation obj = (
	--AlignToParent obj
	obj.rotation = (eulerAngles 0 0 0) as quat
)

--Reset Scale of the node's transform
fn fn_reset_scale obj = (
	--ResetScale obj
	obj.scale = [1,1,1]
)

--Reset pivot position
fn fn_reset_pivot obj = (
	ResetPivot obj
)

fn fn_reset_pos obj = (
	obj.pos = [0,0,0]
)

--Aquire all materials that applied in the scene, collect and return an array
fn fn_get_scene_mat = (
	scene_mat = #()
	for g in Geometry do(
		appendIfUnique scene_mat g.material
	)
	return scene_mat
)

--Check whether materials in MEdit have applied in the scene 
fn fn_check_medit_mat_valid = (
	scene_mat = fn_get_scene_mat()
	for i in 1 to 24 do(
		if (findItem scene_mat MEditMaterials[i]) == 0 do(
			MEditMaterials[i] = Standard name:("Standard - " + i as string)
		)
	)
)

--Check whether opacity map shares the same bitmap with diffuse map
fn fn_check_opacity_map mtl = (
	if mtl.opacityMap != undefined then(
		mtl.diffuseMap.filename == mtl.opacityMap.filename
	)
	else(
		return true
	)
)

--Check whether a string ends in ".tga"
fn fn_check_tga_format_bitmap filename = (
	suffix = subString filename (filename.count - 3) (-1)
	if suffix != ".tga" and suffix != ".TGA" then(
		print (filename + "不是‘.tga’格式文件!")
		return false
	)
	return true
)

--Check whether the file of diffuse map is .tga
fn fn_check_diffuse_map_suffix mtl = (
	filename = mtl.diffuseMap.filename
	if fn_check_tga_format_bitmap filename !=true then(
		print ("发现贴图格式错误于"+mtl.name)
		return false
	)
	return true
)

--Make opacityMap use diffuseMap
fn fn_force_correct_opacity_map mtl = (
	if fn_check_diffuse_map_suffix mtl then(
		mtl.opacityMap.filename = mtl.diffuseMap.filename	
	)
	else if fn_check_tga_format_bitmap mtl.opacityMap.filename then(
		mtl.diffuseMap.filename = mtl.opacityMap.filename
		print ("自动修改漫反射贴图使与透明通道贴图一致于材质" + mtl.name)
	)
	else(
		print ("没有格式找到符合条件的贴图，请重新指定漫反射贴图和透明通道贴图给材质" + mtl.name)
	)
)

--Material on an object
fn fn_force_correct_opacity_map_on_obj obj = (
	try(
		mtl = obj.material
		fn_force_correct_opacity_map mtl
	)
	catch(
		local NOT_STD_MTL_ERR = "Unknown property: \"filename\" in"
		local NOT_STD_MTL_ERR_CN = "未知属性:“filename”位于"
		err = getCurrentException()
		if classof mtl != Standard then(
			type_str = ""
			if mtl == undefined then (
				type_str = "undefined"
			)
			else(
				type_str = (classof mtl) as string				
			)
			print ("贴图类型: "+ type_str)
			return "No material to correct on current object."
		)
		if (findString err NOT_STD_MTL_ERR !=undefined) or (findString err NOT_STD_MTL_ERR_CN !=undefined) then(
			mtl.diffuseMap = undefined
			return (print"Texture map is not a bitmap type.")
		)
		throw()
	)
)

if old_rollout!=undefined then(
	destroyDialog old_rollout
)
if Rollout_tool.open != true then(
	createDialog Rollout_tool
)
else(
	destroyDialog Rollout_tool
)