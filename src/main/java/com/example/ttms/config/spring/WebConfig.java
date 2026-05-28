package com.example.ttms.config.spring;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Spring Boot MVC 兼容配置。
 * 仅保留当前项目启动所需的跨域配置，避免 WebMvcConfigurationSupport
 * 覆盖 Spring Boot 默认 MVC 自动配置。
 */
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOrigins("http://localhost:5173")
                .allowedMethods("GET", "HEAD", "POST", "PUT", "PATCH", "DELETE", "OPTIONS", "TRACE")
                .allowCredentials(true);
    }
}
