import { Document as FSDocument } from 'flexsearch'
import stockProfiles from './stock-profiles.json'


export const StockSearcher = {
  mounted() {
    // For access inside autocomplete constructor
    const self = this

    this.index = new FSDocument({
      document: {
        id: 'id',
        index: ['name', 'symbol'],
        store: ['name', 'symbol', 'image', 'sector', 'industry']
      },
      resolution: 3,
      tokenize: 'full',
    })


    stockProfiles.forEach((item, id) => {
      this.index.addAsync({ ...item, id })
    })

    const search = (query = '') => {
      const resultsList = this.index.search(query, {
        enrich: true,
        limit: 10,
      })

      const allResults = resultsList.reduce((acc, { field, result = [] } = {}) => {
        const slimResults = result.map(({ doc: { name, symbol, ...rest } } = {}) => ({ ...rest, label: name, value: symbol }))
        return acc.concat(slimResults)
      }, [])

      return allResults
    }

    autocomplete({
      emptyMsg: 'No results found',
      fetch: function (text, update) {
        const results = search(text)
        update(results)
      },
      input: document.getElementById(this.el.id),
      minLength: 1,
      onSelect: function (item) {
        self.pushEvent("unauthenticated-search-item-selected", { symbol: item.value })
      },
      render: function (item) {
        const container = document.createElement("div");
        container.className = 'flex flex-row items-center justify-between space-x-4 border-b border-gray-200'
        container.style = 'padding: 6px 8px 6px 8px;'
        const textContainer = container.appendChild(document.createElement('div'))
        textContainer.className = 'flex flex-row flex-wrap w-2/3 space-x-2'
        const symbol = textContainer.appendChild(document.createElement('p'))
        symbol.innerHTML = item.value
        symbol.className = 'tracking-tight leading-3 w-1/6';
        symbol.style = 'font-size: 11px; font-weight: 400;'
        const name = textContainer.appendChild(document.createElement('p'))
        name.innerHTML = item.label
        name.className = 'font-medium tracking-tight leading-3 line-clamp-1 truncate w-2/3'
        name.style = 'font-size: 11px; font-weight: 500;'
        const sector = container.appendChild(document.createElement('p'))
        sector.innerHTML = item.sector
        sector.className = 'bg-gray-100 text-gray-500 rounded-sm line-clamp-1'
        sector.style = 'padding: 0px 4px 0px 4px; font-size: 9px;'
        return container;
      }
    });
  }
}