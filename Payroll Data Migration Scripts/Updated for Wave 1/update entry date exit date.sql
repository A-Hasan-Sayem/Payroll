-- new
UPDATE public.hr_attend_summary_daily
SET entry_date = CASE WHEN entry_date::TIME ='00:00:00.000000' AND entry_time IS NOT NULL THEN entry_date + entry_time ELSE entry_date END
, exit_date = CASE WHEN exit_date::TIME = '00:00:00.000000' AND exit_time IS NOT NULL THEN exit_date + exit_time ELSE exit_date END
WHERE DATE(created_date) = '2025-05-30';
 
 
UPDATE public.hr_attend_summary_daily
SET entry_date = CASE WHEN entry_date::TIME ='00:00:00.000000' THEN NULL ELSE entry_date END
, entry_time =  CASE WHEN exit_date::TIME = '00:00:00.000000' THEN NULL ELSE exit_date END
WHERE DATE(created_date) = '2025-05-30';







-----------------------------------------------------------------------------------------------------

-- old
UPDATE public.hr_attend_summary_daily
SET entry_date = CASE WHEN entry_time IS NOT NULL THEN entry_date + COALESCE(entry_time, '00:00:00.000000') ELSE NULL END
, exit_date = CASE WHEN exit_time IS NOT NULL THEN exit_date + COALESCE(exit_time, '00:00:00.000000') ELSE NULL END
WHERE DATE(created_date) = '2025-05-30'
AND (entry_date::TIME ='00:00:00.000000' OR exit_date::TIME = '00:00:00.000000');


update public.hr_attend_summary_daily H
SET shift_start_time = H.atten_date::timestamp without time zone + CAST(M.start_time AS interval)
FROM mdg_work_shift M
WHERE H.work_shift_id = M.id AND DATE(H.created_date) = '2025-05-30';



UPDATE hr_attend_summary_daily H
SET total_hours = CASE
WHEN entry_date IS NOT NULL AND exit_date IS NOT NULL
AND entry_date::TIME !='00:00:00.000000' AND exit_date::TIME != '00:00:00.000000'
AND exit_date::TIME > shift_start_time::TIME
AND entry_date::TIME < exit_date::TIME  THEN
ROUND(
EXTRACT(EPOCH FROM (
exit_date -
CASE
-- Use the entry_date or shift start whichever is later
WHEN entry_date >= shift_start_time THEN entry_date
ELSE shift_start_time
END
)) / 3600.0, 1) -- Convert seconds to hours and round to 1 decimal place
ELSE 0
END
WHERE DATE(H.created_date) = '2025-05-30';
