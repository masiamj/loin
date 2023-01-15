import { Document as FSDocument } from 'flexsearch'
import stockProfiles from './stock-profiles.json'

window.FSDocument = FSDocument

const index = new FSDocument({
  document: {
    id: 'id',
    index: ['name', 'symbol'],
    store: ['name', 'symbol']
  },
  resolution: 9,
  tokenize: 'full',
})


stockProfiles.forEach((item, id) => {
  index.addAsync({ ...item, id })
})

const search = (query = '') => index.search(query, {
  enrich: true,
})

export const StockSearcher = {
  mounted() {
    console.log("mounted search!")
  }
}