/** 
    LWC Name    : krCategoryGrid.js
    Created Date       : 07 October 2025
    @description       : This is class ..
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    1.0   07/10/2025   Rakeyan Nuramria                  Initial Version
**/

import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import COMMUNITY_ID from '@salesforce/community/Id';
import BASE_PATH from '@salesforce/community/basePath';
import IMG_FALLBACK from '@salesforce/resourceUrl/imgNotFound';
import getModules from '@salesforce/apex/MaterialController.getModules';

// Detect Experience Builder (safe, no crashing SSR/Locker checks)
const IN_BUILDER = (() => {
    try {
      if (typeof window === 'undefined') return false;
      const href = String(window.location?.href || '');
      // Builder URLs usually include ".builder.salesforce-experience.com" and "/builder/"
      return href.includes('.builder.salesforce-experience.com') || href.includes('/builder/');
    } catch {
      return false;
    }
  })();
  

export default class KrCategoryGrid extends NavigationMixin(LightningElement) {
  // ---- Public props (Builder) ----
  /** "apex" | "mock" */
  @api sourceMode = 'apex';
  /** "none" | "empty" | "error" — force a UI state for testing */
  @api simulate = 'none';
  /** mock-only knobs */
  @api mockCount; // string from builder, e.g. "30"
  @api mockDelay; // string from builder, e.g. "600"

  // helper to coerce numbers with a fallback and bounds
  _num(v, fallback, { min = -Infinity, max = Infinity } = {}) {
    const n = Number(v);
    return Number.isFinite(n) ? Math.min(max, Math.max(min, n)) : fallback;
  }  
    

  /** Experience Cloud nav */
  @api homeNamedPage = 'Home';
  @api homeUrl;

  // ---- UI state ----
  isLoading = true;
  errorMsg = '';
  skeletonSlots = Array.from({ length: 15 }, (_, i) => `sk-${i + 1}`);

  // ---- Sorting ----
  selectedSort = 'titleAsc';
  sortOptions = [
    { label: 'A → Z', value: 'titleAsc' },
    { label: 'Z → A', value: 'titleDesc' },
    { label: 'Most items', value: 'countDesc' },
    { label: 'Fewest items', value: 'countAsc' }
  ];

  /** Unified item shape: { id, title, subtitle, count, bgStyle } */
  items = [];
  _lastMode;
  _lastSim;

  // ---- Lifecycle ----
  connectedCallback() {
    this._lastMode = this.sourceMode;
    this._lastSim  = this.simulate;
    this.loadData();
  }

  renderedCallback() {
    if (this._lastMode !== this.sourceMode || this._lastSim !== this.simulate) {
      this._lastMode = this.sourceMode;
      this._lastSim  = this.simulate;
      this.loadData();
    }
  }

  // ---- Data loader (switchable + sim states) ----
  async loadData() {
    this.isLoading = true;
    this.errorMsg = '';
    this.items = [];
    try {
      // If we’re inside Experience Builder, always use mock and skip Apex
      if (IN_BUILDER) {
        const delay = this._num(this.mockDelay, 600, { min: 0, max: 60000 });
        if (delay > 0) await new Promise(r => setTimeout(r, delay));
        const count = this._num(this.mockCount, 30, { min: 0, max: 999 });
        this.items = this._buildDummy(count);
      } else {
        // Respect your selected source when NOT in Builder
        const mode = (this.sourceMode || 'apex').toLowerCase();
        if (mode === 'mock') {
          const delay = this._num(this.mockDelay, 600, { min: 0, max: 60000 });
          if (delay > 0) await new Promise(r => setTimeout(r, delay));
          const count = this._num(this.mockCount, 30, { min: 0, max: 999 });
          this.items = this._buildDummy(count);
        } else {
          const data = await getModules(); // real Apex
          this.items = (data || []).map((m, idx) => {
            const count = m.materialCount || 0;
            return {
              id: `mod-${idx + 1}`,
              title: m.moduleName,
              subtitle: `${count} ${count === 1 ? 'material' : 'materials'}`,
              count,
              bgStyle: `background-image:url("${IMG_FALLBACK}")`
            };
          });
        }
      }
  
      // Apply simulation overrides after data load
      const sim = (this.simulate || 'none').toLowerCase();
      if (sim === 'error') throw new Error('Simulated error (set Simulate to "none" to disable).');
      if (sim === 'empty') this.items = [];
    } catch (e) {
      this.errorMsg = e?.body?.message || e?.message || 'Failed to load modules.';
      this.items = [];
    } finally {
      this.isLoading = false;
    }
  }
  

  /** Optional programmatic refresh */
  @api refresh() { return this.loadData(); }

  // ---- Derived UI flags ----
  get hasError()   { return !!this.errorMsg; }
  get hasEmpty()   { return !this.isLoading && !this.errorMsg && this.items.length === 0; }
  get hasContent() { return !this.isLoading && !this.errorMsg && this.items.length > 0; }

  // ---- Actions ----
  handleRetry = () => { this.refresh(); };

  handleSortChange(e) { this.selectedSort = e.detail.value; }

  get displayItems() {
    const arr = [...this.items];
    switch (this.selectedSort) {
      case 'titleDesc': arr.sort((a, b) => b.title.localeCompare(a.title)); break;
      case 'countDesc': arr.sort((a, b) => b.count - a.count || a.title.localeCompare(b.title)); break;
      case 'countAsc':  arr.sort((a, b) => a.count - b.count || a.title.localeCompare(b.title)); break;
      default:          arr.sort((a, b) => a.title.localeCompare(b.title)); break;
    }
    return arr;
  }

  // ---- Back to Home (robust for Experience Cloud) ----
  get _communityHomeUrl() {
    if (this.homeUrl && typeof this.homeUrl === 'string') {
      const u = this.homeUrl.trim();
      return u.endsWith('/') ? u : u + '/';
    }
    const base = (BASE_PATH ?? '').trim(); // "", "/", or "/site/s"
    if (!base) return '/';
    return base.endsWith('/') ? base : base + '/';
  }

  handleBackHome = () => {
    if (COMMUNITY_ID) {
      try {
        this[NavigationMixin.Navigate]({
          type: 'comm__namedPage',
          attributes: { name: this.homeNamedPage || 'Home' }
        });
        return;
      } catch (_e1) {}
      try {
        this[NavigationMixin.Navigate]({
          type: 'standard__webPage',
          attributes: { url: this._communityHomeUrl }
        });
        return;
      } catch (_e2) {}
      try { window.location.assign(this._communityHomeUrl); } catch (_e3) {}
      return;
    }

    // Core Lightning
    this[NavigationMixin.Navigate]({
      type: 'standard__namedPage',
      attributes: { pageName: 'home' }
    });
  };

  // ---- Dummy data ----
  _buildDummy(n) {
    const names = [
      'Digital Technology, Data & Platform','Digital Network & Connectivity','Digital Transformation',
      'Design & Digital Content','Governance, Risk, & Compliance','Financial & Investment',
      'Business & Management','Personal Development','Customer Experience','Cybersecurity Basics',
      'Cloud Foundations','Agile & Scrum'
    ];
    return Array.from({ length: n }, (_, i) => {
      const title = `${names[i % names.length]} ${i + 1}`;
      const count = (i * 7) % 9 + 1; // 1..9 for variety
      return {
        id: `mock-${i + 1}`,
        title,
        subtitle: `${count} ${count === 1 ? 'material' : 'materials'}`,
        count,
        bgStyle: `background-image:url("${IMG_FALLBACK}")`
      };
    });
  }
}