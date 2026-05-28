package com.example.ttms;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan(basePackages = "com.example.ttms.dao")
public class TtmsApplication {

    public static void main(String[] args) {
        SpringApplication.run(TtmsApplication.class, args);
    }
}
