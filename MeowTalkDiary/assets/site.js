(function () {
  const app = window.PET_PAW_SITE;

  if (!app) {
    return;
  }

  const body = document.body;
  const page = body.dataset.page;
  const pathDepth = page === "home" ? "." : "..";
  const pagePaths = {
    home: `${pathDepth}/index.html`,
    privacy: `${pathDepth}/privacy/`,
    terms: `${pathDepth}/terms/`,
    support: `${pathDepth}/support/`
  };

  function normalizeLanguage(code) {
    if (app.translations[code]) {
      return code;
    }

    if (!code) {
      return "en";
    }

    const lower = code.toLowerCase();

    if (lower.startsWith("zh-cn") || lower.startsWith("zh-hans") || lower === "zh") {
      return "zh-Hans";
    }
    if (lower.startsWith("zh-tw") || lower.startsWith("zh-hk") || lower.startsWith("zh-hant")) {
      return "zh-Hant";
    }
    if (lower.startsWith("ja")) {
      return "ja";
    }
    if (lower.startsWith("ko")) {
      return "ko";
    }
    if (lower.startsWith("en")) {
      return "en";
    }

    return "en";
  }

  function getLanguage() {
    const params = new URLSearchParams(window.location.search);
    const queryLang = normalizeLanguage(params.get("lang"));
    if (params.get("lang") && app.translations[queryLang]) {
      localStorage.setItem("petpaw-lang", queryLang);
      return queryLang;
    }

    const savedLang = normalizeLanguage(localStorage.getItem("petpaw-lang"));
    if (app.translations[savedLang]) {
      return savedLang;
    }

    return normalizeLanguage(navigator.language || navigator.userLanguage);
  }

  function pageLink(target, lang) {
    const url = new URL(pagePaths[target], window.location.href);
    url.searchParams.set("lang", lang);
    return url.pathname + url.search;
  }

  function el(tag, className, text) {
    const node = document.createElement(tag);
    if (className) {
      node.className = className;
    }
    if (typeof text === "string") {
      node.textContent = text;
    }
    return node;
  }

  function renderNavigation(t) {
    const nav = document.querySelector("[data-nav]");
    nav.innerHTML = "";

    const items = [
      { key: "home", label: t.common.navHome },
      { key: "privacy", label: t.common.navPrivacy },
      { key: "terms", label: t.common.navTerms },
      { key: "support", label: t.common.navSupport }
    ];

    items.forEach((item) => {
      const link = el("a", page === item.key ? "is-active" : "", item.label);
      link.href = pageLink(item.key, currentLanguage);
      nav.appendChild(link);
    });
  }

  function renderLanguageSwitch() {
    const wrap = document.querySelector("[data-language-switch]");
    wrap.innerHTML = "";

    app.languages.forEach((language) => {
      const button = el("button", language.code === currentLanguage ? "is-active" : "", language.label);
      button.type = "button";
      button.addEventListener("click", () => {
        localStorage.setItem("petpaw-lang", language.code);
        window.location.href = pageLink(page, language.code);
      });
      wrap.appendChild(button);
    });
  }

  function renderFooter(t) {
    const footer = document.querySelector("[data-footer]");
    footer.innerHTML = "";
    const card = el("div", "footer-card");
    const left = el("div");
    left.appendChild(el("div", "", t.common.footer));
    left.appendChild(el("div", "muted", t.common.updated));
    const right = el("div", "muted", t.common.footerNote);
    card.appendChild(left);
    card.appendChild(right);
    footer.appendChild(card);
  }

  function appendParagraphs(parent, paragraphs) {
    paragraphs.forEach((text) => {
      parent.appendChild(el("p", "", text));
    });
  }

  function appendBullets(parent, bullets) {
    const list = document.createElement("ul");
    bullets.forEach((text) => {
      const item = document.createElement("li");
      item.textContent = text;
      list.appendChild(item);
    });
    parent.appendChild(list);
  }

  function buildHome(t) {
    const main = document.querySelector("[data-page-content]");
    main.innerHTML = "";

    const hero = el("section", "hero");
    const left = el("div");
    left.appendChild(el("span", "eyebrow", t.home.eyebrow));
    left.appendChild(el("h1", "", t.home.title));
    left.appendChild(el("p", "lead", t.home.lead));

    const actions = el("div", "hero-actions");
    const support = el("a", "button is-primary", t.home.primary);
    support.href = pageLink("support", currentLanguage);
    const privacy = el("a", "button", t.home.secondary);
    privacy.href = pageLink("privacy", currentLanguage);
    actions.appendChild(support);
    actions.appendChild(privacy);
    left.appendChild(actions);

    const right = el("div", "hero-panel");
    const stats = el("div", "stats-list");
    stats.innerHTML = t.home.stats.map((stat) => `
      <div class="feature-card">
        <h2>${stat.title}</h2>
        <p>${stat.body}</p>
      </div>
    `).join("");
    right.appendChild(stats);
    hero.appendChild(left);
    hero.appendChild(right);
    main.appendChild(hero);

    const featuresSection = el("section", "section-stack");
    featuresSection.style.marginTop = "24px";
    featuresSection.appendChild(el("h2", "", t.home.featuresTitle));
    const featureGrid = el("div", "feature-grid");
    featureGrid.innerHTML = t.home.features.map((feature) => `
      <article class="feature-card">
        <h2>${feature.title}</h2>
        <p>${feature.body}</p>
      </article>
    `).join("");
    featuresSection.appendChild(featureGrid);
    main.appendChild(featuresSection);

    const docsSection = el("section", "section-stack");
    docsSection.style.marginTop = "24px";
    docsSection.appendChild(el("h2", "", t.home.docsTitle));
    const docGrid = el("div", "doc-grid");
    const docTargets = ["privacy", "terms", "support"];
    docGrid.innerHTML = t.home.docs.map((doc, index) => `
      <a class="feature-card" href="${pageLink(docTargets[index], currentLanguage)}">
        <h2>${doc.title}</h2>
        <p>${doc.body}</p>
      </a>
    `).join("");
    docsSection.appendChild(docGrid);
    main.appendChild(docsSection);

    const trust = el("section", "notice-card");
    trust.style.marginTop = "24px";
    trust.appendChild(el("h2", "", t.home.trustTitle));
    trust.appendChild(el("p", "", t.home.trustBody));
    main.appendChild(trust);
  }

  function buildDocument(t, entry) {
    const main = document.querySelector("[data-page-content]");
    main.innerHTML = "";

    const pageCard = el("article", "page-card");
    pageCard.appendChild(el("span", "eyebrow", t.common.brandFull));
    pageCard.appendChild(el("h1", "", entry.title));
    pageCard.appendChild(el("p", "lead", entry.lead));

    entry.sections.forEach((section) => {
      const block = el("section", "section-stack");
      block.appendChild(el("h2", "", section.title));
      if (section.paragraphs) {
        appendParagraphs(block, section.paragraphs);
      }
      if (section.bullets) {
        appendBullets(block, section.bullets);
      }
      pageCard.appendChild(block);
    });

    main.appendChild(pageCard);
  }

  function buildSupport(t) {
    const main = document.querySelector("[data-page-content]");
    main.innerHTML = "";

    const pageCard = el("article", "page-card");
    pageCard.appendChild(el("span", "eyebrow", t.common.brandFull));
    pageCard.appendChild(el("h1", "", t.support.title));
    pageCard.appendChild(el("p", "lead", t.support.lead));
    main.appendChild(pageCard);

    const cards = el("section", "support-grid");
    cards.style.marginTop = "24px";
    cards.innerHTML = t.support.cards.map((card) => `
      <article>
        <h2>${card.title}</h2>
        <p>${card.body}</p>
      </article>
    `).join("");
    main.appendChild(cards);

    const faqWrap = el("section", "section-stack");
    faqWrap.style.marginTop = "24px";
    faqWrap.appendChild(el("h2", "", t.support.faqTitle));
    const faqList = el("div", "faq-list");
    faqList.innerHTML = t.support.faqs.map((faq) => `
      <article class="faq-item">
        <h2>${faq.title}</h2>
        <p>${faq.body}</p>
      </article>
    `).join("");
    faqWrap.appendChild(faqList);
    main.appendChild(faqWrap);

    const notice = el("section", "notice-card");
    notice.style.marginTop = "24px";
    notice.appendChild(el("h2", "", t.support.noticeTitle));
    notice.appendChild(el("p", "", t.support.noticeBody));
    const links = el("div", "link-row");
    const mail = el("a", "button is-primary", t.common.contact);
    mail.href = `mailto:${t.common.contact}`;
    const privacy = el("a", "button", t.common.ctaPrivacy);
    privacy.href = pageLink("privacy", currentLanguage);
    links.appendChild(mail);
    links.appendChild(privacy);
    notice.appendChild(links);
    main.appendChild(notice);
  }

  const currentLanguage = getLanguage();
  const translation = app.translations[currentLanguage] || app.translations.en;

  document.documentElement.lang = currentLanguage;
  document.title = `${translation.common.brandFull} | ${
    page === "home" ? translation.common.navHome :
    page === "privacy" ? translation.common.navPrivacy :
    page === "terms" ? translation.common.navTerms :
    translation.common.navSupport
  }`;

  renderNavigation(translation);
  renderLanguageSwitch();
  renderFooter(translation);

  if (page === "home") {
    buildHome(translation);
  } else if (page === "privacy") {
    buildDocument(translation, translation.privacy);
  } else if (page === "terms") {
    buildDocument(translation, translation.terms);
  } else if (page === "support") {
    buildSupport(translation);
  }
})();
