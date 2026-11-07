import { Controller } from "@hotwired/stimulus"
import ApexCharts from "apexcharts"

// Connects to data-controller="treemap-chart"
export default class extends Controller {
  static targets = ["canvas"]
  static values = {
    series: Array
  }

  connect() {
    this.chartKey = 'chart-treemap'
    
    // 1. Lire la variable CSS demandée par Tabler
    const computedStyles = getComputedStyle(this.element)
    const baseColor = computedStyles.getPropertyValue('--chart-treemap-color-0').trim()
    
    // 2. La convertir en Hexadécimal pur pour qu'ApexCharts puisse calculer les ombrages (shades)
    const resolvedColor = this.resolveToHex(baseColor || 'var(--tblr-primary)')

    this.config = {
      chart: { 
        id: 'treemap', 
        type: 'treemap', 
        fontFamily: 'inherit', 
        height: 240, 
        parentHeightOffset: 0, 
        toolbar: { show: false }, 
        animations: { enabled: true } 
      },
      plotOptions: { 
        treemap: { 
          distributed: false, 
          enableShades: true, 
          shadeIntensity: 0.4 
        } 
      },
      dataLabels: { 
        enabled: true,
        style: {
          fontFamily: 'inherit',
          fontWeight: '600'
        }
      },
      // Récupère les données dynamiques injectées depuis Rails
      series: this.seriesValue,
      grid: { strokeDashArray: 4 },
      yaxis: { labels: { padding: 4 } },
      colors: [resolvedColor],
      legend: { show: false }
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

  // Convertit n'importe quelle variable CSS ou color-mix en Hexadécimal exploitable
  resolveToHex(colorStr) {
    if (!colorStr) return '#0054a6'
    if (colorStr.startsWith('#')) return colorStr.substring(0, 7)

    const probe = document.createElement('span')
    probe.style.cssText = 'position:absolute;visibility:hidden'
    probe.style.color = colorStr
    this.element.appendChild(probe)
    
    const resolved = getComputedStyle(probe).color
    probe.remove()

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
