import instantsearch, { Widget, IndexWidget } from 'instantsearch.js'
import TypesenseInstantsearchAdapter from 'typesense-instantsearch-adapter'

type AdapterOptions = ConstructorParameters<typeof TypesenseInstantsearchAdapter>[0];

type AdditionalSearchParameters = AdapterOptions['additionalSearchParameters'];
type CollectionSpecificSearchParameters = AdapterOptions['collectionSpecificSearchParameters'];

type LiveSearchOptions = {
  widgets: (Widget | IndexWidget | (Widget | IndexWidget)[])[],
  union?: boolean | null,
  indexName?: string,
  additionalSearchParameters?: AdditionalSearchParameters,
  collectionSpecificSearchParameters?: CollectionSpecificSearchParameters
}

export function setupLiveSearch ({ widgets, union, indexName, additionalSearchParameters, collectionSpecificSearchParameters }: LiveSearchOptions) {
  const typesenseConfig = document.getElementById('typesense-config')
  const apiKey = typesenseConfig?.getAttribute('data-api-key')
  const host = typesenseConfig?.getAttribute('data-host')
  const port = typesenseConfig?.getAttribute('data-port')
  const protocol = typesenseConfig?.getAttribute('data-protocol')
  if (!apiKey || !host || !port || !protocol) {
    throw new Error(`Typesense config not valid. ${apiKey}, ${host}, ${port}, ${protocol}`)
  }

  const adapter = new TypesenseInstantsearchAdapter({
    server: {
      apiKey,
      nodes: [
        {
          host,
          port: parseInt(port),
          protocol
        }
      ]
    },
    // @ts-expect-error: Object literal may only specify known properties, and union does not exist in type
    union,
    additionalSearchParameters,
    collectionSpecificSearchParameters
  })

  const searchClient = adapter.searchClient
  const search = instantsearch({
    searchClient,
    indexName
  })

  search.addWidgets(widgets)
  search.start()
}
