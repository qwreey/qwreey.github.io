document.addEventListener("DOMContentLoaded", function(event) {
	document.querySelectorAll(".collapsible").forEach(item => {
		let child = item.querySelector(".children")
		let childHolder = item.querySelector(".children>.childrenHolder")
		let collapseButton = item.querySelector(".collapseButton")
		let setSize = ()=>{ child.style.maxHeight = item.classList.contains("collapsed") ? "0px" : childHolder.clientHeight + "px" }
		collapseButton.addEventListener("click", function() {
			item.classList.toggle("collapsed")
			setSize()
		})
		new ResizeObserver(()=>{child.style.maxHeight="fit-content";setSize()}).observe(childHolder)
		setSize()
	})
})
