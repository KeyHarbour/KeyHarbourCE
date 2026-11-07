import { Controller } from "@hotwired/stimulus"
import ApexCharts from "apexcharts"

// Connects to data-controller="pie-chart"
export default class extends Controller {
  static targets = ["canvas"]
  static values = {
    series: Array,
    labels: Array
  }

  connect() {
    this.chartKey = 'chart-demo-pie'
    
    // 1. Déclarer les variables CSS que vous souhaitez utiliser
    const cssVariables = [
      '--chart-demo-pie-color-0',
      '--chart-demo-pie-color-1',
      '--chart-demo-pie-color-2',
      '--chart-demo-pie-color-3'
    ]

    // 2. Aller chercher les couleurs calculées par le navigateur et les nettoyer au format Hex
    const computedStyles = getComputedStyle(this.element)
    const colors = cssVariables.map(variable => {
      const rawColor = computedStyles.getPropertyValue(variable).trim()
      return this.resolveToHex(rawColor)
    })
    
    this.config = {
      chart: { 
        id: 'demo-pie', 
        type: 'donut', 
        fontFamily: 'inherit', 
        height: 240, 
        sparkline: { enabled: false }, 
        animations: { enabled: false } 
      },
      series: this.seriesValue,
      labels: this.labelsValue,
      grid: { strokeDashArray: 4 },
      colors: colors, // Utilise vos variables CSS lues en direct
      legend: { show: true, position: 'bottom', offsetY: 12, markers: { size: 5, strokeWidth: 0, shape: 'circle' }, itemMargin: { horizontal: 8, vertical: 8 } },
      tooltip: { fillSeriesColor: false },
      dataLabels: {
        enabled: true,
        style: {
          fontFamily: 'inherit',
          fontSize: '12px',
          fontWeight: 'bold',
          colors: ['#fff', '#fff', '#fff', '#1e293b']
        },
        formatter: function (val, opts) {
          return opts.w.config.series[opts.seriesIndex]
        },
        dropShadow: { enabled: false }
      },
      plotOptions: {
        pie: {
          donut: { size: '65%' }
        }
      }
    }
    
    window.tabler_chart ??= {}
    this.initChart()
  }

  disconnect() {
    if (window.tabler_chart[this.chartKey]) {
      window.tabler_chart[this.chartKey].destroy()
      delete window.tabler_chart[this.chartKey]
    }
  }

  // Traduit n'importe quel format (color-mix, rgb, rgba) en Hexadécimal pur pour ApexCharts
  resolveToHex(colorStr) {
    if (!colorStr) return '#000000'
    if (colorStr.startsWith('#')) return colorStr.substring(0, 7)

    // On utilise un élément temporaire injecté LOCALEMENT dans le composant
    // pour hériter des styles et forcer le moteur du navigateur à résoudre le color-mix
    const probe = document.createElement('span')
    probe.style.cssText = 'position:absolute;visibility:hidden'
    probe.style.color = colorStr
    this.element.appendChild(probe)
    
    // Le navigateur convertit automatiquement le color-mix en rgb() ou rgba() standard
    const resolved = getComputedStyle(probe).color
    probe.remove()

    // Extraction des chiffres du rgb/rgba
    const matches = resolved.match(/\d+(\.\d+)?/g)
    if (matches && matches.length >= 3) {
      const r = parseInt(matches[0]).toString(16).padStart(2, '0')
      const g = parseInt(matches[1]).toString(16).padStart(2, '0')
      const b = parseInt(matches[2]).toString(16).padStart(2, '0')
      return `#${r}${g}${b}`
    }
    return colorStr
  }

  initChart() {
    const targetElement = this.hasCanvasTarget ? this.canvasTarget : this.element
    window.tabler_chart[this.chartKey] = new ApexCharts(targetElement, this.config)
    window.tabler_chart[this.chartKey].render()
  }
}
