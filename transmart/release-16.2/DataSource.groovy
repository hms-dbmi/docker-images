/**
* Configuration for database connection - this file will be loaded
* by the tranSMART application when the tomcat is restarted
*/

dataSource {

 // standard jdbc driver
 driverClassName ="oracle.jdbc.driver.OracleDriver"

 url = "jdbc:oracle:thin:@${System.getenv("ORACLEHOST")}:${System.getenv("DB_PORT")}:ORCLCDB"
 dialect         = 'org.hibernate.dialect.Oracle10gDialect'
 username = "${System.getenv("DB_USER")}"
 password = "${System.getenv("BIOMART_USER")}"
 dbCreate        = 'none'

 properties {
  numTestsPerEvictionRun = 3
  maxWait = 10000

  testOnBorrow = true
  testWhileIdle = true
  testOnReturn = true

  validationQuery = "select 1 if from dual"

  minEvictableIdleTimeMillis = 1000 * 60 * 5
  timeBetweenEvictionRunsMillis = 1000 * 60 * 5
}
}

environments {
    development {
        dataSource {
            logSql    = true
            formatSql = true
             properties {
                maxActive   = 10
                maxIdle     = 5
                minIdle     = 2
                initialSize = 2
            }
        }
    }
    production {
        dataSource {
            logSql    = false
            formatSql = false
             properties {
                maxActive   = 50
                maxIdle     = 25
                minIdle     = 5
                initialSize = 5
            }
        }
    }
}

// for old versions that don't specify this in the in-tree one
if (hibernate.cache.region.factory_class != 'grails.plugin.cache.ehcache.hibernate.BeanEhcacheRegionFactory') {
    hibernate {
        cache.use_query_cache        = true
        cache.use_second_level_cache = true
        cache.provider_class         = 'org.hibernate.cache.EhCacheProvider'
    }
}
