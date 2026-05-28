import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '../stores/user'
import Login from '../views/Login.vue'
import Layout from '../views/Layout.vue'
import Home from '../views/Home.vue'
import Employees from '../views/Employees.vue'
import Studios from '../views/Studios.vue'
import Plays from '../views/Plays.vue'
import SellTickets from '../views/SellTickets.vue'
import Dictionary from '../views/Dictionary.vue'
import Schedules from '../views/Schedules.vue'
import Seats from '../views/Seats.vue'
import SalesAnalysis from '../views/SalesAnalysis.vue'
import PendingOrders from '../views/PendingOrders.vue'
import Profile from '../views/Profile.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/login', component: Login },
    {
      path: '/',
      component: Layout,
      children: [
        { path: '', component: Home },
        { path: 'employees', component: Employees, meta: { roles: [3] } },
        { path: 'studios', component: Studios, meta: { roles: [3] } },
        { path: 'plays', component: Plays, meta: { roles: [1] } },
        { path: 'sell', component: SellTickets, meta: { roles: [2, 4, 5] } },
        { path: 'return-ticket', component: SellTickets, props: { mode: -1 }, meta: { roles: [2, 4, 5] } },
        { path: 'dictionary', component: Dictionary, meta: { roles: [1] } },
        { path: 'schedules', component: Schedules, meta: { roles: [1] } },
        { path: 'seats', component: Seats, meta: { roles: [1] } },
        { path: 'analysis', component: SalesAnalysis, meta: { roles: [1] } },
        { path: 'unhandled', component: PendingOrders, meta: { roles: [2] } },
        { path: 'profile', component: Profile }
      ]
    }
  ]
})

router.beforeEach((to) => {
  const userStore = useUserStore()
  if (to.path !== '/login' && !userStore.isLogin) return '/login'
  const roles = to.meta.roles
  if (roles && !roles.includes(userStore.user?.emp_type)) return '/'
})

export default router
