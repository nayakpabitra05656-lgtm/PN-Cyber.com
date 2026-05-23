<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>PN Cyber | Elite Security Operations</title>
  <link href="https://fonts.googleapis.com/css2?family=Share+Tech+Mono&family=Orbitron:wght@400;700;900&family=Rajdhani:wght@300;400;600&display=swap" rel="stylesheet"/>
  <style>
    :root {
      --green: #00ff41;
      --green-dim: #00c832;
      --green-ghost: rgba(0,255,65,0.07);
      --green-glow: rgba(0,255,65,0.4);
      --red: #ff003c;
      --dark: #020b05;
      --darker: #010703;
      --panel: rgba(0,255,65,0.04);
      --border: rgba(0,255,65,0.18);
    }

    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    html { scroll-behavior: smooth; }

    body {
      background: var(--dark);
      color: var(--green);
      font-family: 'Share Tech Mono', monospace;
      overflow-x: hidden;
      cursor: none;
    }

    /* CUSTOM CURSOR */
    #cursor {
      position: fixed;
      width: 20px; height: 20px;
      border: 2px solid var(--green);
      border-radius: 50%;
      pointer-events: none;
      z-index: 9999;
      transform: translate(-50%,-50%);
      transition: width .15s, height .15s, background .15s;
      box-shadow: 0 0 10px var(--green-glow);
    }
    #cursor-dot {
      position: fixed;
      width: 5px; height: 5px;
      background: var(--green);
      border-radius: 50%;
      pointer-events: none;
      z-index: 9999;
      transform: translate(-50%,-50%);
    }
    body:hover #cursor { background: rgba(0,255,65,0.1); width: 28px; height: 28px; }

    /* MATRIX CANVAS */
    #matrix-bg {
      position: fixed;
      top: 0; left: 0;
      width: 100%; height: 100%;
      z-index: 0;
      opacity: 0.13;
    }

    /* SCANLINES */
    body::before {
      content: '';
      position: fixed;
      top: 0; left: 0;
      width: 100%; height: 100%;
      background: repeating-linear-gradient(
        0deg,
        transparent,
        transparent 2px,
        rgba(0,0,0,0.07) 2px,
        rgba(0,0,0,0.07) 4px
      );
      pointer-events: none;
      z-index: 1000;
    }

    /* NAV */
    nav {
      position: fixed;
      top: 0; width: 100%;
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 18px 48px;
      border-bottom: 1px solid var(--border);
      background: rgba(2,11,5,0.92);
      backdrop-filter: blur(10px);
      z-index: 500;
    }
    .nav-logo {
      font-family: 'Orbitron', sans-serif;
      font-weight: 900;
      font-size: 1.4rem;
      letter-spacing: 4px;
      color: var(--green);
      text-shadow: 0 0 20px var(--green-glow), 0 0 40px var(--green-glow);
      animation: flicker 5s infinite;
    }
    .nav-logo span { color: var(--red); text-shadow: 0 0 15px rgba(255,0,60,0.7); }
    .nav-links { display: flex; gap: 36px; }
    .nav-links a {
      color: var(--green-dim);
      text-decoration: none;
      font-size: 0.78rem;
      letter-spacing: 3px;
      text-transform: uppercase;
      transition: color .2s, text-shadow .2s;
    }
    .nav-links a:hover {
      color: var(--green);
      text-shadow: 0 0 10px var(--green-glow);
    }
    .nav-status {
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 0.7rem;
      color: var(--green-dim);
      letter-spacing: 2px;
    }
    .status-dot {
      width: 8px; height: 8px;
      border-radius: 50%;
      background: var(--green);
      animation: pulse 1.5s infinite;
      box-shadow: 0 0 8px var(--green);
    }

    /* HERO */
    .hero {
      position: relative;
      z-index: 10;
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      text-align: center;
      padding: 120px 24px 60px;
    }
    .hero-tag {
      font-size: 0.7rem;
      letter-spacing: 6px;
      color: var(--red);
      margin-bottom: 20px;
      text-transform: uppercase;
      animation: fadeInDown .8s ease both;
    }
    .hero-title {
      font-family: 'Orbitron', sans-serif;
      font-size: clamp(3rem, 10vw, 8rem);
      font-weight: 900;
      line-height: 1;
      letter-spacing: 8px;
      text-shadow:
        0 0 20px var(--green-glow),
        0 0 60px rgba(0,255,65,0.2),
        0 0 100px rgba(0,255,65,0.1);
      animation: fadeInDown 1s ease .2s both, flicker 8s infinite 2s;
    }
    .hero-title .pn { color: var(--green); }
    .hero-title .cyber {
      color: transparent;
      -webkit-text-stroke: 2px var(--green);
      text-shadow: 0 0 30px var(--green-glow);
    }
    .hero-subtitle {
      font-family: 'Rajdhani', sans-serif;
      font-size: clamp(1rem, 3vw, 1.5rem);
      font-weight: 300;
      letter-spacing: 8px;
      color: rgba(0,255,65,0.5);
      margin: 20px 0 40px;
      animation: fadeInDown 1s ease .4s both;
    }
    .hero-typewriter {
      font-size: 1rem;
      color: var(--green);
      letter-spacing: 2px;
      min-height: 1.5em;
      animation: fadeIn 1s ease .6s both;
    }
    .hero-typewriter .cursor-blink { animation: blink .7s infinite; }

    .hero-cta {
      display: flex;
      gap: 20px;
      margin-top: 48px;
      animation: fadeInUp 1s ease .8s both;
      flex-wrap: wrap;
      justify-content: center;
    }
    .btn {
      font-family: 'Share Tech Mono', monospace;
      font-size: 0.78rem;
      letter-spacing: 3px;
      text-transform: uppercase;
      padding: 14px 36px;
      border: 1px solid var(--green);
      background: transparent;
      color: var(--green);
      cursor: none;
      text-decoration: none;
      transition: all .25s;
      position: relative;
      overflow: hidden;
    }
    .btn::before {
      content: '';
      position: absolute;
      top: 0; left: -100%;
      width: 100%; height: 100%;
      background: var(--green);
      transition: left .25s;
      z-index: -1;
    }
    .btn:hover { color: var(--dark); text-shadow: none; }
    .btn:hover::before { left: 0; }
    .btn-ghost {
      border-color: rgba(0,255,65,0.35);
      color: rgba(0,255,65,0.5);
    }
    .btn-ghost:hover { color: var(--dark); }

    /* STATS BAR */
    .stats-bar {
      position: relative;
      z-index: 10;
      display: flex;
      justify-content: center;
      gap: 0;
      border-top: 1px solid var(--border);
      border-bottom: 1px solid var(--border);
      background: var(--panel);
    }
    .stat-item {
      flex: 1;
      max-width: 220px;
      text-align: center;
      padding: 28px 20px;
      border-right: 1px solid var(--border);
    }
    .stat-item:last-child { border-right: none; }
    .stat-num {
      font-family: 'Orbitron', sans-serif;
      font-size: 2rem;
      font-weight: 700;
      color: var(--green);
      text-shadow: 0 0 15px var(--green-glow);
      display: block;
    }
    .stat-label {
      font-size: 0.65rem;
      letter-spacing: 3px;
      color: rgba(0,255,65,0.4);
      text-transform: uppercase;
      display: block;
      margin-top: 4px;
    }

    /* SECTIONS */
    section {
      position: relative;
      z-index: 10;
      padding: 100px 48px;
      max-width: 1200px;
      margin: 0 auto;
    }
    .section-header {
      margin-bottom: 60px;
    }
    .section-tag {
      font-size: 0.65rem;
      letter-spacing: 5px;
      color: var(--red);
      text-transform: uppercase;
      display: block;
      margin-bottom: 10px;
    }
    .section-title {
      font-family: 'Orbitron', sans-serif;
      font-size: clamp(1.5rem, 4vw, 2.5rem);
      font-weight: 700;
      letter-spacing: 4px;
      color: var(--green);
      text-shadow: 0 0 20px var(--green-glow);
    }
    .section-title .line {
      display: inline-block;
      width: 60px; height: 2px;
      background: var(--red);
      vertical-align: middle;
      margin-right: 16px;
      box-shadow: 0 0 8px rgba(255,0,60,0.6);
    }

    /* SERVICES GRID */
    .services-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
      gap: 2px;
      background: var(--border);
    }
    .service-card {
      background: var(--dark);
      padding: 40px 32px;
      border: none;
      position: relative;
      overflow: hidden;
      transition: background .3s;
      cursor: none;
    }
    .service-card::before {
      content: '';
      position: absolute;
      top: 0; left: 0;
      width: 3px; height: 0;
      background: var(--green);
      transition: height .4s;
      box-shadow: 0 0 10px var(--green-glow);
    }
    .service-card:hover::before { height: 100%; }
    .service-card:hover { background: var(--green-ghost); }
    .service-icon {
      font-size: 2.5rem;
      margin-bottom: 20px;
      display: block;
      filter: drop-shadow(0 0 8px var(--green-glow));
    }
    .service-num {
      position: absolute;
      top: 20px; right: 24px;
      font-family: 'Orbitron', sans-serif;
      font-size: 0.7rem;
      color: rgba(0,255,65,0.12);
      font-weight: 700;
      letter-spacing: 2px;
    }
    .service-title {
      font-family: 'Orbitron', sans-serif;
      font-size: 0.9rem;
      font-weight: 700;
      letter-spacing: 3px;
      margin-bottom: 14px;
      color: var(--green);
    }
    .service-desc {
      font-family: 'Rajdhani', sans-serif;
      font-size: 0.95rem;
      color: rgba(0,255,65,0.55);
      line-height: 1.7;
      letter-spacing: 0.5px;
    }

    /* TERMINAL */
    .terminal {
      background: var(--darker);
      border: 1px solid var(--border);
      border-radius: 0;
      overflow: hidden;
      box-shadow: 0 0 40px rgba(0,255,65,0.08), inset 0 0 40px rgba(0,0,0,0.5);
    }
    .terminal-bar {
      background: rgba(0,255,65,0.05);
      border-bottom: 1px solid var(--border);
      padding: 12px 20px;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .t-dot { width: 10px; height: 10px; border-radius: 50%; }
    .t-dot-r { background: var(--red); box-shadow: 0 0 6px rgba(255,0,60,0.5); }
    .t-dot-y { background: #ffb300; box-shadow: 0 0 6px rgba(255,179,0,0.5); }
    .t-dot-g { background: var(--green); box-shadow: 0 0 6px var(--green-glow); }
    .t-title { margin-left: 12px; font-size: 0.7rem; letter-spacing: 3px; color: rgba(0,255,65,0.4); }
    .terminal-body {
      padding: 28px 32px;
      min-height: 320px;
      font-size: 0.88rem;
      line-height: 2;
    }
    .t-line { display: flex; gap: 10px; align-items: baseline; }
    .t-prompt { color: var(--red); flex-shrink: 0; }
    .t-cmd { color: var(--green); }
    .t-output { color: rgba(0,255,65,0.55); padding-left: 20px; }
    .t-success { color: var(--green); padding-left: 20px; }
    .t-warn { color: #ffb300; padding-left: 20px; }
    .t-live::after {
      content: '█';
      animation: blink .7s infinite;
      color: var(--green);
    }

    /* ABOUT SPLIT */
    .about-split {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 60px;
      align-items: center;
    }
    .about-text p {
      font-family: 'Rajdhani', sans-serif;
      font-size: 1.05rem;
      line-height: 1.9;
      color: rgba(0,255,65,0.6);
      margin-bottom: 20px;
      letter-spacing: 0.5px;
    }
    .about-text p strong { color: var(--green); font-family: 'Share Tech Mono', monospace; font-size: 0.9rem; }
    .skill-bars { display: flex; flex-direction: column; gap: 20px; }
    .skill-bar-item {}
    .skill-bar-label {
      display: flex;
      justify-content: space-between;
      font-size: 0.72rem;
      letter-spacing: 3px;
      color: rgba(0,255,65,0.5);
      margin-bottom: 8px;
    }
    .skill-bar-track {
      height: 3px;
      background: rgba(0,255,65,0.1);
      position: relative;
    }
    .skill-bar-fill {
      position: absolute;
      top: 0; left: 0;
      height: 100%;
      background: var(--green);
      box-shadow: 0 0 8px var(--green-glow);
      animation: fillBar 2s ease forwards;
    }

    /* CONTACT */
    .contact-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 60px;
    }
    .contact-info {}
    .contact-item {
      display: flex;
      gap: 20px;
      align-items: flex-start;
      padding: 20px 0;
      border-bottom: 1px solid var(--border);
    }
    .contact-item-icon { font-size: 1.3rem; margin-top: 2px; }
    .contact-item-label {
      font-size: 0.65rem;
      letter-spacing: 3px;
      color: rgba(0,255,65,0.35);
      text-transform: uppercase;
      display: block;
      margin-bottom: 4px;
    }
    .contact-item-value {
      font-family: 'Rajdhani', sans-serif;
      font-size: 1rem;
      color: var(--green);
      letter-spacing: 1px;
    }
    .contact-form { display: flex; flex-direction: column; gap: 16px; }
    .form-input {
      background: var(--panel);
      border: 1px solid var(--border);
      color: var(--green);
      font-family: 'Share Tech Mono', monospace;
      font-size: 0.82rem;
      padding: 14px 18px;
      letter-spacing: 1px;
      outline: none;
      transition: border .2s, box-shadow .2s;
      resize: none;
      cursor: none;
    }
    .form-input::placeholder { color: rgba(0,255,65,0.2); }
    .form-input:focus {
      border-color: var(--green);
      box-shadow: 0 0 12px rgba(0,255,65,0.1);
    }

    /* FOOTER */
    footer {
      position: relative;
      z-index: 10;
      border-top: 1px solid var(--border);
      padding: 48px;
      text-align: center;
      background: var(--panel);
    }
    .footer-logo {
      font-family: 'Orbitron', sans-serif;
      font-weight: 900;
      font-size: 1.5rem;
      letter-spacing: 6px;
      color: var(--green);
      text-shadow: 0 0 20px var(--green-glow);
      margin-bottom: 16px;
    }
    .footer-logo span { color: var(--red); }
    .footer-sub {
      font-size: 0.65rem;
      letter-spacing: 4px;
      color: rgba(0,255,65,0.25);
      text-transform: uppercase;
      margin-bottom: 32px;
    }
    .footer-links {
      display: flex;
      justify-content: center;
      gap: 32px;
      margin-bottom: 32px;
    }
    .footer-links a {
      font-size: 0.7rem;
      letter-spacing: 3px;
      color: rgba(0,255,65,0.3);
      text-decoration: none;
      text-transform: uppercase;
      transition: color .2s;
    }
    .footer-links a:hover { color: var(--green); }
    .footer-copy {
      font-size: 0.65rem;
      color: rgba(0,255,65,0.15);
      letter-spacing: 2px;
    }

    /* GLITCH EFFECT */
    .glitch {
      position: relative;
    }
    .glitch::before, .glitch::after {
      content: attr(data-text);
      position: absolute;
      top: 0; left: 0;
      width: 100%; height: 100%;
    }
    .glitch::before {
      left: 2px;
      text-shadow: -2px 0 var(--red);
      clip: rect(24px, 550px, 90px, 0);
      animation: glitch1 3s infinite linear alternate-reverse;
    }
    .glitch::after {
      left: -2px;
      text-shadow: -2px 0 #0ff;
      clip: rect(85px, 550px, 140px, 0);
      animation: glitch2 2.5s infinite linear alternate-reverse;
    }

    /* DIVIDER */
    .hex-divider {
      text-align: center;
      padding: 20px 0;
      font-size: 0.65rem;
      letter-spacing: 4px;
      color: rgba(0,255,65,0.15);
      position: relative;
      z-index: 10;
    }

    /* ANIMATIONS */
    @keyframes flicker {
      0%, 95%, 100% { opacity: 1; }
      96% { opacity: 0.85; }
      97% { opacity: 1; }
      98% { opacity: 0.6; }
      99% { opacity: 1; }
    }
    @keyframes pulse {
      0%, 100% { opacity: 1; transform: scale(1); }
      50% { opacity: 0.4; transform: scale(0.7); }
    }
    @keyframes blink {
      0%, 100% { opacity: 1; }
      50% { opacity: 0; }
    }
    @keyframes fadeInDown {
      from { opacity: 0; transform: translateY(-30px); }
      to { opacity: 1; transform: translateY(0); }
    }
    @keyframes fadeInUp {
      from { opacity: 0; transform: translateY(30px); }
      to { opacity: 1; transform: translateY(0); }
    }
    @keyframes fadeIn {
      from { opacity: 0; }
      to { opacity: 1; }
    }
    @keyframes fillBar {
      from { width: 0; }
    }
    @keyframes glitch1 {
      0% { clip: rect(20px, 9999px, 30px, 0); transform: skew(0.3deg); }
      20% { clip: rect(70px, 9999px, 80px, 0); transform: skew(-0.1deg); }
      40% { clip: rect(10px, 9999px, 50px, 0); transform: skew(0.5deg); }
      60% { clip: rect(100px, 9999px, 120px, 0); transform: skew(0deg); }
      80% { clip: rect(40px, 9999px, 60px, 0); transform: skew(-0.3deg); }
      100% { clip: rect(5px, 9999px, 25px, 0); transform: skew(0.2deg); }
    }
    @keyframes glitch2 {
      0% { clip: rect(60px, 9999px, 90px, 0); transform: skew(-0.4deg); }
      30% { clip: rect(30px, 9999px, 55px, 0); transform: skew(0.2deg); }
      60% { clip: rect(80px, 9999px, 100px, 0); transform: skew(-0.2deg); }
      100% { clip: rect(15px, 9999px, 40px, 0); transform: skew(0.4deg); }
    }
    @keyframes scan {
      0% { top: -100%; }
      100% { top: 100%; }
    }

    /* SCAN LINE EFFECT */
    .hero::after {
      content: '';
      position: absolute;
      left: 0;
      top: -100%;
      width: 100%;
      height: 2px;
      background: linear-gradient(transparent, var(--green), transparent);
      opacity: 0.3;
      animation: scan 6s linear infinite;
      pointer-events: none;
    }

    @media (max-width: 768px) {
      nav { padding: 14px 20px; }
      .nav-links { display: none; }
      section { padding: 60px 20px; }
      .about-split, .contact-grid { grid-template-columns: 1fr; gap: 40px; }
      footer { padding: 32px 20px; }
      .stats-bar { flex-wrap: wrap; }
      .stat-item { flex: none; width: 50%; border-right: 1px solid var(--border); border-bottom: 1px solid var(--border); }
    }
  </style>
</head>
<body>

  <!-- CURSOR -->
  <div id="cursor"></div>
  <div id="cursor-dot"></div>

  <!-- MATRIX BACKGROUND -->
  <canvas id="matrix-bg"></canvas>

  <!-- NAV -->
  <nav>
    <div class="nav-logo"><span>PN</span> CYBER</div>
    <div class="nav-links">
      <a href="#services">Services</a>
      <a href="#about">About</a>
      <a href="#terminal">Operations</a>
      <a href="#contact">Contact</a>
    </div>
    <div class="nav-status">
      <div class="status-dot"></div>
      SYSTEMS ONLINE
    </div>
  </nav>

  <!-- HERO -->
  <section class="hero" id="home">
    <p class="hero-tag">// elite cybersecurity operations //</p>
    <h1 class="hero-title glitch" data-text="PN CYBER">
      <span class="pn">PN</span> <span class="cyber">CYBER</span>
    </h1>
    <p class="hero-subtitle">PENETRATE &nbsp;·&nbsp; NEUTRALIZE &nbsp;·&nbsp; PROTECT</p>
    <div class="hero-typewriter" id="typewriter"><span class="cursor-blink">█</span></div>
    <div class="hero-cta">
      <a href="#services" class="btn">[ INITIATE ]</a>
      <a href="#contact" class="btn btn-ghost">[ CONTACT ]</a>
    </div>
  </section>

  <!-- STATS -->
  <div class="stats-bar">
    <div class="stat-item">
      <span class="stat-num" id="cnt1">0</span>
      <span class="stat-label">Vulnerabilities Found</span>
    </div>
    <div class="stat-item">
      <span class="stat-num" id="cnt2">0</span>
      <span class="stat-label">Systems Secured</span>
    </div>
    <div class="stat-item">
      <span class="stat-num" id="cnt3">0</span>
      <span class="stat-label">Clients Protected</span>
    </div>
    <div class="stat-item">
      <span class="stat-num" id="cnt4">0</span>
      <span class="stat-label">Zero-Day Exploits</span>
    </div>
    <div class="stat-item">
      <span class="stat-num" id="cnt5">0</span>
      <span class="stat-label">Uptime %</span>
    </div>
  </div>

  <div class="hex-divider">
    ◈ ────────── 0x504E435942455220 ────────── ◈
  </div>

  <!-- SERVICES -->
  <section id="services">
    <div class="section-header">
      <span class="section-tag">// module_02 :: services</span>
      <h2 class="section-title"><span class="line"></span>OPERATIONS</h2>
    </div>
    <div class="services-grid">
      <div class="service-card">
        <span class="service-num">01</span>
        <span class="service-icon">🔍</span>
        <h3 class="service-title">RECON & OSINT</h3>
        <p class="service-desc">Deep reconnaissance and open-source intelligence gathering. We map your entire attack surface before adversaries do.</p>
      </div>
      <div class="service-card">
        <span class="service-num">02</span>
        <span class="service-icon">💀</span>
        <h3 class="service-title">PENETRATION TESTING</h3>
        <p class="service-desc">Full-scope offensive security assessments. Web apps, internal networks, APIs, social engineering — no scope is too deep.</p>
      </div>
      <div class="service-card">
        <span class="service-num">03</span>
        <span class="service-icon">🛡️</span>
        <h3 class="service-title">THREAT DEFENSE</h3>
        <p class="service-desc">Incident response, SOC operations, and proactive threat hunting. We identify intrusions before they become breaches.</p>
      </div>
      <div class="service-card">
        <span class="service-num">04</span>
        <span class="service-icon">🔐</span>
        <h3 class="service-title">EXPLOIT RESEARCH</h3>
        <p class="service-desc">Zero-day discovery, CVE analysis, and custom exploit development for authorized red team engagements.</p>
      </div>
      <div class="service-card">
        <span class="service-num">05</span>
        <span class="service-icon">🌐</span>
        <h3 class="service-title">DARK WEB MONITORING</h3>
        <p class="service-desc">Continuous monitoring of dark web markets and threat forums for leaked credentials, data, and attack planning.</p>
      </div>
      <div class="service-card">
        <span class="service-num">06</span>
        <span class="service-icon">⚡</span>
        <h3 class="service-title">MALWARE ANALYSIS</h3>
        <p class="service-desc">Static and dynamic reverse engineering of malicious code. Behavioral profiling and IoC extraction for threat intelligence.</p>
      </div>
    </div>
  </section>

  <div class="hex-divider">◈ ────────── ACCESS::LEVEL::ROOT ────────── ◈</div>

  <!-- TERMINAL -->
  <section id="terminal" style="padding-top:40px;">
    <div class="section-header">
      <span class="section-tag">// module_03 :: live feed</span>
      <h2 class="section-title"><span class="line"></span>OPERATIONS LOG</h2>
    </div>
    <div class="terminal">
      <div class="terminal-bar">
        <div class="t-dot t-dot-r"></div>
        <div class="t-dot t-dot-y"></div>
        <div class="t-dot t-dot-g"></div>
        <span class="t-title">root@pncyber:~#</span>
      </div>
      <div class="terminal-body" id="terminal-body">
      </div>
    </div>
  </section>

  <!-- ABOUT -->
  <section id="about">
    <div class="section-header">
      <span class="section-tag">// module_04 :: about</span>
      <h2 class="section-title"><span class="line"></span>WHO WE ARE</h2>
    </div>
    <div class="about-split">
      <div class="about-text">
        <p>
          <strong>PN CYBER</strong> is an elite offensive security unit operating in the grey zones of digital warfare. Founded by anonymous security researchers, we specialize in turning adversarial tactics into defensive weapons.
        </p>
        <p>
          We don't follow conventional security playbooks. We think like attackers — because we <strong>are</strong> attackers. Every engagement is a real-world scenario; every report is a roadmap to resilience.
        </p>
        <p>
          Our operators hold <strong>OSCP, CEH, GPEN, CRTO</strong> and numerous other certifications, combined with years of underground research experience.
        </p>
        <a href="#contact" class="btn" style="margin-top:12px; display:inline-block;">[ REQUEST BRIEFING ]</a>
      </div>
      <div class="skill-bars">
        <div class="skill-bar-item">
          <div class="skill-bar-label"><span>NETWORK EXPLOITATION</span><span>97%</span></div>
          <div class="skill-bar-track"><div class="skill-bar-fill" style="width:97%"></div></div>
        </div>
        <div class="skill-bar-item">
          <div class="skill-bar-label"><span>WEB APP HACKING</span><span>95%</span></div>
          <div class="skill-bar-track"><div class="skill-bar-fill" style="width:95%"></div></div>
        </div>
        <div class="skill-bar-item">
          <div class="skill-bar-label"><span>REVERSE ENGINEERING</span><span>90%</span></div>
          <div class="skill-bar-track"><div class="skill-bar-fill" style="width:90%"></div></div>
        </div>
        <div class="skill-bar-item">
          <div class="skill-bar-label"><span>SOCIAL ENGINEERING</span><span>93%</span></div>
          <div class="skill-bar-track"><div class="skill-bar-fill" style="width:93%"></div></div>
        </div>
        <div class="skill-bar-item">
          <div class="skill-bar-label"><span>CRYPTOGRAPHY</span><span>88%</span></div>
          <div class="skill-bar-track"><div class="skill-bar-fill" style="width:88%"></div></div>
        </div>
        <div class="skill-bar-item">
          <div class="skill-bar-label"><span>MALWARE DEVELOPMENT</span><span>92%</span></div>
          <div class="skill-bar-track"><div class="skill-bar-fill" style="width:92%"></div></div>
        </div>
      </div>
    </div>
  </section>

  <div class="hex-divider">◈ ────────── ENCRYPT::TRANSMIT::DELIVER ────────── ◈</div>

  <!-- CONTACT -->
  <section id="contact">
    <div class="section-header">
      <span class="section-tag">// module_05 :: contact</span>
      <h2 class="section-title"><span class="line"></span>ESTABLISH LINK</h2>
    </div>
    <div class="contact-grid">
      <div class="contact-info">
        <div class="contact-item">
          <span class="contact-item-icon">📡</span>
          <div>
            <span class="contact-item-label">Secure Channel</span>
            <span class="contact-item-value">ops@pncyber.onion</span>
          </div>
        </div>
        <div class="contact-item">
          <span class="contact-item-icon">🔒</span>
          <div>
            <span class="contact-item-label">PGP Key</span>
            <span class="contact-item-value">0xA3F7B2C9D01E4F58</span>
          </div>
        </div>
        <div class="contact-item">
          <span class="contact-item-icon">📍</span>
          <div>
            <span class="contact-item-label">Location</span>
            <span class="contact-item-value">CLASSIFIED // GLOBAL OPS</span>
          </div>
        </div>
        <div class="contact-item">
          <span class="contact-item-icon">⏱️</span>
          <div>
            <span class="contact-item-label">Response Time</span>
            <span class="contact-item-value">&lt; 24H // ENCRYPTED ONLY</span>
          </div>
        </div>
        <div class="contact-item">
          <span class="contact-item-icon">💬</span>
          <div>
            <span class="contact-item-label">Signal / Session</span>
            <span class="contact-item-value">@pncyber_sec</span>
          </div>
        </div>
      </div>
      <div class="contact-form">
        <input type="text" class="form-input" placeholder="// HANDLE / ALIAS" />
        <input type="text" class="form-input" placeholder="// ENCRYPTED EMAIL" />
        <select class="form-input" style="appearance:none;">
          <option value="" disabled selected>// SELECT OPERATION TYPE</option>
          <option>PENETRATION TEST</option>
          <option>RED TEAM ENGAGEMENT</option>
          <option>INCIDENT RESPONSE</option>
          <option>OSINT INVESTIGATION</option>
          <option>VULNERABILITY AUDIT</option>
          <option>OTHER // CLASSIFIED</option>
        </select>
        <textarea class="form-input" rows="5" placeholder="// DESCRIBE OBJECTIVE :: USE ENCRYPTED CHANNEL FOR SENSITIVE INFO"></textarea>
        <button class="btn" style="width:100%; border:1px solid var(--green); font-size:0.8rem;">[ TRANSMIT MESSAGE ]</button>
      </div>
    </div>
  </section>

  <!-- FOOTER -->
  <footer>
    <div class="footer-logo"><span>PN</span>CYBER</div>
    <div class="footer-sub">// Penetrate. Neutralize. Protect. //</div>
    <div class="footer-links">
      <a href="#">Privacy</a>
      <a href="#">Disclosure Policy</a>
      <a href="#">Hall of Fame</a>
      <a href="#">PGP Key</a>
    </div>
    <div class="footer-copy">
      © 2026 PN CYBER — ALL OPERATIONS AUTHORIZED — UNAUTHORIZED ACCESS IS ILLEGAL
    </div>
  </footer>

  <script>
    // CUSTOM CURSOR
    const cur = document.getElementById('cursor');
    const dot = document.getElementById('cursor-dot');
    document.addEventListener('mousemove', e => {
      cur.style.left = e.clientX + 'px';
      cur.style.top = e.clientY + 'px';
      dot.style.left = e.clientX + 'px';
      dot.style.top = e.clientY + 'px';
    });

    // MATRIX RAIN
    const canvas = document.getElementById('matrix-bg');
    const ctx = canvas.getContext('2d');
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
    window.addEventListener('resize', () => {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
    });
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*()_+-=[]{}|;:<>?/\\PN漢字'.split('');
    const fontSize = 13;
    const cols = Math.floor(canvas.width / fontSize);
    const drops = Array(cols).fill(1);
    function drawMatrix() {
      ctx.fillStyle = 'rgba(2,11,5,0.06)';
      ctx.fillRect(0, 0, canvas.width, canvas.height);
      ctx.fillStyle = '#00ff41';
      ctx.font = fontSize + 'px Share Tech Mono';
      drops.forEach((y, i) => {
        const c = chars[Math.floor(Math.random() * chars.length)];
        ctx.fillText(c, i * fontSize, y * fontSize);
        if (y * fontSize > canvas.height && Math.random() > 0.975) drops[i] = 0;
        drops[i]++;
      });
    }
    setInterval(drawMatrix, 45);

    // TYPEWRITER
    const phrases = [
      'root@pncyber:~# ./scan --target all --mode aggressive',
      'Initializing exploit framework...',
      'BREACH DETECTED // Response protocol active',
      '> Access granted. Welcome to the shadows.',
      'PN CYBER — We find what you cannot hide.',
    ];
    let pi = 0, ci = 0, deleting = false;
    const tw = document.getElementById('typewriter');
    function type() {
      const phrase = phrases[pi];
      if (!deleting) {
        tw.innerHTML = phrase.slice(0, ci++) + '<span class="cursor-blink">█</span>';
        if (ci > phrase.length) { deleting = true; setTimeout(type, 2000); return; }
      } else {
        tw.innerHTML = phrase.slice(0, ci--) + '<span class="cursor-blink">█</span>';
        if (ci < 0) { deleting = false; pi = (pi + 1) % phrases.length; ci = 0; }
      }
      setTimeout(type, deleting ? 35 : 75);
    }
    type();

    // COUNTER ANIMATION
    function animateCounter(id, target, suffix = '', duration = 2000) {
      const el = document.getElementById(id);
      let start = null;
      function step(ts) {
        if (!start) start = ts;
        const progress = Math.min((ts - start) / duration, 1);
        const eased = 1 - Math.pow(1 - progress, 3);
        el.textContent = Math.floor(eased * target) + suffix;
        if (progress < 1) requestAnimationFrame(step);
      }
      requestAnimationFrame(step);
    }
    const statsObs = new IntersectionObserver(entries => {
      if (entries[0].isIntersecting) {
        animateCounter('cnt1', 4729, '+');
        animateCounter('cnt2', 312);
        animateCounter('cnt3', 187);
        animateCounter('cnt4', 63);
        animateCounter('cnt5', 99, '%');
        statsObs.disconnect();
      }
    });
    statsObs.observe(document.querySelector('.stats-bar'));

    // LIVE TERMINAL
    const termLines = [
      { type: 'cmd', prompt: 'root@pncyber:~#', cmd: 'nmap -sV -p- 192.168.1.0/24' },
      { type: 'output', text: 'Starting Nmap 7.95 ( https://nmap.org )' },
      { type: 'output', text: 'Scanning 256 hosts [65535 ports/host]' },
      { type: 'success', text: '[+] Open: 192.168.1.12:22  (OpenSSH 7.4)' },
      { type: 'success', text: '[+] Open: 192.168.1.12:80  (Apache httpd 2.4.6)' },
      { type: 'warn',   text: '[!] CVE-2021-41773: Path Traversal — CRITICAL' },
      { type: 'cmd', prompt: 'root@pncyber:~#', cmd: 'python3 exploit.py --target 192.168.1.12' },
      { type: 'output', text: 'Sending payload...' },
      { type: 'success', text: '[+] Shell obtained — uid=0(root)' },
      { type: 'cmd', prompt: 'root@pncyber:~#', cmd: 'cat /etc/shadow | hashcat -m 1800' },
      { type: 'success', text: '[+] Hashes cracked: admin:pncyber_r00t' },
      { type: 'warn',   text: '[!] Report generated: /reports/engagement_2026.pdf' },
      { type: 'cmd', prompt: 'root@pncyber:~#', cmd: '' },
    ];
    const tb = document.getElementById('terminal-body');
    let tIdx = 0;
    function printTermLine() {
      if (tIdx >= termLines.length) { tIdx = 0; tb.innerHTML = ''; }
      const l = termLines[tIdx++];
      const div = document.createElement('div');
      div.className = 't-line';
      if (l.type === 'cmd') {
        div.innerHTML = `<span class="t-prompt">${l.prompt}</span><span class="t-cmd">${l.cmd}</span>`;
      } else if (l.type === 'output') {
        div.innerHTML = `<span class="t-output">${l.text}</span>`;
      } else if (l.type === 'success') {
        div.innerHTML = `<span class="t-success">${l.text}</span>`;
      } else if (l.type === 'warn') {
        div.innerHTML = `<span class="t-warn">${l.text}</span>`;
      }
      tb.appendChild(div);
      tb.scrollTop = tb.scrollHeight;
      setTimeout(printTermLine, 600 + Math.random() * 500);
    }
    const termObs = new IntersectionObserver(entries => {
      if (entries[0].isIntersecting) { printTermLine(); termObs.disconnect(); }
    });
    termObs.observe(document.getElementById('terminal'));

    // SMOOTH SCROLL
    document.querySelectorAll('a[href^="#"]').forEach(a => {
      a.addEventListener('click', e => {
        e.preventDefault();
        const t = document.querySelector(a.getAttribute('href'));
        if (t) t.scrollIntoView({ behavior: 'smooth' });
      });
    });

    // FORM BUTTON EFFECT
    document.querySelector('.contact-form .btn').addEventListener('click', function() {
      this.textContent = '[ TRANSMITTING... ]';
      setTimeout(() => { this.textContent = '[ MESSAGE SENT // ENCRYPTED ]'; }, 1500);
      setTimeout(() => { this.textContent = '[ TRANSMIT MESSAGE ]'; }, 4000);
    });
  </script>
</body>
</html>
