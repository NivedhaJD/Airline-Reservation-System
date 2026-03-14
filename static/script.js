// ============================================================
// Airline Reservation System - Main JavaScript
// ============================================================

document.addEventListener('DOMContentLoaded', function () {

  // ---- Hamburger / Mobile Menu ----
  const hamburger = document.querySelector('.hamburger');
  const navMenu   = document.querySelector('.navbar-nav');
  if (hamburger && navMenu) {
    hamburger.addEventListener('click', () => {
      navMenu.classList.toggle('open');
    });
    // Close menu when a nav link is clicked
    navMenu.querySelectorAll('a').forEach(link => {
      link.addEventListener('click', () => navMenu.classList.remove('open'));
    });
  }

  // ---- Auto-dismiss Flash Messages after 4s ----
  document.querySelectorAll('.flash-msg').forEach(msg => {
    setTimeout(() => {
      msg.style.transition = 'opacity 0.5s ease, max-height 0.5s ease';
      msg.style.opacity    = '0';
      msg.style.maxHeight  = '0';
      msg.style.overflow   = 'hidden';
      setTimeout(() => msg.remove(), 500);
    }, 4000);
  });

  // ---- Dynamic Meal List on Food Page ----
  const mealTypeSelect = document.getElementById('meal_type');
  const mealNameSelect = document.getElementById('meal_name');

  if (mealTypeSelect && mealNameSelect) {
    mealTypeSelect.addEventListener('change', function () {
      const selectedType = this.value;
      mealNameSelect.innerHTML = '<option value="">Loading meals...</option>';
      mealNameSelect.disabled = true;

      if (!selectedType) {
        mealNameSelect.innerHTML = '<option value="">-- Select meal type first --</option>';
        return;
      }

      // Fetch meals from Flask API
      fetch(`/api/meals/${encodeURIComponent(selectedType)}`)
        .then(res => res.json())
        .then(meals => {
          mealNameSelect.innerHTML = '<option value="">-- Select a meal --</option>';
          meals.forEach(meal => {
            const opt = document.createElement('option');
            opt.value       = meal.name;
            opt.textContent = `${meal.name}  —  ₹${meal.price.toFixed(2)}`;
            mealNameSelect.appendChild(opt);
          });
          mealNameSelect.disabled = false;
        })
        .catch(() => {
          mealNameSelect.innerHTML = '<option value="">Error loading meals</option>';
        });
    });
  }

  // ---- Confirm Cancel Ticket ----
  document.querySelectorAll('.cancel-form').forEach(form => {
    form.addEventListener('submit', function (e) {
      if (!confirm('Are you sure you want to cancel this ticket? This action cannot be undone.')) {
        e.preventDefault();
      }
    });
  });

  // ---- Form Validation: Password Match on Register ----
  const registerForm = document.getElementById('register-form');
  if (registerForm) {
    registerForm.addEventListener('submit', function (e) {
      const pass    = document.getElementById('password').value;
      const confirm = document.getElementById('confirm_password')?.value;
      if (confirm !== undefined && pass !== confirm) {
        e.preventDefault();
        showAlert('Passwords do not match!', 'error');
      }
    });
  }

  // ---- Search Form: Prevent empty origin & destination ----
  const searchForm = document.getElementById('search-form');
  if (searchForm) {
    searchForm.addEventListener('submit', function (e) {
      const origin = document.getElementById('origin')?.value.trim();
      const dest   = document.getElementById('destination')?.value.trim();
      if (!origin && !dest) {
        e.preventDefault();
        showAlert('Please enter at least Origin or Destination to search.', 'error');
      }
    });
  }

  // ---- Smooth Scroll for anchor links ----
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
      const target = document.querySelector(this.getAttribute('href'));
      if (target) {
        e.preventDefault();
        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }
    });
  });

  // ---- Print Ticket Button ----
  const printBtn = document.getElementById('print-ticket');
  if (printBtn) {
    printBtn.addEventListener('click', () => window.print());
  }

  // ---- Highlight Active Nav Link ----
  const currentPath = window.location.pathname;
  document.querySelectorAll('.navbar-nav a').forEach(link => {
    if (link.getAttribute('href') === currentPath) {
      link.classList.add('active');
    }
  });

  // ---- Crew Filter Dropdown auto-submit ----
  const crewFilter = document.getElementById('crew-flight-filter');
  if (crewFilter) {
    crewFilter.addEventListener('change', function () {
      this.closest('form').submit();
    });
  }

  // ---- Booking: Real-time price display ----
  updateBookingTotal();

});

// ============================================================
// Helper: show a temporary alert banner
// ============================================================
function showAlert(message, type = 'info') {
  const container = document.querySelector('.flash-messages') || createFlashContainer();
  const div = document.createElement('div');
  div.className = `flash-msg flash-${type}`;
  div.innerHTML = `<span>${type === 'error' ? '✖' : 'ℹ'}</span> ${message}`;
  container.appendChild(div);

  setTimeout(() => {
    div.style.opacity = '0';
    setTimeout(() => div.remove(), 500);
  }, 4000);
}

function createFlashContainer() {
  const div = document.createElement('div');
  div.className = 'flash-messages';
  document.querySelector('.navbar').insertAdjacentElement('afterend', div);
  return div;
}

// ============================================================
// Booking: update total price display
// ============================================================
function updateBookingTotal() {
  const priceEl = document.getElementById('flight-price');
  const totalEl = document.getElementById('total-display');
  if (priceEl && totalEl) {
    totalEl.textContent = '₹' + parseFloat(priceEl.dataset.price).toLocaleString('en-IN');
  }
}
