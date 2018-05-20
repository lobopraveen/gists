On importing a package with a component, say constructor, that uses source monitoring, the last processed date gets reset. The next time the component runs, it processes everything. To avoid this, we have to reset the last processed date. Note that this holds true for version 10~.

This is an approximate query just to give an idea where to look for the settings.

```sql
UPDATE CADIS_SYS.CO_PROCESSINPUT
SET    LASTDATEPROCESSED = PROPOSEDDATE
WHERE  PROCESSNAME = 'CODE' AND
       INPUT = 'CODE'
```
