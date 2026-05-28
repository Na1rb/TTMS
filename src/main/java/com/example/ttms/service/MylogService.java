package com.example.ttms.service;

import com.example.ttms.model.Mylog;

public interface MylogService {
    //根据id
    Mylog selectMylogById(Integer id);

    //新增
    boolean addMylog(Mylog mylog);

    //删除
    boolean deleteMylogById(Integer id);
}
