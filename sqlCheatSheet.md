# SQL Cheat Sheet Reference

### SHOW CREATE TABLE [table-name]
Shows the query for creating the specified table. e.g. `CREATE TABLE` ...

### Set Lat and Lon format AS LAT, LON (in sensor db)
```sql
SELECT *, CONCAT(CAST(lat AS char(10)) , ',', CAST(lon AS char(10))) FROM `ov_kv6` 
	WHERE
		timestamp BETWEEN '2018-03-01 00:24' AND '2018-03-01 00:25' 
		AND vehicle='4005'
```
### Allow remote access	
Change binding address to `0.0.0.0` from `127.0.0.1` i.e. from local access only to `0`.
File path: `/etc/mysql/mysql.conf.d/mysqld.cnf`
Then: 
```bash 
$ sudo mysql 
```
In sql cmd line:
```sql
GRANT ALL PRIVILEGES ON 'db-name'.* TO 'ranjan'@'192.168.TARGET' IDENTIFIED BY 'user_password';
```
This will grant privileges to user `ranjan` upon database `db-name` and all its tables (*.* for all db and tables). If the user `ranjan` is accessing db from the ip-address `192.168.TARGET`

### Drop a column
```sql
ALTER TABLE `tableName`
  	DROP COLUMN `columnName1`,
  	DROP COLUMN `columnName1`;
```

### MonetDB: Analyze tables and columns
```sql
ANALYZE schemaname [ '.' tablename [ '('columnname , ...')' ] ]
	e.g.
	ANALYZE sys.tablename(columnname , ...) SAMPLE 24; // only 24 samples
	SELECT * FROM sys.statistics;
```
source: https://www.monetdb.org/Documentation/Cookbooks/SQLrecipes/statistics

### Monetdb TRANSACTIONS
```sql
START TRANSACTION; COMMIT; ROLLBACK;
```

### Monetdb create custom function
Example:
```sql
CREATE FUNCTION testing (name CHAR(10)) RETURNS string RETURN CONCAT('Hello ', name);
```
Usage:
```sql
SELECT testing('bobby');
SELECT id, name, testing('bobby') FROM table1 LIMIT 4;
```
