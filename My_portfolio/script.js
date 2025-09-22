// Animate progress bars in skills section when in view
function animateSkillProgressBars() {
	const skillsSection = document.getElementById('skills-section');
	if (!skillsSection) return;
	const bars = skillsSection.querySelectorAll('.progress-fill');
	bars.forEach(bar => {
		const target = bar.getAttribute('data-width');
		bar.style.width = target;
	});
}

// skills animation flag
let skillsAnimated = false;

// Typing effect and initialization for About Me + navigation + modal
function initApp() {
	try {
		// About paragraph is static now; animation handled by CSS.
	} catch (err) {
		// avoid breaking rest of script
		console.error('Init typing failed:', err);
	}

	// Navigation: if the target section exists on this page, smooth-scroll to it;
	// otherwise navigate to main.html with a hash so the browser will open the page at that section.
	function bindNav(btnId, sectionId, fallbackHref) {
		const btn = document.getElementById(btnId);
		if (!btn) return;
		btn.addEventListener('click', function(e) {
			e.preventDefault();
			const section = sectionId ? document.getElementById(sectionId) : null;
			if (section) {
				try {
					const rect = section.getBoundingClientRect();
					const top = window.scrollY + rect.top - 20;
					window.scrollTo({ top: Math.max(0, top), behavior: 'smooth' });
					history.replaceState ? history.replaceState(null, null, '#' + sectionId) : (window.location.hash = sectionId);
				} catch (err) {
					section.scrollIntoView({ behavior: 'smooth' });
				}
			} else {
				window.location.href = fallbackHref;
			}
		});
	}

	// Project button should scroll to top main section if available
	bindNav('project-btn', 'main-section', 'main.html#main-section');
	// Certificates and Education
	bindNav('cert-btn', 'certificates-section', 'main.html#certificates-section');
	bindNav('edu-btn', 'education-section', 'main.html#education-section');
	// Skills (if you later add a skills section)
	bindNav('skills-btn', 'skills-section', 'main.html#skills-section');

	// Register IntersectionObserver for skills now that DOM is ready
	try {
		const skillsSection = document.getElementById('skills-section');
		if ('IntersectionObserver' in window && skillsSection) {
			const observer = new IntersectionObserver((entries) => {
				entries.forEach(entry => {
					if (entry.isIntersecting && !skillsAnimated) {
						animateSkillProgressBars();
						skillsAnimated = true;
						observer.unobserve(entry.target);
					}
				});
			}, { threshold: 0.25 });
			observer.observe(skillsSection);
		}
		// fallback scroll check
		window.addEventListener('scroll', function onScroll() {
			if (skillsAnimated) return;
			const ss = document.getElementById('skills-section');
			if (!ss) return;
			const rect = ss.getBoundingClientRect();
			if (rect.top < window.innerHeight && rect.bottom > 0) {
				animateSkillProgressBars();
				skillsAnimated = true;
				window.removeEventListener('scroll', onScroll);
			}
		});
	} catch (err) {
		console.warn('Skills observer failed:', err);
	}

	// Certificate modal logic
	const certModal = document.getElementById('cert-modal');
	const certModalImg = document.getElementById('cert-modal-img');
	const certModalDownload = document.getElementById('cert-modal-download');
	const certModalClose = document.querySelector('.cert-modal-close');
	document.querySelectorAll('.cert-img').forEach(img => {
		img.addEventListener('click', function() {
			const src = img.getAttribute('data-cert') || img.getAttribute('src');
			if (certModalImg) {
				certModalImg.src = src;
				certModalImg.alt = img.alt || 'Certificate Preview';
			}
			if (certModalDownload) {
				certModalDownload.href = src;
				certModalDownload.download = src.split('/').pop();
			}
			if (certModal) certModal.classList.add('active');
		});
	});
	if (certModalClose) {
		certModalClose.addEventListener('click', function() {
			if (certModal) certModal.classList.remove('active');
			if (certModalImg) certModalImg.src = '';
		});
	}
	// Close modal on overlay click
	if (certModal) {
		certModal.addEventListener('click', function(e) {
			if (e.target === certModal) {
				certModal.classList.remove('active');
				if (certModalImg) certModalImg.src = '';
			}
		});
	}
}

// Ensure initApp runs whether DOMContentLoaded already fired or not
if (document.readyState === 'loading') {
	document.addEventListener('DOMContentLoaded', initApp);
} else {
	initApp();
}
