package com.example.ttms.serviceimpl;

import com.example.ttms.dao.SeatDAO;
import com.example.ttms.dao.StudioDAO;
import com.example.ttms.model.Seat;
import com.example.ttms.model.Studio;
import com.example.ttms.service.ScheduleService;
import com.example.ttms.service.SeatService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service("SeatService")
public class SeatServiceImpl implements SeatService {

    @Autowired
    private SeatDAO seatDAO;

    @Autowired
    private StudioDAO studioDAO;

    @Autowired
    @Lazy
    private ScheduleService scheduleService;

    //根据id获取座位信息
    public Seat selectSeatById(Integer id){
        return seatDAO.selectSeatById(id);
    }

    //根据演出厅ID获取演出厅内所有座位信息
    public List<Seat> selectStudioSeatsByStudioId(Integer id){
        return seatDAO.selectStudioSeatsByStudioId(id);
    }

    //新增座位
    public boolean addSeat(Seat seat){
        Studio studio = studioDAO.selectStudioById(seat.getStudio_id());
        //演出厅存在且座位的行列要满足演出厅中座位的行列
        if(studio != null && seat.getSeat_row() <= studio.getStudio_row_count() && seat.getSeat_row() > 0
                && seat.getSeat_column() <= studio.getStudio_col_count() && seat.getSeat_column() > 0){
            seatDAO.addSeat(seat);
            return true;
        }else{
            return false;
        }
    }

    //删除座位
    public boolean deleteSeatById(Integer id){
        if(seatDAO.selectSeatById(id) != null){
            seatDAO.deleteSeatById(id);
            return true;
        }else{
            return false;
        }
    }

    //根据演出厅ID批量初始化座位
    public boolean initSeatByStudioId(Integer id){
        Studio studio = studioDAO.selectStudioById(id);
        if(studio == null){
            return false;
        }

        List<Seat> seats = seatDAO.selectStudioSeatsByStudioId(id);
        if(seats != null && !seats.isEmpty()){
            return false;
        }

        for(int i = 1; i <= studio.getStudio_row_count(); i++){
            for(int j = 1 ;j <= studio.getStudio_col_count(); j++){
                Seat seat = new Seat(studio.getStudio_id(),i,j,Short.parseShort("1"));
                seatDAO.addSeat(seat);
            }
        }
        return true;
    }

    //根据演出厅ID更新座位信息
    @Override
    public boolean updateStatusByStudioId(Integer studio_id, Map<Integer,Integer> seats){
        Studio studio = studioDAO.selectStudioById(studio_id);
        List<com.example.ttms.model.Schedule> schedules = scheduleService.selectScheduleByStudioId(studio_id);
        //演出厅存在且尚未安排演出计划
        if(studio != null && (schedules == null || schedules.isEmpty())){
            for(Map.Entry<Integer,Integer> entry:seats.entrySet()){
                seatDAO.updateStatusById(entry.getKey(),entry.getValue());
            }
            return true;
        }else{
            return false;
        }

    }
}
