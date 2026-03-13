use role SALES_ENGINEER;
-- set variables
set query_id  = '01c3006c-0000-f2f2-0015-224f01001286'; 
set deployment = '';

--- DO NOT CHANGE ---
EXECUTE IMMEDIATE $$
DECLARE
  deployment string;
  uuid string;
  query string;
  cDep cursor for select upper($deployment);
  cUid cursor for select lower($query_id);
  cLTime cursor for select to_timestamp(to_number(left($query_id, 8), 'XXXXXXXX') * 60);
  lTime timestamp;
  rs resultset;
BEGIN
  open cDep;
  open cUid;
  open cLTime;
  fetch cDep into deployment;
  fetch cUid into uuid;
  fetch cLTime into lTime;
  if (upper(deployment) = 'UNKNOWN' or deployment = '') then
    query := 'select temp.perfsol.get_deployment_link(DEPLOYMENT, UUID) as LINK, * ' ||
                'from    snowhouse_import.prod.job_etl_v ' ||
                'where   CLIENT_SEND_TIME between :1 and dateadd(m, 1, :1) ' ||
                'and     UUID = $query_id ' ||
                'limit   1';
  else
    query := 'select temp.perfsol.get_deployment_link(:2, UUID) as LINK, ' ||
                ':2 as DEPLOYMENT, * ' ||
                'from    snowhouse_import.' || :deployment || '.job_etl_v ' ||
                'where   CLIENT_SEND_TIME between :1 and dateadd(m, 1, :1) ' ||
                'and     UUID = $query_id ' ||
                'limit   1';
  end if;
  //return :query;
  rs := (execute immediate :query using (lTime, deployment));
  return table(rs);
END;
$$
;