package com.example.ttms.web.RESTful;

import com.example.ttms.model.ResponseResult;
import com.example.ttms.service.EmployeeService;
import com.example.ttms.utils.MD5;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jakarta.servlet.http.HttpServletRequest;

@RestController
@RequestMapping("/rest")
public class LoginAndLogout {

    @Autowired
    private EmployeeService employeeService;

    //登录
    @RequestMapping(value = "/login",method = RequestMethod.POST)
    public ResponseResult login(HttpServletRequest request, @RequestParam("username") String username,
                                @RequestParam("password") String password){
        String vaildPasswd = employeeService.getPasswordByName(username);
        if(MD5.codeByMD5(password).equals(vaildPasswd)){
            if(request.getSession(false) != null) {
                request.getSession(false).invalidate();
            }
            com.example.ttms.model.Employee emp = employeeService.getEmployeeByName(username);
            request.getSession().setAttribute("user", emp);
            return new ResponseResult(true,emp);
        }else{
            return new ResponseResult(false,"身份验证失败");
        }
    }

    //注销
    @RequestMapping(value = "/logout",method = RequestMethod.GET)
    public void logout(HttpServletRequest request){
        if(request.getSession(false) != null) {
            request.getSession(false).invalidate();
        }
    }
}
