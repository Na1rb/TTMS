package com.example.ttms.config.spring;

import org.springframework.context.annotation.Configuration;

/**
 * 旧版 Servlet 容器根配置的兼容占位类。
 * 当前项目以 Spring Boot 启动为主，不再承担组件扫描职责，避免与自动配置重复。
 */
@Configuration
public class RootConfig {
}
