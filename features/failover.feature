Feature: test failover
  setup 2 nodes, kill master and check failover, after that restart previous master and it should join the cluster as a replica node

  Scenario: start first mysql and add second replica
    Given setup default proxysql with name: proxysql and image: hub.hamdocker.ir/proxysql/proxysql:2.6.2
    And setup default mysql with server_id 1 and image: hub.hamdocker.ir/library/mysql:8.0.35-bullseye
    And setup default mysql with server_id 2 and image: hub.hamdocker.ir/library/mysql:8.0.35-bullseye
    And setup mysql_manager with name mm
    And sleep 50 seconds
    When execute mysql query with user: hamadmin, password: password, host: proxysql and port: 3306 query: use hamdb; CREATE TABLE t1 (c1 INT PRIMARY KEY, c2 TEXT NOT NULL);INSERT INTO t1 VALUES (1, 'Luis');
    Given stop mysql with server_id 1
    And sleep 40 seconds
    Then result of query: "show replica status;" with user: root and password: root on host: mysql-s2 and port: 3306 should be
    """
    <?xml version="1.0"?>

    <resultset statement="show replica status" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"></resultset>
    """

    # Then result of query: "show master status;" with user: root and password: root on host: mysql-s2 and port: 3306 should be
    # """
    # """
    
    Then result of query: "select * from hamdb.t1;" with user: hamadmin and password: password on host: proxysql and port: 3306 should be
    """
    <?xml version="1.0"?>

    <resultset statement="select * from hamdb.t1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <row>
	    <field name="c1">1</field>
	    <field name="c2">Luis</field>
      </row>
    </resultset>
    """
    
    # Then result of query: "use mysql; show events;" with user: root and password: root on host: mysql-s2 and port: 3306 should be
    # """
    # """

    Then result of query: "SELECT user FROM mysql.user;" with user: root and password: root on host: mysql-s2 and port: 3306 should be
    """
    <?xml version="1.0"?>

    <resultset statement="SELECT user FROM mysql.user" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <row>
	    <field name="user">exporter</field>
      </row>

      <row>
	    <field name="user">hamadmin</field>
      </row>

      <row>
	    <field name="user">proxysql</field>
      </row>

      <row>
	    <field name="user">replica</field>
      </row>

      <row>
	    <field name="user">root</field>
      </row>

      <row>
	    <field name="user">mysql.infoschema</field>
      </row>

      <row>
	    <field name="user">mysql.session</field>
      </row>

      <row>
	    <field name="user">mysql.sys</field>
      </row>

      <row>
	    <field name="user">root</field>
      </row>
    </resultset>
    """
    
    Then result of query: "show grants for hamadmin;" with user: root and password: root on host: mysql-s2 and port: 3306 should be
    """
    <?xml version="1.0"?>

    <resultset statement="show grants for hamadmin" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <row>
	    <field name="Grants for hamadmin@%">GRANT CREATE, DROP, PROCESS, SHOW DATABASES, REPLICATION CLIENT, CREATE USER, CREATE ROLE, DROP ROLE ON *.* TO `hamadmin`@`%` WITH GRANT OPTION</field>
      </row>

      <row>
	    <field name="Grants for hamadmin@%">GRANT ROLE_ADMIN ON *.* TO `hamadmin`@`%` WITH GRANT OPTION</field>
      </row>

      <row>
	    <field name="Grants for hamadmin@%">GRANT ALL PRIVILEGES ON `hamdb`.* TO `hamadmin`@`%` WITH GRANT OPTION</field>
      </row>

      <row>
	    <field name="Grants for hamadmin@%">GRANT SELECT ON `mysql`.* TO `hamadmin`@`%` WITH GRANT OPTION</field>
      </row>

      <row>
	    <field name="Grants for hamadmin@%">GRANT SELECT ON `sys`.* TO `hamadmin`@`%` WITH GRANT OPTION</field>
      </row>

      <row>
	    <field name="Grants for hamadmin@%">GRANT SELECT ON `performance_schema`.* TO `hamadmin`@`%` WITH GRANT OPTION</field>
      </row>
    </resultset>
    """

    Then result of query: "show databases;" with user: root and password: root on host: mysql-s2 and port: 3306 should be
    """
    <?xml version="1.0"?>

    <resultset statement="show databases" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <row>
	    <field name="Database">hamdb</field>
      </row>

      <row>
	    <field name="Database">information_schema</field>
      </row>

      <row>
	    <field name="Database">mysql</field>
      </row>

      <row>
	    <field name="Database">performance_schema</field>
      </row>

      <row>
	    <field name="Database">sys</field>
      </row>

      <row>
	    <field name="Database">test</field>
      </row>
    </resultset>
    """

    Then result of query: "select * from runtime_mysql_servers;" with user: radmin and password: pwd on host: proxysql and port: 6032 should be
    """
    <?xml version="1.0"?>

    <resultset statement="select * from runtime_mysql_servers" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <row>
	    <field name="hostgroup_id">0</field>
	    <field name="hostname">mysql-s2</field>
	    <field name="port">3306</field>
	    <field name="gtid_port">0</field>
	    <field name="status">ONLINE</field>
	    <field name="weight">1</field>
	    <field name="compression">0</field>
	    <field name="max_connections">1000</field>
	    <field name="max_replication_lag">0</field>
	    <field name="use_ssl">0</field>
	    <field name="max_latency_ms">0</field>
	    <field name="comment"></field>
      </row>

      <row>
	    <field name="hostgroup_id">1</field>
	    <field name="hostname">mysql-s2</field>
	    <field name="port">3306</field>
	    <field name="gtid_port">0</field>
	    <field name="status">ONLINE</field>
	    <field name="weight">1</field>
	    <field name="compression">0</field>
	    <field name="max_connections">1000</field>
	    <field name="max_replication_lag">0</field>
	    <field name="use_ssl">0</field>
	    <field name="max_latency_ms">0</field>
	    <field name="comment"></field>
      </row>
    </resultset>
    """
    
    Given start mysql with server_id 1
    Given sleep 30 seconds
    When execute mysql query with user: hamadmin, password: password, host: proxysql and port: 3306 query: INSERT INTO hamdb.t1 VALUES (2, 'Hassan');
    Then result of query: "show replica status;" with user: root and password: root on host: mysql-s2 and port: 3306 should be
    """
    <?xml version="1.0"?>

    <resultset statement="show replica status" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"></resultset>
    """
    # Then result of query: "show master status;" with user: root and password: root on host: mysql-s2 and port: 3306 should be
    # """
    # """
    
    # Then result of query: "show replica status;" with user: root and password: root on host: mysql-s1 and port: 3306 should be
    # """
    # """
    
    # Then result of query: "show master status;" with user: root and password: root on host: mysql-s1 and port: 3306 should be
    # """
    # """
    Then result of query: "select * from runtime_mysql_servers;" with user: radmin and password: pwd on host: proxysql and port: 6032 should be
    """
    <?xml version="1.0"?>

    <resultset statement="select * from runtime_mysql_servers" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <row>
	    <field name="hostgroup_id">0</field>
	    <field name="hostname">mysql-s2</field>
	    <field name="port">3306</field>
	    <field name="gtid_port">0</field>
	    <field name="status">ONLINE</field>
	    <field name="weight">1</field>
	    <field name="compression">0</field>
	    <field name="max_connections">1000</field>
	    <field name="max_replication_lag">0</field>
	    <field name="use_ssl">0</field>
	    <field name="max_latency_ms">0</field>
	    <field name="comment"></field>
      </row>

      <row>
	    <field name="hostgroup_id">1</field>
	    <field name="hostname">mysql-s1</field>
	    <field name="port">3306</field>
	    <field name="gtid_port">0</field>
	    <field name="status">ONLINE</field>
	    <field name="weight">1</field>
	    <field name="compression">0</field>
	    <field name="max_connections">1000</field>
	    <field name="max_replication_lag">0</field>
	    <field name="use_ssl">0</field>
	    <field name="max_latency_ms">0</field>
	    <field name="comment"></field>
      </row>

      <row>
	    <field name="hostgroup_id">1</field>
	    <field name="hostname">mysql-s2</field>
	    <field name="port">3306</field>
	    <field name="gtid_port">0</field>
	    <field name="status">ONLINE</field>
	    <field name="weight">1</field>
	    <field name="compression">0</field>
	    <field name="max_connections">1000</field>
	    <field name="max_replication_lag">0</field>
	    <field name="use_ssl">0</field>
	    <field name="max_latency_ms">0</field>
	    <field name="comment"></field>
      </row>
    </resultset>
    """
    
    Then result of query: "select * from hamdb.t1;" with user: hamadmin and password: password on host: proxysql and port: 3306 should be
    """
    <?xml version="1.0"?>

    <resultset statement="select * from hamdb.t1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <row>
	    <field name="c1">1</field>
	    <field name="c2">Luis</field>
      </row>
      <row>
	    <field name="c1">2</field>
	    <field name="c2">Hassan</field>
      </row>
    </resultset>
    """
    
    Then result of query: "select * from hamdb.t1;" with user: root and password: root on host: mysql-s1 and port: 3306 should be
    """
    <?xml version="1.0"?>

    <resultset statement="select * from hamdb.t1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <row>
	    <field name="c1">1</field>
	    <field name="c2">Luis</field>
      </row>
      <row>
	    <field name="c1">2</field>
	    <field name="c2">Hassan</field>
      </row>
    </resultset>
    """
    
    Then result of query: "select * from hamdb.t1;" with user: root and password: root on host: mysql-s2 and port: 3306 should be
    """
    <?xml version="1.0"?>

    <resultset statement="select * from hamdb.t1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <row>
	    <field name="c1">1</field>
	    <field name="c2">Luis</field>
      </row>
      <row>
	    <field name="c1">2</field>
	    <field name="c2">Hassan</field>
      </row>
    </resultset>
    """

    Given restart mysql manager

    Then result of query: "show replica status;" with user: root and password: root on host: mysql-s2 and port: 3306 should be
    """
    <?xml version="1.0"?>

    <resultset statement="show replica status" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"></resultset>
    """
    # Then result of query: "show master status;" with user: root and password: root on host: mysql-s2 and port: 3306 should be
    # """
    # """
    
    # Then result of query: "show replica status;" with user: root and password: root on host: mysql-s1 and port: 3306 should be
    # """
    # """
    
    # Then result of query: "show master status;" with user: root and password: root on host: mysql-s1 and port: 3306 should be
    # """
    # """
    Then result of query: "select * from runtime_mysql_servers;" with user: radmin and password: pwd on host: proxysql and port: 6032 should be
    """
    <?xml version="1.0"?>

    <resultset statement="select * from runtime_mysql_servers" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <row>
	    <field name="hostgroup_id">0</field>
	    <field name="hostname">mysql-s2</field>
	    <field name="port">3306</field>
	    <field name="gtid_port">0</field>
	    <field name="status">ONLINE</field>
	    <field name="weight">1</field>
	    <field name="compression">0</field>
	    <field name="max_connections">1000</field>
	    <field name="max_replication_lag">0</field>
	    <field name="use_ssl">0</field>
	    <field name="max_latency_ms">0</field>
	    <field name="comment"></field>
      </row>

      <row>
	    <field name="hostgroup_id">1</field>
	    <field name="hostname">mysql-s1</field>
	    <field name="port">3306</field>
	    <field name="gtid_port">0</field>
	    <field name="status">ONLINE</field>
	    <field name="weight">1</field>
	    <field name="compression">0</field>
	    <field name="max_connections">1000</field>
	    <field name="max_replication_lag">0</field>
	    <field name="use_ssl">0</field>
	    <field name="max_latency_ms">0</field>
	    <field name="comment"></field>
      </row>

      <row>
	    <field name="hostgroup_id">1</field>
	    <field name="hostname">mysql-s2</field>
	    <field name="port">3306</field>
	    <field name="gtid_port">0</field>
	    <field name="status">ONLINE</field>
	    <field name="weight">1</field>
	    <field name="compression">0</field>
	    <field name="max_connections">1000</field>
	    <field name="max_replication_lag">0</field>
	    <field name="use_ssl">0</field>
	    <field name="max_latency_ms">0</field>
	    <field name="comment"></field>
      </row>
    </resultset>
    """
