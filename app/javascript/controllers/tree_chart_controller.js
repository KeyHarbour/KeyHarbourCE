import { Controller } from "@hotwired/stimulus"
import * as d3 from "d3"

export default class extends Controller {
  static values = { data: Array }

  connect() {
    const rawData = this.dataValue
    console.log("Raw data for tree chart:", rawData)
    if (!rawData.length) return

    this.root = d3.stratify()
      .id(d => d.id)
      .parentId(d => d.parent_id)
      (rawData)

    this.width = 1000 // Augmenté pour accommoder le texte
    this.height = 800
    this.margin = { top: 20, right: 120, bottom: 30, left: 120 }
    this.duration = 750

    this.svg = d3.select("#tree-svg")
      .attr("width", this.width)
      .attr("height", this.height)
      .append("g")
      .attr("transform", `translate(${this.margin.left},${this.margin.top})`)

    // On augmente l'espacement vertical entre les nœuds car ils font 2 lignes
    this.treeLayout = d3.tree().size([this.height - 100, this.width - 400])

    if (this.root.children) {
      this.root.children.forEach(child => this.collapse(child));
    }

    this.root.x0 = this.height / 2
    this.root.y0 = 0

    this.update(this.root)
  }
  
  collapse(d) {
    if (d.children) {
      d._children = d.children;
      // Utilisation d'une flèche ici aussi pour ne pas perdre le "this"
      d._children.forEach(child => this.collapse(child)); 
      d.children = null;
    }
  }
  
  toggle(event, d) {
    if (d.children) {
      d._children = d.children
      d.children = null
    } else {
      d.children = d._children
      d._children = null
    }
    this.update(d)
  }

  update(source) {
    const nodes = this.treeLayout(this.root).descendants()
    const links = this.root.links()

    const node = this.svg.selectAll("g.node")
      .data(nodes, d => d.id)

    const nodeEnter = node.enter().append("g")
      .attr("class", "node")
      .attr("transform", `translate(${source.y0},${source.x0})`)
      .on("click", (event, d) => this.toggle(event, d))
      .style("cursor", "pointer")

    nodeEnter.append("circle")
      .attr("r", 1e-6)
      .style("fill", d => d._children ? "lightsteelblue" : "#fff")
      .style("stroke", "steelblue")
      .style("stroke-width", "3px")

    // --- CONSTRUCTION DU TEXTE SUR 2 LIGNES ---
    const textGroup = nodeEnter.append("text")
      .attr("dy", ".35em")
      .attr("x", d => d.children || d._children ? -15 : 15)
      .attr("text-anchor", d => d.children || d._children ? "end" : "start")
      .style("font-family", "sans-serif")
      .style("font-size", "12px")

    // Ligne 1 : Le NOM
    textGroup.append("tspan")
      .attr("x", d => d.children || d._children ? -15 : 15)
      .attr("dy", "-0.3em") // On remonte un peu par rapport au centre
      .style("font-weight", "bold")
      .text(d => d.data.name)

    // Ligne 2 : Le ROLE
    textGroup.append("tspan")
      .attr("x", d => d.children || d._children ? -15 : 15)
      .attr("dy", "1.2em") // On descend en dessous de la ligne 1
      .style("fill", "#666")
      .style("font-weight", "normal")
      .text(d => d.data.role || "")

    // Ligne 2 : Le ROLE
    textGroup.append("tspan")
      .attr("x", d => d.children || d._children ? -15 : 15)
      .attr("dy", "1.2em") // On descend en dessous de la ligne 1
      .style("fill", "#666")
      .style("font-weight", "normal")
      .text(d => d.data.total_cost || "")

    const nodeUpdate = nodeEnter.merge(node)
      .transition().duration(this.duration)
      .attr("transform", d => `translate(${d.y},${d.x})`)

    nodeUpdate.select("circle")
      .attr("r", 10)
      .style("fill", d => d._children ? "lightsteelblue" : "#fff")

    const nodeExit = node.exit().transition().duration(this.duration)
      .attr("transform", `translate(${source.y},${source.x})`)
      .remove()

    nodeExit.select("circle").attr("r", 1e-6)

    const link = this.svg.selectAll("path.link")
      .data(links, d => d.target.id)

    const linkEnter = link.enter().insert("path", "g")
      .attr("class", "link")
      .attr("d", d3.linkHorizontal().x(source.y0).y(source.x0))
      .style("fill", "none")
      .style("stroke", "#ccc")
      .style("stroke-width", "2px")

    link.merge(linkEnter).transition().duration(this.duration)
      .attr("d", d3.linkHorizontal()
        .x(d => d.y)
        .y(d => d.x))

    link.exit().transition().duration(this.duration)
      .attr("d", d3.linkHorizontal().x(source.y).y(source.x))
      .remove()

    nodes.forEach(d => {
      d.x0 = d.x
      d.y0 = d.y
    })
  }
}
