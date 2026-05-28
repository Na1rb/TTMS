package com.example.ttms.web.RESTful;

import com.example.ttms.model.Employee;
import com.example.ttms.model.ResponseResult;
import com.example.ttms.model.Sale;
import com.example.ttms.model.Schedule;
import com.example.ttms.model.SeatAndTicket;
import com.example.ttms.model.Ticket;
import com.example.ttms.service.SaleService;
import com.example.ttms.service.ScheduleService;
import com.example.ttms.service.TicketService;
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.util.Calendar;
import java.util.List;
import java.util.Random;

@RestController
@RequestMapping("rest/sale")
public class SaleRestController {

    @Autowired
    private SaleService saleService;

    @Autowired
    private TicketService ticketService;

    @Autowired
    private ScheduleService scheduleService;

    //根据演出厅ID更新座位信息
    @RequestMapping(value = "/create",method = RequestMethod.POST)
    public ResponseResult update(HttpServletRequest request,@RequestParam("json") String json,@RequestParam("flag") Integer flag){
        Employee employee = (Employee)request.getSession().getAttribute("user");
        ResponseResult roleCheck = validatePurchaseRole(employee);
        if (roleCheck != null) {
            return roleCheck;
        }

        JSONObject jsonObject = JSON.parseObject(json);
        List<SeatAndTicket> seatAndTickets = JSONArray.parseArray(jsonObject.getString("tickets"),SeatAndTicket.class);
        if (flag == 1) {
            ResponseResult permissionCheck = validatePurchaseWindow(employee, seatAndTickets);
            if (permissionCheck != null) {
                return permissionCheck;
            }
        }
        Sale sale = saleService.dealSale(seatAndTickets,flag,employee.getEmp_id());
        if(sale == null){
            return new ResponseResult(false,"订单生成失败,已被别人锁定");
        }else {
            Random rand = new Random();
            int a = rand.nextInt(50) + 10;
            int b = rand.nextInt(50) + 10;
            int answer = a + b;
            HttpSession session = request.getSession();
            session.setAttribute("captcha_" + sale.getSale_ID(), answer);

            JSONObject result = new JSONObject();
            result.put("sale", sale);
            result.put("question", a + " + " + b + " = ?");
            return new ResponseResult(true, result);
        }
    }

    private ResponseResult validatePurchaseRole(Employee employee) {
        if (employee == null) {
            return new ResponseResult(false, "请先登录");
        }
        Integer empType = employee.getEmp_type();
        if (empType == null || (empType != 2 && empType != 4 && empType != 5)) {
            return new ResponseResult(false, "仅售票员、VIP 和普通用户允许购票");
        }
        return null;
    }

    private ResponseResult validatePurchaseWindow(Employee employee, List<SeatAndTicket> seatAndTickets) {
        if (employee == null || seatAndTickets == null || seatAndTickets.isEmpty()) {
            return new ResponseResult(false, "用户信息或票务信息无效");
        }
        boolean isVip = employee.getEmp_type() != null && employee.getEmp_type() == 4;
        int advanceMinutes = isVip ? 50 : 30;
        Calendar now = Calendar.getInstance();
        Calendar allowedTime = Calendar.getInstance();
        allowedTime.add(Calendar.MINUTE, advanceMinutes);
        for (SeatAndTicket seatAndTicket : seatAndTickets) {
            Ticket ticket = ticketService.selectTicketById(seatAndTicket.getTicket_id());
            if (ticket == null) {
                return new ResponseResult(false, "票不存在或已失效");
            }
            Schedule schedule = scheduleService.selectScheduleById(ticket.getSched_id());
            if (schedule == null || schedule.getSched_time() == null) {
                return new ResponseResult(false, "演出计划不存在或已失效");
            }
            if (!schedule.getSched_time().after(now.getTime())) {
                return new ResponseResult(false, "该场次已经开演，无法购票");
            }
            if (schedule.getSched_time().after(allowedTime.getTime())) {
                return new ResponseResult(false, isVip ? "VIP 用户仅可购买开演前 50 分钟内的场次" : "普通用户仅可购买开演前 30 分钟内的场次");
            }
        }
        return null;
    }

    //付款（含答题验证）
    @RequestMapping(value = "/pay",method = RequestMethod.GET)
    public ResponseResult pay(HttpServletRequest request,
                              @RequestParam("id")Long id,
                              @RequestParam("flag")Integer flag,
                              @RequestParam(value = "answer", required = false) Integer answer){
        Employee employee = (Employee)request.getSession().getAttribute("user");
        ResponseResult roleCheck = validatePurchaseRole(employee);
        if (roleCheck != null) {
            return roleCheck;
        }

        if (flag == 1 && answer != null) {
            HttpSession session = request.getSession();
            Integer correctAnswer = (Integer) session.getAttribute("captcha_" + id);
            // Session 过期或验证答案已失效
            if (correctAnswer == null) {
                return new ResponseResult(false, "验证已过期，请重新生成订单。座位仍为你保留。");
            }
            // 答案错误：不删除 session，允许用户重新计算并重试
            if (!correctAnswer.equals(answer)) {
                return new ResponseResult(false, "答案错误，请重新计算！座位仍为你保留。");
            }
            // 答案正确，清除验证信息
            session.removeAttribute("captcha_" + id);
        }

        Sale sale = new Sale();
        sale.setSale_time(Calendar.getInstance().getTime());
        sale.setSale_ID(id);
        sale.setSale_change(BigDecimal.ZERO);
        sale.setSale_status(Short.parseShort("1"));
        if(saleService.updateStatusById(sale,flag)){
            return new ResponseResult(true,"交易成功");
        }else{
            return new ResponseResult(false,"交易失败");
        }
    }

    //取消
    @RequestMapping(value = "/cancel",method = RequestMethod.GET)
    public ResponseResult cancel(HttpServletRequest request,@RequestParam("id")Long id,@RequestParam("flag")Integer flag){
        Employee employee = (Employee)request.getSession().getAttribute("user");
        ResponseResult roleCheck = validatePurchaseRole(employee);
        if (roleCheck != null) {
            return roleCheck;
        }

        if(saleService.cancelSaleById(id,flag)){
            return new ResponseResult(true,"取消成功");
        }else{
            return new ResponseResult(false,"取消失败");
        }
    }
}
