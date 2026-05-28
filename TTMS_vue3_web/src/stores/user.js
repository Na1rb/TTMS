import { defineStore } from 'pinia'
import { USER_KEY } from '../config/constants'

export const useUserStore = defineStore('user', {
  state: () => ({
    user: JSON.parse(sessionStorage.getItem(USER_KEY) || 'null')
  }),
  getters: {
    isLogin: (state) => !!state.user,
    roleName: (state) => ({ 1: '经理', 2: '售票员', 3: '管理员', 4: 'VIP会员', 5: '普通用户' }[state.user?.emp_type] || '未知角色')
  },
  actions: {
    setUser(user) {
      this.user = user
      sessionStorage.setItem(USER_KEY, JSON.stringify(user))
    },
    clear() {
      this.user = null
      sessionStorage.removeItem(USER_KEY)
    }
  }
})
