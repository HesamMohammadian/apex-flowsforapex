create or replace package body flow_p0008_api
as

  procedure process_action
  as 
    l_error_occured boolean := false;
    l_url           varchar2(4000);
    l_clob          clob;
  begin
    if instr(apex_application.g_x01, 'bulk-') > 0 then
      for i in apex_application.g_f01.first..apex_application.g_f01.last
      loop
        apex_debug.message( p_message => 'Action: %s, PRCS: %s, SBFL: %s', p0 => apex_application.g_x01, p1 => apex_application.g_f01(i), p2 => apex_application.g_f02(i) );
        case upper(apex_application.g_x01)
          when 'BULK-RESERVE-STEP' then
            flow_api_pkg.flow_reserve_step
            (
              p_process_id => apex_application.g_f01(i)
            , p_subflow_id => apex_application.g_f02(i)
            , p_reservation => coalesce(apex_application.g_x02, V('APP_USER'))
            );
          when 'BULK-RELEASE-STEP' then
            flow_api_pkg.flow_release_step
            (
              p_process_id => apex_application.g_f01(i)
            , p_subflow_id => apex_application.g_f02(i)
            );        
          when 'BULK-COMPLETE-STEP' then
            flow_api_pkg.flow_complete_step
            (
              p_process_id => apex_application.g_f01(i)
            , p_subflow_id => apex_application.g_f02(i)
            );
          when 'BULK-RESTART-STEP' then 
            flow_api_pkg.flow_restart_step 
            (
              p_process_id => apex_application.g_f01(i)
            , p_subflow_id => apex_application.g_f02(i)
            , p_comment       => apex_application.g_x02           
            );
          else
            apex_error.add_error
            (
              p_message          => 'Unknow action requested.'
            , p_display_location => apex_error.c_on_error_page
            );
        end case;
      end loop;
    else
      apex_debug.message( p_message => 'Action: %s, PRCS: %s, SBFL: %s', p0 => apex_application.g_x01, p1 => apex_application.g_x02, p2 => apex_application.g_x03 );
      case upper(apex_application.g_x01)
        when 'RESET-FLOW-INSTANCE' then
          flow_api_pkg.flow_reset( p_process_id => apex_application.g_x01, p_comment => apex_application.g_x02 );
        when 'START-FLOW-INSTANCE' then
          flow_api_pkg.flow_start( p_process_id => apex_application.g_x01 );
        when 'DELETE-FLOW-INSTANCE' then
          flow_api_pkg.flow_delete( p_process_id => apex_application.g_x01, p_comment => apex_application.g_x02 );
          l_url := apex_page.get_url(
                p_page => 10
              , p_clear_cache => 10
          );
        when 'RESERVE-STEP' then
          flow_api_pkg.flow_reserve_step
          (
            p_process_id => apex_application.g_x02
          , p_subflow_id => apex_application.g_x03
          , p_reservation => coalesce(apex_application.g_x04, V('APP_USER'))
          );
        when 'TERMINATE-FLOW-INSTANCE' then 
          flow_api_pkg.flow_terminate ( p_process_id => apex_application.g_x02, p_comment => apex_application.g_x03 );
        when 'RELEASE-STEP' then
          flow_api_pkg.flow_release_step
          (
            p_process_id => apex_application.g_x02
          , p_subflow_id => apex_application.g_x03
          );    
        when 'COMPLETE-STEP' then
          flow_api_pkg.flow_complete_step
          (
            p_process_id    => apex_application.g_x02
          , p_subflow_id    => apex_application.g_x03
          );
        when 'RESTART-STEP' then 
          flow_api_pkg.flow_restart_step 
          (
            p_process_id    => apex_application.g_x02
          , p_subflow_id    => apex_application.g_x03
          , p_comment       => apex_application.g_x04       
          );
        when 'FLOW-INSTANCE-AUDIT' then
          l_url := apex_page.get_url(
              p_page => 14
            , p_items => 'P14_PRCS_ID,P14_TITLE'
            , p_values => apex_application.g_x02||','||apex_application.g_x03
          );
        when 'EDIT-FLOW-DIAGRAM' then
          l_url := apex_page.get_url(
              p_page => 7
            , p_items => 'P7_DGRM_ID'
            , p_values => apex_application.g_x02
          );
        when 'ADD-PROCESS-VARIABLE' then
          case apex_application.g_x04
            when 'VARCHAR2' then
              flow_process_vars.set_var
              (
                pi_prcs_id   => apex_application.g_x02
              , pi_var_name  => apex_application.g_x03
              , pi_vc2_value => apex_application.g_x05
              );
            when 'NUMBER' then
              flow_process_vars.set_var
              (
                pi_prcs_id   => apex_application.g_x02
              , pi_var_name  => apex_application.g_x03
              , pi_num_value => to_number(apex_application.g_x05)
              );
            when 'DATE' then
              flow_process_vars.set_var
              (
                pi_prcs_id    => apex_application.g_x02
              , pi_var_name   => apex_application.g_x03
              , pi_date_value => to_date(apex_application.g_x05, v('APP_DATE_TIME_FORMAT'))
              );
            when 'CLOB' then
              for i in apex_application.g_f01.first..apex_application.g_f01.last
              loop
                l_clob := l_clob || apex_application.g_f01(i);
              end loop;
              flow_process_vars.set_var
              (
                pi_prcs_id    => apex_application.g_x02
              , pi_var_name   => apex_application.g_x03
              , pi_clob_value => l_clob
              );
            else
              null;
          end case;
        else
          apex_error.add_error
          (
            p_message          => 'Unknow action requested.'
          , p_display_location => apex_error.c_on_error_page
          );
      end case;
    end if;

    apex_json.open_object;
    apex_json.write( p_name => 'success', p_value => not apex_error.have_errors_occurred );
    if l_url is not null then
      apex_json.write( p_name => 'url', p_value => l_url );
    end if;
    apex_json.close_all;
    
  exception
      when others then
        l_error_occured := true;
  end process_action;

  procedure process_action
  (
    pi_action      in varchar2
  , pi_prcs_ids    in apex_application.g_f01%type
  , pi_sbfl_ids    in apex_application.g_f02%type
  , pi_dgrm_ids    in apex_application.g_f03%type
  , pi_prcs_names  in apex_application.g_f04%type
  , pi_reservation in varchar2
  , pi_comment     in varchar2
  )
  as
    l_error_occured boolean := false;
    l_url           varchar2(4000);
  begin
    for i in pi_prcs_ids.first..pi_prcs_ids.last
    loop
      apex_debug.message( p_message => 'Action: %s, PRCS: %s, SBFL: %s', p0 => pi_action, p1 => pi_prcs_ids(i), p2 => pi_sbfl_ids(i) );
      case upper(pi_action)
        when 'RESET-FLOW-INSTANCE' then
          flow_api_pkg.flow_reset( p_process_id => pi_prcs_ids(i), p_comment => pi_comment );
        when 'START-FLOW-INSTANCE' then
          flow_api_pkg.flow_start( p_process_id => pi_prcs_ids(i) );
        when 'DELETE-FLOW-INSTANCE' then
          flow_api_pkg.flow_delete( p_process_id => pi_prcs_ids(i), p_comment => pi_comment );
          l_url := apex_page.get_url(
                p_page => 10
              , p_clear_cache => 10
          );
        when 'RESERVE-STEP' then
          flow_api_pkg.flow_reserve_step
          (
            p_process_id => pi_prcs_ids(i)
          , p_subflow_id => pi_sbfl_ids(i)
          , p_reservation => coalesce(pi_reservation, V('APP_USER'))
          );
        when 'BULK-RESERVE-STEP' then
          flow_api_pkg.flow_reserve_step
          (
            p_process_id => pi_prcs_ids(i)
          , p_subflow_id => pi_sbfl_ids(i)
          , p_reservation => coalesce(pi_reservation, V('APP_USER'))
          );
        when 'TERMINATE-FLOW-INSTANCE' then 
          flow_api_pkg.flow_terminate ( p_process_id => pi_prcs_ids(i), p_comment => pi_comment );
        when 'RELEASE-STEP' then
          flow_api_pkg.flow_release_step
          (
            p_process_id => pi_prcs_ids(i)
          , p_subflow_id => pi_sbfl_ids(i)
          );   
        when 'BULK-RELEASE-STEP' then
          flow_api_pkg.flow_release_step
          (
            p_process_id => pi_prcs_ids(i)
          , p_subflow_id => pi_sbfl_ids(i)
          );        
        when 'COMPLETE-STEP' then
          flow_api_pkg.flow_complete_step
          (
            p_process_id    => pi_prcs_ids(i)
          , p_subflow_id    => pi_sbfl_ids(i)
          );
        when 'BULK-COMPLETE-STEP' then
          flow_api_pkg.flow_complete_step
          (
            p_process_id    => pi_prcs_ids(i)
          , p_subflow_id    => pi_sbfl_ids(i)
          );
        when 'RESTART-STEP' then 
          flow_api_pkg.flow_restart_step 
          (
            p_process_id    => pi_prcs_ids(i)
          , p_subflow_id    => pi_sbfl_ids(i)    
          , p_comment       => pi_comment       
          );
        when 'BULK-RESTART-STEP' then 
          flow_api_pkg.flow_restart_step 
          (
            p_process_id    => pi_prcs_ids(i)
          , p_subflow_id    => pi_sbfl_ids(i)
          , p_comment       => pi_comment           
          );
        when 'FLOW-INSTANCE-AUDIT' then
          l_url := apex_page.get_url(
              p_page => 14
            , p_items => 'P14_PRCS_ID,P14_TITLE'
            , p_values => pi_prcs_ids(i)||','||pi_prcs_names(i)
          );
        when 'EDIT-FLOW-DIAGRAM' then
          l_url := apex_page.get_url(
              p_page => 7
            , p_items => 'P7_DGRM_ID'
            , p_values => pi_dgrm_ids(i)
          );
        else
          apex_error.add_error
          (
            p_message          => 'Unknow action requested.'
          , p_display_location => apex_error.c_on_error_page
          );
      end case;
    end loop;
    
  
    apex_json.open_object;
    apex_json.write( p_name => 'success', p_value => not apex_error.have_errors_occurred );
    if l_url is not null then
      apex_json.write( p_name => 'url', p_value => l_url );
    end if;
    apex_json.close_all;
    
  exception
      when others then
        l_error_occured := true;
    
  end process_action;


procedure process_variables_row
(
  pi_request         in varchar2
, pi_delete_prov_var in boolean default false
, pi_prov_prcs_id    in out nocopy flow_process_variables.prov_prcs_id%type
, pi_prov_var_name   in out nocopy flow_process_variables.prov_var_name%type
, pi_prov_var_type   in flow_process_variables.prov_var_type%type
, pi_prov_var_vc2    in flow_process_variables.prov_var_vc2%type
, pi_prov_var_num    in flow_process_variables.prov_var_num%type
, pi_prov_var_date   in flow_process_variables.prov_var_date%type
, pi_prov_var_clob   in flow_process_variables.prov_var_clob%type
)
as
begin
  if ( pi_delete_prov_var ) then
    flow_process_vars.delete_var(
        pi_prcs_id  => pi_prov_prcs_id
      , pi_var_name => pi_prov_var_name
    );
  end if;

  case pi_prov_var_type
    when 'VARCHAR2' then
      flow_process_vars.set_var
      (
        pi_prcs_id   => pi_prov_prcs_id
      , pi_var_name  => pi_prov_var_name
      , pi_vc2_value => pi_prov_var_vc2
      );
    when 'NUMBER' then
      flow_process_vars.set_var
      (
        pi_prcs_id   => pi_prov_prcs_id
      , pi_var_name  => pi_prov_var_name
      , pi_num_value => pi_prov_var_num
      );
    when 'DATE' then
      flow_process_vars.set_var
      (
        pi_prcs_id    => pi_prov_prcs_id
      , pi_var_name   => pi_prov_var_name
      , pi_date_value => pi_prov_var_date
      );
    when 'CLOB' then
      flow_process_vars.set_var
      (
        pi_prcs_id    => pi_prov_prcs_id
      , pi_var_name   => pi_prov_var_name
      , pi_clob_value => pi_prov_var_clob
      );
    else
      null;
  end case;
end process_variables_row;

end flow_p0008_api;
/