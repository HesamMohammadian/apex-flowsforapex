create or replace view flow_p0013_subflow_log_vw
as
  select lgsf.lgsf_prcs_id
       , lgsf.lgsf_objt_id
       , lgsf.lgsf_sbfl_id
       , lgsf.lgsf_sbfl_process_level
       , lgsf.lgsf_last_completed
       , lgsf.lgsf_status_when_complete
       , lgsf.lgsf_was_current
       , lgsf.lgsf_started
       , lgsf.lgsf_completed
       , lgsf.lgsf_reservation
       , lgsf.lgsf_user
       , lgsf.lgsf_comment
    from flow_subflow_event_log lgsf
with read only;
