prompt --application/shared_components/navigation/lists/p10_subflow_header_action_menu
begin
--   Manifest
--     LIST: P10_SUBFLOW_HEADER_ACTION_MENU
--   Manifest End
wwv_flow_api.component_begin (
 p_version_yyyy_mm_dd=>'2020.03.31'
,p_release=>'20.1.0.00.13'
,p_default_workspace_id=>2400405578329584
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'FLOWS4APEX'
);
wwv_flow_api.create_list(
 p_id=>wwv_flow_api.id(4409050172512221)
,p_name=>'P10_SUBFLOW_HEADER_ACTION_MENU'
,p_list_status=>'PUBLIC'
);
wwv_flow_api.create_list_item(
 p_id=>wwv_flow_api.id(4409268569512242)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'Complete Step'
,p_list_item_icon=>'fa-sign-out'
,p_list_text_01=>'bulk-complete-step'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_api.create_list_item(
 p_id=>wwv_flow_api.id(4409653667512250)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'Re-start Step'
,p_list_item_icon=>'fa-redo-arrow'
,p_list_text_01=>'bulk-restart-step'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_api.create_list_item(
 p_id=>wwv_flow_api.id(4410048087512250)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'-'
,p_list_item_link_target=>'separator'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_api.create_list_item(
 p_id=>wwv_flow_api.id(4410440520512250)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>'Reserve Step'
,p_list_item_icon=>'fa-lock'
,p_list_text_01=>'bulk-reserve-step'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_api.create_list_item(
 p_id=>wwv_flow_api.id(4410861620512250)
,p_list_item_display_sequence=>50
,p_list_item_link_text=>'Release Step'
,p_list_item_icon=>'fa-unlock'
,p_list_text_01=>'bulk-release-step'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_api.component_end;
end;
/
