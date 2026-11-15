export function createStubSearchClient(
  typesenseConfig: HTMLElement,
  union: boolean | null | undefined
) {
  return {
    async search(
      requests: { indexName: string; params?: { query?: string } }[]
    ) {
      const stubbedHits: Record<string, Record<string, unknown>[]> = JSON.parse(
        typesenseConfig.dataset.testSearchHits ?? '{}'
      )
      const matches = requests.map(({ indexName, params }) => {
        const query = params?.query ?? ''
        return { query, hits: stubbedHits[`${indexName}:${query}`] ?? [] }
      })
      const unionHits = union ? matches.flatMap(({ hits }) => hits) : null
      return {
        results: matches.map(({ query, hits: indexHits }) => {
          const hits = unionHits ?? indexHits
          return {
            hits,
            nbHits: hits.length,
            page: 0,
            nbPages: hits.length > 0 ? 1 : 0,
            hitsPerPage: hits.length,
            processingTimeMS: 0,
            exhaustiveNbHits: true,
            query,
            params: ''
          }
        })
      }
    }
  }
}
