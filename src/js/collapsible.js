document.querySelectorAll(".collapsible").forEach(item => {
	item.addEventListener("click", function() {
		item.classList.toggle("collapsed")
	})
})
