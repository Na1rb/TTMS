package com.example.ttms.serviceimpl;

import com.example.ttms.dao.TicketDAO;
import com.example.ttms.model.Schedule;
import com.example.ttms.model.Seat;
import com.example.ttms.model.SeatAndTicket;
import com.example.ttms.model.Ticket;
import com.example.ttms.service.ScheduleService;
import com.example.ttms.service.SeatService;
import com.example.ttms.service.TicketService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;

import java.util.List;

@Service("TicketService")
public class TicketServiceImpl implements TicketService {
    @Autowired
    private TicketDAO ticketDAO;

    @Autowired
    @Lazy
    private SeatService seatService;

    @Autowired
    private ScheduleService scheduleService;

    //根据id获取信息
    @Override
    public Ticket selectTicketById(Long id) { return ticketDAO.selectTicketById(id);}

    //增加
    @Override
    public boolean addTicket(Ticket ticket){
        if(ticketDAO.selectTicketById(ticket.getTicket_id())==null){
            ticketDAO.addTicket(ticket);
            return true;
        }
        return  false;
    }

    //删除
    @Override
    public boolean deleteTicketById(Long id){
        if(ticketDAO.selectTicketById(id)!=null){
            ticketDAO.deleteTicketById(id);
            return true;
        }
        return  false;
    }

    //更新
    @Override
    public boolean updateTicketById(Ticket ticket){
        Ticket ticket_old = ticketDAO.selectTicketById(ticket.getTicket_id());

        //不存在
        if(ticket_old==null){
            return false;
        }

        if(ticket_old.getTicket_id().equals(ticket.getTicket_id())||
                ticket.getTicket_id()!=null){
            ticketDAO.updateTicketById(ticket);
            return true;
        }
        else
            return false;
    }

    //根据演出计划id批量生成票(添加演出计划时)
    public boolean initTicketByScheduleId(Integer id){
        Schedule schedule = scheduleService.selectScheduleById(id);
        if(schedule!=null){
            List<Seat> seats = seatService.selectStudioSeatsByStudioId(schedule.getStudio_id());
            for(Seat seat : seats){
                if(seat.getSeat_status() == 1){
                    //给正常的座位添加票
                    ticketDAO.addTicket(new Ticket(seat.getSeat_id(),schedule.getSched_id(),schedule.getSched_ticket_price(),Short.parseShort("0")));
                }
            }
            return true;
        }else{
            return false;
        }
    }

    //根据演出计划id批量删除票（删除演出计划时）
    @Override
    public boolean deleteTicketByScheduleId(Integer sched_id) {
        Schedule schedule = scheduleService.selectScheduleById(sched_id);
        if(schedule != null){
            ticketDAO.deleteTicketByScheduleId(sched_id);
            return true;
        }else{
            return false;
        }
    }

    //根据演出计划批量提取票
    public List<SeatAndTicket> selectTicketByScheduleId(Integer sched_id){
        //先给超时的订单的票解锁
        releaseExpiredLocks();
        Schedule schedule = scheduleService.selectScheduleById(sched_id);
        if(schedule != null){
            return ticketDAO.selectTicketByScheduleId(sched_id);
        }else{
            return null;
        }
    }

    //判断该票是否能被锁定，锁定超过5分钟自动解锁
    public boolean isLocked(Long ticket_id){
        Ticket ticket = ticketDAO.selectTicketById(ticket_id);
        if(ticket.getTicket_locked_time() == null){
            return true;
        }
        //锁定超过5分钟则自动解锁
        long elapsed = System.currentTimeMillis() - ticket.getTicket_locked_time().getTime();
        if(elapsed > 5 * 60 * 1000){
            return true;
        }
        return false;
    }

    //更新上锁时间
    public void updateLockedTime(Ticket ticket){
        ticketDAO.updateLockedTime(ticket);
    }

    //给取消的订单中的票解锁
    public void UnLockTickets(Short status,Long saleID){
        ticketDAO.UnLockTickets(status,saleID);
    }

    //释放过期的占座（超过5分钟）
    @Override
    public void releaseExpiredLocks() {
        java.util.Date expireTime = new java.util.Date(System.currentTimeMillis() - 5 * 60 * 1000);
        ticketDAO.releaseExpiredLocks(expireTime);
    }

    //根据演出计划提取卖出的票
    public List<Ticket> selectSelledTicketByScheduleId(Integer sched_id){
        return ticketDAO.selectSelledTicketByScheduleId(sched_id);
    }
}
