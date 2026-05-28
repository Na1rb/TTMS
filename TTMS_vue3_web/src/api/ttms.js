import http, { get, post } from './http'

export const authApi = {
  login: (username, password) => post('/login', { username, password }),
  logout: () => get('/logout')
}

export const employeeApi = {
  list: () => get('/employee/getAllEmp'),
  search: (name) => get('/employee/getEmpByPartName', { name }),
  add: (employee) => post('/employee/add', employee),
  update: (employee) => post('/employee/update', employee),
  remove: (id) => get('/employee/delete', { id }),
  updatePassword: (payload) => post('/employee/updatePassword', payload)
}

export const studioApi = {
  list: () => get('/studio/getAllStudio'),
  search: (name) => get('/studio/getStudioByPartName', { name }),
  add: (studio) => post('/studio/add', studio),
  update: (studio) => post('/studio/update', studio),
  remove: (id) => get('/studio/delete', { id })
}

export const playApi = {
  list: () => get('/play/getAllPlay'),
  search: (name) => get('/play/getPlayByPartName', { name }),
  byDate: (date) => get('/play/selectPlayByDate', { date }),
  add: (play) => post('/play/add', play),
  update: (play) => post('/play/update', play),
  remove: (id) => get('/play/delete', { id })
}

export const scheduleApi = {
  list: (playId) => get('/schedule/getScheduleByPlayId', { play_id: playId }),
  byPlayId: (play_id) => get('/schedule/getScheduleByPlayId', { play_id }),
  byPlayIdDate: (play_id, date) => get('/schedule/getScheduleByPlayIdDate', { play_id, date }),
  todayLeast: (play_id) => get('/schedule/getTodayLeastSchedules', { play_id }),
  byStudioId: (id) => get('/schedule/getScheduleByStudioId', { id }),
  add: (schedule) => post('/schedule/add', schedule),
  update: (schedule) => post('/schedule/update', schedule),
  remove: (id) => get('/schedule/delete', { id })
}

export const ticketApi = {
  byScheduleId: (id) => get('/ticket/getTicketByScheduleId', { id })
}

export const saleApi = {
  create: (tickets, flag) => post('/sale/create', { json: JSON.stringify({ tickets }), flag }),
  pay: (id, flag, answer) => {
    const params = { id, flag }
    if (answer !== undefined && answer !== null) params.answer = answer
    return get('/sale/pay', params)
  },
  cancel: (id, flag) => get('/sale/cancel', { id, flag })
}

export const dictionaryApi = {
  list: () => get('/dataDict/getAllDataDict'),
  search: (name) => get('/dataDict/getDataDictByPartName', { name }),
  byParentName: (name) => get('/dataDict/getDataDictByParentName', { name }),
  add: (dictionary) => post('/dataDict/add', dictionary),
  update: (dictionary) => post('/dataDict/update', dictionary),
  remove: (id) => get('/dataDict/delete', { id })
}

export const seatApi = {
  byStudioId: (id) => get('/seat/getStudioSeats', { id }),
  init: (id) => get('/seat/init', { id }),
  updateByStudioId: (studio_id, seats) => post('/seat/updateByStudioId', { json: JSON.stringify({ studio_id, seats }) })
}

export const orderApi = {
  create: saleApi.create,
  pay: saleApi.pay,
  cancel: saleApi.cancel,
  unfinishedByEmployeeId: (id) => get('/analysis/selectCancelSaleByEmployeeId', { id })
}

export const profileApi = {
  updatePassword: (payload) => employeeApi.updatePassword(payload)
}

export const salesApi = {
  create: saleApi.create,
  pay: saleApi.pay,
  cancel: saleApi.cancel,
  employeeAnalysis: () => get('/analysis/getEmployeeAnalysis'),
  playTicketAmount: () => get('/analysis/getPlayTicketAmount'),
  employeeAnalysisByEmployeeId: (id) => get('/analysis/getEmployeeAnalysisByEmployeeId', { id }),
  saleAmountsByEmployeeName: () => get('/analysis/getSelectSaleAmountsByEmployeeName'),
  playPercentByName: () => get('/analysis/getPlayPercentByName'),
  playPercentByDate: (date) => get('/analysis/getAllPlayPercentByDate', { date }),
  unfinishedByEmployeeId: (id) => get('/analysis/selectCancelSaleByEmployeeId', { id })
}

export const uploadApi = {
  upload: async (url, file, extra = {}) => {
    const formData = new FormData()
    formData.append('file', file)
    Object.entries(extra).forEach(([key, value]) => {
      if (value !== undefined && value !== null) formData.append(key, value)
    })
    const { data } = await http.post(url, formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
    return data
  }
}
