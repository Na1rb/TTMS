/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{vue,js}'],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', 'Microsoft YaHei', 'system-ui', 'sans-serif']
      }
    }
  },
  plugins: []
}
