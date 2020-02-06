class Pagenation {
  initParams
  elPagenation;
  currentPage = 1;
  maxPage;
  elNext;
  elNextLink;
  elPrev;
  elPrevLink;

  constructor() {
    this.elPagenation = document.getElementById('pagination');
  }

  init(params, reset = false) {
    if (reset) {
      this.currentPage = 1;
    }
    this.elPagenation.innerHTML = '';
    this.initParams = params
    this.maxPage = Math.ceil(this.initParams['total'] / this.initParams['limit']);
    this._createPageElement('prev', 'Previous');
    for (let i = 1; i <= this.maxPage; i++){
      this._createPageElement(i, i);
    }
    this._createPageElement('next', 'Next');
    this._disabledPagenationBySuffix(this.currentPage);
  }

  getCurrentPage() {
    return this.currentPage;
  }

  _createPageElement(idSuffix, text) {
    const elLi = document.createElement('li');
    elLi.id = 'page-' + idSuffix;
    elLi.classList.add('page-item');

    const elLink = document.createElement('a');
    elLink.id = 'page-link-' + idSuffix;
    elLink.innerText = text;
    elLink.classList.add('page-link');
    elLink.onclick = () => {
      const pageNo = idSuffix;
      let page;
      switch (pageNo) {
        case 'prev':
          page = this.currentPage - 1;
          break;
        case 'next':
          page = this.currentPage + 1;
          break;
        default:
          page = idSuffix
          break;
      }
      fetch(this._generateUrl(page))
      .then(res => {
        if(res.ok){
          return res.json();
        }
      })
      .then(json => {
        this._abledPagenationBySuffix(this.currentPage);
        this.currentPage = page;
        this._disabledPagenationBySuffix(page);
        if (this.currentPage != this.maxPage && this.currentPage != 1) {
          const elPrev = this._getPrevElements();
          const elNext = this._getNextElements();
          if (elNext['li'].classList.contains('disabled')) {
            elNext['li'].classList.remove('disabled');
            elNext['link'].style.pointerEvents = 'auto';
          }
          if (elPrev['li'].classList.contains('disabled')) {
            elPrev['li'].classList.remove('disabled');
            elPrev['link'].style.pointerEvents = 'auto';
          }
        }
        this.initParams['callback'](json);
      });
    }

    elLi.appendChild(elLink);
    this.elPagenation.appendChild(elLi);
  }

  _generateUrl(page) {
    let queryString = 'page=' + page;
    if (this.initParams['queryParams']) {
      for (let key in this.initParams['queryParams']) {
        if (this.initParams['queryParams'][key]) {
          const param = this.initParams['queryParams'][key];
          if (typeof param == 'object') {
            for (let paramKey in param) {
              if (param[paramKey]) {
                queryString += '&' + key + '[' + paramKey + ']=' + param[paramKey];
              }
            }
          } else {
            queryString += '&' + key + '=' + param;
          }
        }
      }
    }
    return this.initParams['apiUrl'] + '?' + new URLSearchParams(queryString);
  }

  _disabledPagenationBySuffix(idSuffix) {
    const elLi   = document.getElementById('page-' + idSuffix);
    const elLink = document.getElementById('page-link-' + idSuffix);
    elLi.classList.add('active');
    if (!elLink.style) {
      document.defaultView.getComputedStyle(elLink, '');
    }
    elLink.style.pointerEvents = 'none';
    if(idSuffix == 1) {
      this._disabledPagenationByHash(this._getPrevElements());
    } else if (idSuffix == this.maxPage) {
      this._disabledPagenationByHash(this._getNextElements());
    }
  }

  _abledPagenationBySuffix(idSuffix) {
    const elLi   = document.getElementById('page-' + idSuffix);
    const elLink = document.getElementById('page-link-' + idSuffix);
    elLi.classList.remove('active');
    if (!elLink.style) {
      document.defaultView.getComputedStyle(elLink, '');
    }
    elLink.style.pointerEvents = 'auto';
  }

  _disabledPagenationByHash(hash) {
    hash['li'].classList.add('disabled');
    if (!hash['link'].style) {
      document.defaultView.getComputedStyle(hash['link'], '');
    }
    hash['link'].style.pointerEvents = 'none';
  }

  _getNextElements() {
    if (!this.elNext) {
      this.elNext = document.getElementById('page-next');
    }
    if (!this.elNextLink) {
      this.elNextLink = document.getElementById('page-link-next');
      document.defaultView.getComputedStyle(this.elNextLink, '');
    }
    return {
      li: this.elNext,
      link: this.elNextLink,
    }
  }

  _getPrevElements() {
    if (!this.elPrev) {
      this.elPrev = document.getElementById('page-prev');
    }
    if (!this.elPrevLink) {
      this.elPrevLink = document.getElementById('page-link-prev');
      document.defaultView.getComputedStyle(this.elPrevLink, '');
    }
    return {
      li: this.elPrev,
      link: this.elPrevLink,
    }
  }
}
