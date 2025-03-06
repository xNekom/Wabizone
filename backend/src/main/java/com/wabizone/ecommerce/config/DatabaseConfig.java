package com.wabizone.ecommerce.config;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.jdbc.datasource.init.DataSourceInitializer;
import org.springframework.jdbc.datasource.init.ResourceDatabasePopulator;
import org.springframework.core.io.ClassPathResource;

@Configuration
public class DatabaseConfig {

    @Value("${spring.datasource.username}")
    private String username;

    @Value("${spring.datasource.password}")
    private String password;

    @Bean
    @Primary
    public DataSource dataSource() {
        String url = "jdbc:mysql://localhost:3306";
        
        // First, try to create the database
        DataSource tempDataSource = DataSourceBuilder.create()
            .url(url)
            .username(username)
            .password(password)
            .driverClassName("com.mysql.cj.jdbc.Driver")
            .build();

        try {
            tempDataSource.getConnection().createStatement().execute("CREATE DATABASE IF NOT EXISTS sga");
        } catch (Exception e) {
            throw new RuntimeException("Error creating database: " + e.getMessage(), e);
        }

        // Now create the actual datasource with the database
        return DataSourceBuilder.create()
            .url(url + "/sga")
            .username(username)
            .password(password)
            .driverClassName("com.mysql.cj.jdbc.Driver")
            .build();
    }

    @Bean
    public DataSourceInitializer dataSourceInitializer(DataSource dataSource) {
        ResourceDatabasePopulator populator = new ResourceDatabasePopulator();
        populator.addScript(new ClassPathResource("db/migration/V1__init.sql"));

        DataSourceInitializer initializer = new DataSourceInitializer();
        initializer.setDataSource(dataSource);
        initializer.setDatabasePopulator(populator);
        return initializer;
    }
}