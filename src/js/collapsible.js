document.querySelectorAll(".collapsible").forEach(item => {
	item.addEventListener("click", function() {
		item.classList.toggle("collapsed")
		let content = item.nextElementSibling
		if (content.style.maxHeight) {
			content.style.maxHeight = null
		} else {
			content.style.maxHeight = content.scrollHeight + "px"
		}
	})
})
