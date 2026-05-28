package com.example.ttms.serviceimpl;

import com.example.ttms.dao.SeatDAO;
import com.example.ttms.dao.StudioDAO;
import com.example.ttms.model.Schedule;
import com.example.ttms.model.Studio;
import com.example.ttms.service.ScheduleService;
import com.example.ttms.service.SeatService;
import com.example.ttms.service.StudioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service("StudioService")
public class StudioServiceImpl implements StudioService {

    @Autowired
    private StudioDAO studioDAO;

    @Autowired
    private SeatService seatService;

    @Autowired
    private SeatDAO seatDAO;

    @Autowired
    private ScheduleService scheduleService;

    private boolean hasSchedules(Integer studioId){
        List<Schedule> schedules = scheduleService.selectScheduleByStudioId(studioId);
        return schedules != null && !schedules.isEmpty();
    }

    private boolean isLayoutValid(Studio studio){
        return studio != null
                && studio.getStudio_name() != null
                && !studio.getStudio_name().trim().isEmpty()
                && studio.getStudio_row_count() != null
                && studio.getStudio_col_count() != null
                && studio.getStudio_row_count() > 0
                && studio.getStudio_col_count() > 0;
    }

    private void fillSeatCount(Studio studio){
        studio.setStudio_seat_count(studio.getStudio_row_count() * studio.getStudio_col_count());
    }

    //根据id获取演出厅信息
    @Override
    public Studio selectStudioById(Integer id){
        return studioDAO.selectStudioById(id);
    }

    //根据名称获取演出厅信息
    @Override
    public Studio selectStudioByName(String name){
        return studioDAO.selectStudioByName(name);
    }

    //根据关键字获取匹配的演出厅信息
    @Override
    public List<Studio> getAllStudioByPartName(String name){
        return studioDAO.getAllStudioByPartName("%"+name+"%");
    }

    //新增演出厅
    @Override
    @Transactional
    public boolean addStudio(Studio studio){
        if (!isLayoutValid(studio)){
            return false;
        }
        if (studioDAO.selectStudioByName(studio.getStudio_name()) == null){
            fillSeatCount(studio);
            studioDAO.addStudio(studio);
            return seatService.initSeatByStudioId(studio.getStudio_id());
        }
        return false;
    }

    //删除演出厅
    @Override
    @Transactional
    public boolean deleteStudioById(Integer id){
        //当演出厅存在并且没有安排演出计划
        if (studioDAO.selectStudioById(id) != null && !hasSchedules(id)){
            seatDAO.deleteSeatsByStudioId(id);
            studioDAO.deleteStudioById(id);
            return true;
        }
        return false;
    }

    //更新演出厅
    @Override
    @Transactional
    public boolean updateStudioById(Studio studio){
        Studio studio_old = studioDAO.selectStudioById(studio.getStudio_id());

        //该用户不存在
        if(studio_old == null || !isLayoutValid(studio)){
            return false;
        }

        //名称没有改变或者新名称可用
        if(!(studio_old.getStudio_name().equals(studio.getStudio_name()) ||
                studioDAO.selectStudioByName(studio.getStudio_name()) == null)){
            return false;
        }

        fillSeatCount(studio);

        boolean layoutChanged = !studio_old.getStudio_row_count().equals(studio.getStudio_row_count())
                || !studio_old.getStudio_col_count().equals(studio.getStudio_col_count());

        if(layoutChanged){
            if(hasSchedules(studio.getStudio_id())){
                return false;
            }
            studioDAO.updateStudioById(studio);
            seatDAO.deleteSeatsByStudioId(studio.getStudio_id());
            return seatService.initSeatByStudioId(studio.getStudio_id());
        }

        studioDAO.updateStudioById(studio);
        return true;
    }
}
