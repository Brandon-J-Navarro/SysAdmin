-- https://straightpathsql.com/archives/2023/01/5-common-sql-server-problems-to-troubleshoot-with-sp_whoisactive/
-- What’s really happening right now?
EXEC sp_WhoIsActive
    @output_column_list = '[dd%][session_id][%delta][login_name][sql_text][%]'
    , @delta_Interval = 5;

-- What filled up the transaction log?
EXEC sp_WhoIsActive
    @output_column_list = '[dd%][session_id][tran%][login_name][sql_text][%]'
    , @get_transaction_info = 1;

-- What’s using the most memory?
EXEC sp_WhoIsActive
    @output_column_list = '[dd%][session_id][%memory%][login_name][sql_text][%]'
    , @get_memory_info = 1;

-- What filled up tempdb?
EXEC sp_WhoIsActive
    @output_column_list = '[start_time][session_id][temp%][sql_text][query_plan][wait_info][%]'
    , @get_plans = 1
    , @sort_order = '[tempdb_current] DESC';

-- Is there blocking?
EXEC sp_WhoIsActive
    @output_column_list = '[start_time][session_id][block%][login%][locks][sql_text][%]'
    , @find_block_leaders = 1
    , @get_locks = 1
    , @get_additional_info = 1
    , @sort_order = '[blocked_session_count] DESC';
