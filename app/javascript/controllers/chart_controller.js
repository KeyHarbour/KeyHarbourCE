// app/javascript/controllers/chart_controller.js
import { Controller } from "@hotwired/stimulus"
import ApexCharts from "apexcharts"

export default class extends Controller {
  static targets = ["canvas"]
  static values = { 
    series: Array, 
    labels: Array, 
    type: { type: String, default: 'area' },
    legendPosition: { type: String, default: 'bottom' } 
  }

  connect() {
    console.log("ChartController connected")
    console.log("Series:", this.seriesValue)
    const options = {
      chart: { type: this.typeValue, height: 350, stacked: true },
      series: ['bar', 'pie'].includes(this.typeValue) 
        ? this.seriesValue 
        : [{ data: this.seriesValue }],
      labels: this.labelsValue,
      legend: {
        position: this.legendPositionValue,
        horizontalAlign: 'center'
      }      
    }

    this.chart = new ApexCharts(this.canvasTarget, options)
    this.chart.render()
  }

  disconnect() {
    if (this.chart) this.chart.destroy()
  }
}