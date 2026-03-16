// ============================================================
// header.js — EventSpark Shared Navigation
// Include on every page with:  <script src="header.js"></script>
// Make sure your page has:     <div id="main-nav"></div>
// ============================================================

(async function () {

  // ── 1. Inject nav HTML ──────────────────────────────────────
  const navHTML = `
  <nav id="eventspark-nav">
    <div class="logo">
      <img src="logo.jpg" alt="EventSpark Logo">
      <span>EventSpark</span>
    </div>
    <div class="nav-links">
      <a href="home.html">Home</a>
      <a href="event.html">Events</a>
      <a href="about_us.html">About Us</a>
     
      <span id="nav-auth"></span>
    </div>
  </nav>`;

  // Insert nav at the very top of <body>
  document.body.insertAdjacentHTML('afterbegin', navHTML);

  // ── 2. Inject shared nav CSS ────────────────────────────────
  const style = document.createElement('style');
  style.textContent = `
    #eventspark-nav {
      background-color: white;
      padding: 1rem 2rem;
      position: fixed;
      top: 0; left: 0;
      width: 100%;
      z-index: 1000;
      display: flex;
      justify-content: space-between;
      align-items: center;
      box-shadow: 0 2px 8px rgba(0,0,0,0.07);
      box-sizing: border-box;
    }

    #eventspark-nav .logo {
      display: flex;
      align-items: center;
    }

    #eventspark-nav .logo img {
      height: 70px;
      margin-right: 10px;
    }

    #eventspark-nav .logo span {
      font-size: 3.0rem;
      font-weight: bold;
      color: #1a365d;
      font-family: News706 BT, serif;
      white-space: nowrap;
    }

    #eventspark-nav .nav-links {
      display: flex;
      gap: 1.5rem;
      align-items: center;
    }

    #eventspark-nav .nav-links a {
      text-decoration: none;
      color: #4a5568;
      font-weight: 500;
      font-family: Arial, sans-serif;
      transition: color 0.3s;
      white-space: nowrap;
    }

    #eventspark-nav .nav-links a:hover {
      color: #2b6cb0;
    }

    /* Highlight active page link */
    #eventspark-nav .nav-links a.nav-active {
      color: #1a365d;
      font-weight: 700;
    }

    /* Auth buttons */
    #eventspark-nav .nav-login-btn {
      padding: 0.45rem 1rem;
      border-radius: 0.5rem;
      font-weight: 600;
      background: #B8E2F4;
      color: #1a365d;
      text-decoration: none;
      font-family: Arial, sans-serif;
      transition: background 0.3s, color 0.3s;
      white-space: nowrap;
    }
    #eventspark-nav .nav-login-btn:hover {
      background: #2c5282;
      color: white;
    }

    #eventspark-nav .nav-signup-btn {
      padding: 0.45rem 1rem;
      border-radius: 0.5rem;
      font-weight: 600;
      background: #B7E892;
      color: #1a365d;
      text-decoration: none;
      font-family: Arial, sans-serif;
      transition: background 0.3s, color 0.3s;
      white-space: nowrap;
    }
    #eventspark-nav .nav-signup-btn:hover {
      background: #2f855a;
      color: white;
    }

    #eventspark-nav .nav-logout-btn {
      padding: 0.45rem 1rem;
      border-radius: 0.5rem;
      font-weight: 600;
      background: #f7f5ff;
      color: #c53030;
      border: 1.5px solid #fed7d7;
      text-decoration: none;
      font-family: Arial, sans-serif;
      transition: all 0.25s;
      white-space: nowrap;
    }
    #eventspark-nav .nav-logout-btn:hover {
      background: #c53030;
      color: white;
      border-color: #c53030;
    }

    #eventspark-nav .nav-user-badge {
      font-size: 0.88rem;
      font-weight: 600;
      background:#1a365d;
      color: #1a365d;
      font-family: Cambria Math, serif;
      white-space: nowrap;
    }

    /* Mobile */
    @media (max-width: 768px) {
      #eventspark-nav .nav-links {
        display: none;
      }
    }
  `;
  document.head.appendChild(style);

  // ── 3. Highlight active page ────────────────────────────────
  const currentPage = window.location.pathname.split('/').pop() || 'home.html';
  document.querySelectorAll('#eventspark-nav .nav-links a').forEach(link => {
    const href = link.getAttribute('href');
    if (href === currentPage) link.classList.add('nav-active');
  });

  // ── 4. Fetch session and render auth buttons ────────────────
  try {
    const res  = await fetch('/session-info');
    const data = await res.json();
    const area = document.getElementById('nav-auth');

    if (data.loggedIn) {
      const dashLink = data.user.role === 'manager'
        ? `<a href="manager_dashboard.html" class="nav-links-inner">Dashboard</a>`
        : `<a href="my-bookings-page.html" class="nav-links-inner">My Bookings</a>`;

      area.innerHTML = `

        ${dashLink}
        <a href="/logout" class="nav-logout-btn">Logout</a>`;
    } else {
      area.innerHTML = `
        <a href="select_role.html" class="nav-signup-btn">Sign up</a>
        <a href="finallogin.html"  class="nav-login-btn">Login</a>`;
    }
  } catch (e) {
    // Server not reachable — show default
    const area = document.getElementById('nav-auth');
    if (area) {
      area.innerHTML = `
        <a href="select_role.html" class="nav-signup-btn">Sign up</a>
        <a href="finallogin.html"  class="nav-login-btn">Login</a>`;
    }
  }

})();
