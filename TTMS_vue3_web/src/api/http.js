import axios from 'axios'

const http = axios.create({
  baseURL: '/rest',
  timeout: 15000,
  withCredentials: true,
  headers: {
    'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
  }
})

function toForm(data = {}) {
  const params = new URLSearchParams()
  Object.entries(data).forEach(([key, value]) => {
    if (value !== undefined && value !== null) params.append(key, value)
  })
  return params
}

export async function get(url, params) {
  const { data } = await http.get(url, { params })
  return data
}

export async function post(url, data) {
  const res = await http.post(url, toForm(data))
  return res.data
}

export default http
