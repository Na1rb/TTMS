package com.example.ttms.config.database;

import org.apache.commons.dbcp2.BasicDataSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcOperations;
import org.springframework.jdbc.core.JdbcTemplate;

import javax.sql.DataSource;
import java.util.List;
import java.util.ResourceBundle;

@Configuration
public class DbConfig {
    private static String URL;
    private static String USERNAME;
    private static String PASSWORD;
    private static String driverClassName;

    private static final ResourceBundle RESOURCE_BUNDLE = ResourceBundle.getBundle("db-config");

    static {
        URL = RESOURCE_BUNDLE.getString("jdbc.url");
        USERNAME = RESOURCE_BUNDLE.getString("jdbc.username");
        PASSWORD = RESOURCE_BUNDLE.getString("jdbc.password");
        driverClassName = RESOURCE_BUNDLE.getString("jdbc.driverClassName");
    }

    @Bean
    public DataSource dataSource() {
        BasicDataSource dataSource = new BasicDataSource();
        dataSource.setDriverClassName(driverClassName);
        dataSource.setUrl(URL);
        dataSource.setUsername(USERNAME);
        dataSource.setPassword(PASSWORD);
        dataSource.setInitialSize(5);
        dataSource.setMaxIdle(10);

        // Every newly-created JDBC connection explicitly switches to utf8mb4.
        // This protects all data read by the Vue frontend from MySQL connection
        // character-set drift, even if the server/container default changes later.
        dataSource.setConnectionInitSqls(List.of("SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci"));
        return dataSource;
    }

    @Bean
    public JdbcOperations jdbcTemplate(DataSource dataSource) {
        return new JdbcTemplate(dataSource);
    }
}
