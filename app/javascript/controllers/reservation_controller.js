import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dateSection", "timeSection", "roomSection", "confirmSection", 
                   "roomId", "startTime", "endTime", "summary", "form"]
  
  connect() {
    this.selectedDate = null
    this.selectedTime = null
    this.selectedRoom = null
  }
  
  selectDate(event) {
    const dateElement = event.currentTarget
    const date = dateElement.dataset.date
    
    if (!date) return
    
    // Update selected date visual
    this.element.querySelectorAll('[data-date]').forEach(el => {
      el.classList.remove('bg-blue-500', 'text-white')
    })
    dateElement.classList.add('bg-blue-500', 'text-white')
    
    this.selectedDate = date
    
    // Load time slots
    fetch(`/reservations/time_slots?date=${date}`)
      .then(response => response.text())
      .then(html => {
        document.getElementById('time-slots-container').innerHTML = html
        this.timeSectionTarget.classList.remove('hidden')
        this.roomSectionTarget.classList.add('hidden')
        this.confirmSectionTarget.classList.add('hidden')
      })
  }
  
  selectTime(event) {
    const timeElement = event.currentTarget
    const time = timeElement.dataset.time
    
    // Update selected time visual
    this.element.querySelectorAll('.time-slot-btn').forEach(el => {
      el.classList.remove('bg-blue-500', 'text-white', 'selected')
      el.classList.add('hover:bg-blue-100', 'hover:border-blue-500')
    })
    timeElement.classList.add('bg-blue-500', 'text-white', 'selected')
    timeElement.classList.remove('hover:bg-blue-100', 'hover:border-blue-500')
    
    this.selectedTime = time
    
    // Calculate end time - fixed 30 minutes
    const duration = 30
    const startTime = new Date(time)
    const endTime = new Date(startTime.getTime() + duration * 60000)
    
    // Load available rooms
    fetch(`/reservations/available_rooms?start_time=${startTime.toISOString()}&end_time=${endTime.toISOString()}`)
      .then(response => response.text())
      .then(html => {
        document.getElementById('rooms-container').innerHTML = html
        this.roomSectionTarget.classList.remove('hidden')
        this.confirmSectionTarget.classList.add('hidden')
      })
  }
  
  selectRoom(event) {
    const roomElement = event.currentTarget
    const roomId = roomElement.dataset.roomId
    const roomNumber = roomElement.dataset.roomNumber
    
    // Update selected room visual
    this.element.querySelectorAll('.room-btn').forEach(el => {
      el.classList.remove('bg-blue-100', 'border-blue-500')
    })
    roomElement.classList.add('bg-blue-100', 'border-blue-500')
    
    this.selectedRoom = { id: roomId, number: roomNumber }
    
    // Set form values - fixed 30 minutes
    const duration = 30
    const startTime = new Date(this.selectedTime)
    const endTime = new Date(startTime.getTime() + duration * 60000)
    
    this.roomIdTarget.value = roomId
    this.startTimeTarget.value = startTime.toISOString()
    this.endTimeTarget.value = endTime.toISOString()
    
    // Update summary
    const dateStr = startTime.toLocaleDateString('ko-KR', { 
      year: 'numeric', month: 'long', day: 'numeric', weekday: 'short' 
    })
    const startTimeStr = startTime.toLocaleTimeString('ko-KR', { 
      hour: '2-digit', minute: '2-digit' 
    })
    const endTimeStr = endTime.toLocaleTimeString('ko-KR', { 
      hour: '2-digit', minute: '2-digit' 
    })
    
    this.summaryTarget.innerHTML = `
      <div>날짜: ${dateStr}</div>
      <div>시간: ${startTimeStr} - ${endTimeStr}</div>
      <div>연습실: ${roomNumber}번</div>
    `
    
    this.confirmSectionTarget.classList.remove('hidden')
  }
  
  prevMonth(event) {
    event.preventDefault()
    const currentMonth = document.querySelector('[data-month]').dataset.month
    const date = new Date(currentMonth + '-01')
    date.setMonth(date.getMonth() - 1)
    this.loadCalendar(date)
  }
  
  nextMonth(event) {
    event.preventDefault()
    const currentMonth = document.querySelector('[data-month]').dataset.month
    const date = new Date(currentMonth + '-01')
    date.setMonth(date.getMonth() + 1)
    this.loadCalendar(date)
  }
  
  loadCalendar(date) {
    const dateStr = date.toISOString().split('T')[0]
    fetch(`/reservations/calendar?date=${dateStr}`)
      .then(response => response.text())
      .then(html => {
        document.getElementById('calendar-container').innerHTML = html
      })
  }
}