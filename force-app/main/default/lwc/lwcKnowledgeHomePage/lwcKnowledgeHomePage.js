/** 
    LWC Name    : lwcKnowledgeHomePage.js
    Created Date       : 06 October 2025
    @description       : This is class ..
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    1.0   06/10/2025   Rakeyan Nuramria                  Initial Version
**/


import { LightningElement, api } from 'lwc';
import HERO_SVG from '@salesforce/resourceUrl/heroSVG';
import FALLBACK_IMG from '@salesforce/resourceUrl/imgNotFound';

// Apex (homepage-specific)
import getLatestModulesForHome
  from '@salesforce/apex/KnowledgeHomeController.getLatestModulesForHome';
import getLatestMaterialsForHome
  from '@salesforce/apex/KnowledgeHomeController.getLatestMaterialsForHome';

/** <<< TOGGLE HERE >>> */
const USE_LIVE = true;   // false = dummy data, true = call Apex
const LIMIT    = 20;      // how many items for each section (1..50)
/** ^^^^^^^^^^^^^^^^^^^^^ */

const DEFAULT_IMAGE_URL =
  'https://images.unsplash.com/photo-1498050108023-c5249f4df085?q=80&w=2400&auto=format&fit=crop';

const PAGE_SIZE = 5;

export default class LwcKnowledgeHomePage extends LightningElement {
  /* existing Builder props you already had */
  @api heroMode = 'Auto';
  @api imageUrl = DEFAULT_IMAGE_URL;
  @api modulesHref = '/modules';
  @api materialsHref = '/materials';

  // Loading
  isHeroLoading = true;
  isLoadingModules = true;
  isLoadingMaterials = true;

  // Data
  latestModules = [];
  latestMaterials = [];

  // Slider
  modulesPage = 0;
  materialsPage = 0;

  get skeleton5() { return Array.from({ length: 5 }, (_, i) => `sk-${i + 1}`); }

  /* =========================================
   * Lifecycle
   * =======================================*/
  connectedCallback() {
    const limit = this._clamp(LIMIT, 1, 50);

    if (USE_LIVE) {
      this._fetchLiveData(limit);
    } else {
      this._loadDummyData(limit);
    }
  }

  renderedCallback() {
    this.applyHeroBackground();
    this.updateTrackTransforms();
  }

  /* =========================================
   * Data loading
   * =======================================*/
  _fetchLiveData(limit) {
    this.isLoadingModules = true;
    this.isLoadingMaterials = true;

    // Modules
    getLatestModulesForHome({ limitSize: limit })
      .then(rows => {
        this.latestModules = (rows || []).map((r, i) => ({
          id: r.Id,
          title: r.Name,
          subtitle: 'Module',
          imgSrc: `${FALLBACK_IMG}?m=${i}`
        }));
      })
      .catch(err => {
        // eslint-disable-next-line no-console
        console.error('getLatestModulesForHome error:', err);
        this.latestModules = this._dummyList(this._moduleNames(), limit, 'Module');
      })
      .finally(() => {
        this.isLoadingModules = false;
        this.modulesPage = 0;
        this.updateTrackTransforms();
      });

    // Materials
    getLatestMaterialsForHome({ limitSize: limit })
      .then(rows => {
        this.latestMaterials = (rows || []).map((r, i) => ({
          id: r.id,
          title: r.title,
          subtitle: 'Material',
          moduleName: r.moduleName,
          imgSrc: `${FALLBACK_IMG}?t=${i}`
        }));
      })
      .catch(err => {
        // eslint-disable-next-line no-console
        console.error('getLatestMaterialsForHome error:', err);
        this.latestMaterials = this._dummyList(this._materialNames(), limit, 'Material');
      })
      .finally(() => {
        this.isLoadingMaterials = false;
        this.materialsPage = 0;
        this.updateTrackTransforms();
      });
  }

  _loadDummyData(limit) {
    // Small delays to keep skeleton visible
    setTimeout(() => {
      this.latestModules = this._dummyList(this._moduleNames(), limit, 'Module');
      this.isLoadingModules = false;
      this.modulesPage = 0;
      this.updateTrackTransforms();
    }, 400);

    setTimeout(() => {
      this.latestMaterials = this._dummyList(this._materialNames(), limit, 'Material');
      this.isLoadingMaterials = false;
      this.materialsPage = 0;
      this.updateTrackTransforms();
    }, 550);
  }

  /* =========================================
   * Hero background
   * =======================================*/
  applyHeroBackground() {
    const section = this.template.querySelector('[data-hero]');
    const heroImg = this.template.querySelector('.hero__image');
    if (!section || !heroImg) return;

    const mode = (this.heroMode || 'Auto').toLowerCase();
    const imgUrl = (this.imageUrl || DEFAULT_IMAGE_URL).trim();

    const setSVG = () => {
      heroImg.style.backgroundImage = `url('${HERO_SVG}')`;
      section.dataset.mode = 'svg';
      Promise.resolve().then(() => { this.isHeroLoading = false; });
    };
    const setImage = () => {
      heroImg.style.backgroundImage = `url('${imgUrl}')`;
      section.dataset.mode = 'img';
      this.isHeroLoading = false;
    };

    const key = `${mode}|${imgUrl}`;
    if (heroImg.dataset.appliedKey === key) return;

    this.isHeroLoading = true;
    if (mode === 'auto' || mode === 'svg') {
      setSVG();
    } else if (mode === 'image') {
      setSVG();
      const probe = new Image();
      probe.onload = () => setImage();
      probe.onerror = () => { this.isHeroLoading = false; };
      probe.src = imgUrl;
    } else {
      setSVG();
    }
    heroImg.dataset.appliedKey = key;
  }

  /* =========================================
   * Slider transforms (set via JS, not inline)
   * =======================================*/
  updateTrackTransforms() {
    const modulesTrack = this.template.querySelector('.track[data-grid="modules"]');
    const materialsTrack = this.template.querySelector('.track[data-grid="materials"]');
    if (modulesTrack) modulesTrack.style.transform = `translateX(-${this.modulesPage * 100}%)`;
    if (materialsTrack) materialsTrack.style.transform = `translateX(-${this.materialsPage * 100}%)`;
  }

  /* =========================================
   * Computed (pages & dots)
   * =======================================*/
  _chunk(list, size) {
    const out = [];
    for (let i = 0; i < list.length; i += size) out.push(list.slice(i, i + size));
    return out;
  }

  // Modules
  get modulesTotalPages() {
    return Math.max(1, Math.ceil(this.latestModules.length / PAGE_SIZE));
  }
  get modulesPages() {
    return this._chunk(this.latestModules, PAGE_SIZE).map((items, idx) => ({ key: `m-page-${idx}`, items }));
  }
  get isModulesPrevDisabled() { return this.modulesPage <= 0; }
  get isModulesNextDisabled() { return this.modulesPage >= this.modulesTotalPages - 1; }
  get modulesDots() {
    return Array.from({ length: this.modulesTotalPages }, (_, i) => ({
      key: `m-dot-${i}`,
      className: `dot${i === this.modulesPage ? ' dot--active' : ''}`,
      title: `Go to page ${i + 1}`,
      index: i,
      ariaCurrent: i === this.modulesPage ? 'page' : 'false'
    }));
  }

  // Materials
  get materialsTotalPages() {
    return Math.max(1, Math.ceil(this.latestMaterials.length / PAGE_SIZE));
  }
  get materialsPages() {
    return this._chunk(this.latestMaterials, PAGE_SIZE).map((items, idx) => ({ key: `t-page-${idx}`, items }));
  }
  get isMaterialsPrevDisabled() { return this.materialsPage <= 0; }
  get isMaterialsNextDisabled() { return this.materialsPage >= this.materialsTotalPages - 1; }
  get materialsDots() {
    return Array.from({ length: this.materialsTotalPages }, (_, i) => ({
      key: `t-dot-${i}`,
      className: `dot${i === this.materialsPage ? ' dot--active' : ''}`,
      title: `Go to page ${i + 1}`,
      index: i,
      ariaCurrent: i === this.materialsPage ? 'page' : 'false'
    }));
  }

  /* =========================================
   * Actions
   * =======================================*/
  goPrevModules = () => { if (!this.isModulesPrevDisabled) { this.modulesPage -= 1; this.updateTrackTransforms(); } };
  goNextModules = () => { if (!this.isModulesNextDisabled) { this.modulesPage += 1; this.updateTrackTransforms(); } };
  goToModulesPage = (e) => {
    const idx = Number(e.currentTarget.dataset.index);
    if (!Number.isNaN(idx)) { this.modulesPage = idx; this.updateTrackTransforms(); }
  };

  goPrevMaterials = () => { if (!this.isMaterialsPrevDisabled) { this.materialsPage -= 1; this.updateTrackTransforms(); } };
  goNextMaterials = () => { if (!this.isMaterialsNextDisabled) { this.materialsPage += 1; this.updateTrackTransforms(); } };
  goToMaterialsPage = (e) => {
    const idx = Number(e.currentTarget.dataset.index);
    if (!Number.isNaN(idx)) { this.materialsPage = idx; this.updateTrackTransforms(); }
  };

  /* =========================================
   * Image guard
   * =======================================*/
  handleImgError = (evt) => {
    if (!evt?.target) return;
    evt.target.onerror = null;
    evt.target.src = `${FALLBACK_IMG}?v=${Date.now()}`;
  };

  /* =========================================
   * Dummy data helpers
   * =======================================*/
  _moduleNames() {
    return [
      'Digital Technology, Data & Platform','Digital Network & Connectivity','Digital Transformation',
      'Design & Digital Content','Governance, Risk, & Compliance','Financial & Investment',
      'Business & Management','Personal Development','Customer Experience','Cybersecurity Basics'
    ];
  }
  _materialNames() {
    return [
      'Intro to Data Mesh','API Security 101','OKR for Teams','Design Tokens Basics','Zero Trust Crash Course',
      'LLM Prompting Primer','Cloud Cost Optimization','Journey Mapping Quickstart','SOC2 Essentials','Git Strategy Guide'
    ];
  }

  _moduleBadges() {
    return [
      'Sales Cloud', 'Service Cloud', 'Marketing Cloud', 'Data Cloud',
      'Platform', 'Security', 'DevOps', 'Analytics', 'Integration', 'AI'
    ];
  }
  
  _dummyList(names, n, subtitle) {
    const count = this._clamp(n, 1, 50);
    return Array.from({ length: count }, (_, i) => ({
      id: `${subtitle.toLowerCase().slice(0,3)}-${i + 1}`,
      title: names[i % names.length],
      subtitle,
      moduleName: subtitle === 'Material' ? badges[i % badges.length] : undefined,
      imgSrc: `${FALLBACK_IMG}?d=${subtitle}-${i}`
    }));
  }

  _clamp(n, min, max) {
    let v = parseInt(n, 10);
    if (Number.isNaN(v)) v = min;
    if (v < min) v = min;
    if (v > max) v = max;
    return v;
  }
}