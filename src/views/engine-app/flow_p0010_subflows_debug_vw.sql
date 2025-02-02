-- dev version of flow_p0010_subflows_vw exposing all moving parts
-- not installed by default
create or replace view flow_p0010_subflows_debug_vw
as
  select sbfl.sbfl_id
       , sbfl.sbfl_sbfl_id
       , sbfl.sbfl_prcs_id
       , sbfl.sbfl_process_name
       , sbfl.sbfl_dgrm_id
       , sbfl.sbfl_sbfl_dgrm_id
       , sbfl.sbfl_dgrm_name
       , sbfl.sbfl_dgrm_version
       , sbfl.sbfl_dgrm_status
       , sbfl.sbfl_dgrm_category
       , sbfl_route
       , sbfl_route_name
       , sbfl_last_completed
       , sbfl_last_completed_name
       , sbfl.sbfl_current
       , sbfl.sbfl_current_name 
       , sbfl.sbfl_current_tag_name
       , sbfl.sbfl_starting_object
       , sbfl.sbfl_starting_object_name 
       , sbfl.sbfl_last_update
       , sbfl.sbfl_status
       , sbfl.sbfl_current_lane
       , sbfl.sbfl_current_lane_name
       , sbfl.sbfl_reservation
       , sbfl.sbfl_process_level
       , case
          when sbfl.sbfl_status in ('split', 'in subprocess', 'waiting at gateway', 'waiting for event', 'waiting for timer') then
            '<span class="' ||
            case sbfl.sbfl_status
              when 'split' then 'fa fa-share-alt'
              when 'in subprocess' then 'fa fa-share-alt'
              when 'waiting at gateway' then 'fa fa-hand-stop-o'
              when 'waiting for timer' then 'fa fa-clock-o'
              when 'waiting for event' then 'fa fa-hand-stop-o'
            end ||
            '"></span>'
          when sbfl.sbfl_status = 'error' then 
            '<button type="button" class="clickable-action t-Button t-Button--noLabel t-Button--icon" ' ||
            'title="Re-start Previous Step" aria-label="Re-start Previous Step" ' ||
            'data-prcs="' || sbfl.sbfl_prcs_id || '" data-sbfl="' || sbfl.sbfl_id || 
            '" data-action="restart_step"><span aria-hidden="true" class="fa fa-redo-arrow"></span></button>' 
          else
            '<button type="button" class="clickable-action t-Button t-Button--noLabel t-Button--icon" ' ||
            'title="Go to next step" aria-label="Go to next step" ' ||
            'data-prcs="' || sbfl.sbfl_prcs_id || '" data-sbfl="' || sbfl.sbfl_id || 
            '" data-action="next_step"><span aria-hidden="true" class="fa fa-sign-out"></span></button>' 
         end as action_html
       , case 
          when sbfl.sbfl_status = 'running' then 
            '<button type="button" class="clickable-action t-Button t-Button--noLabel t-Button--icon" ' ||
            case 
                when sbfl.sbfl_reservation is null then 'title="Reserve Step" aria-label="Reserve Step" '
                when sbfl.sbfl_reservation is not null then 'title="Release Reservation" aria-label="Release Reservation" '
            end || 'data-prcs="' || sbfl.sbfl_prcs_id || '" data-sbfl="' || sbfl.sbfl_id || '" data-action="' ||
            case 
                when sbfl.sbfl_reservation is null then 'reserve'
                when sbfl.sbfl_reservation is not null then 'release'
              end || '"><span aria-hidden="true" class="' ||
              case
                when sbfl.sbfl_reservation is null then  'fa fa-lock'
                when sbfl.sbfl_reservation is not null then 'fa fa-unlock'
              end || '"></span></button>'  
          else
            null  
         end as reservation_html
    from flow_subflows_vw sbfl
with read only
;
