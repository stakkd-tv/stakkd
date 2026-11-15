import { Marked, type Token } from 'marked'
import { MARKED_CONFIG } from './marked'

const markdownParser = new Marked(MARKED_CONFIG)
const delimiter = '||'

function blockStructure(tokens: Token[] | undefined): string[] {
  if (tokens === undefined) return []
  return tokens.flatMap((token) => {
    if (token.type === 'blockquote') {
      return ['blockquote', ...blockStructure(token.tokens), '/blockquote']
    }
    if (token.type === 'list') {
      return [
        'list',
        ...token.items.flatMap((item: { tokens: Token[] }) => [
          'item',
          ...blockStructure(item.tokens),
          '/item'
        ]),
        '/list'
      ]
    }
    return [token.type]
  })
}

function spoilers(tokens: Token[]) {
  const matches: string[] = []
  const imageAltTokens = new Set<Token>()
  markdownParser.walkTokens(tokens, (token) => {
    if (token.type === 'image' && token.tokens) {
      // Marked renders these descendants as attribute text.
      markdownParser.walkTokens(token.tokens, (child) => {
        imageAltTokens.add(child)
      })
    }
    if (token.type === 'spoiler' && !imageAltTokens.has(token)) {
      matches.push(token.raw)
    }
  })
  return matches
}

function sameSequence(before: string[], after: string[]) {
  return (
    before.length === after.length &&
    before.every((raw, index) => raw === after[index])
  )
}

export function spoilerEdit(markdown: string, start: number, end: number) {
  const before = markdown.slice(0, start)
  const selected = markdown.slice(start, end)
  const after = markdown.slice(end)
  const originalTokens = markdownParser.lexer(markdown)
  const originalSpoilers = spoilers(originalTokens)

  // Marked exposes token text but no source offsets. A temporary marker
  // identifies the token at this selection, even if its text occurs elsewhere.
  let marker = 'StakkdSpoilerSelection'
  while (markdown.includes(marker)) marker += 'X'

  const markedSelection = spoilers(
    markdownParser.lexer(before + marker + selected + after)
  )
  const activeIndex = markedSelection.findIndex((raw) => raw.includes(marker))
  if (activeIndex !== -1) {
    const active = markedSelection[activeIndex]
    const raw = active.replace(marker, '')
    const from = start - active.indexOf(marker)
    const to = from + raw.length
    const contentEnd = to - delimiter.length
    const content = markdown.slice(from + delimiter.length, contentEnd)
    markedSelection.splice(activeIndex, 1)
    const expectedSpoilers = [...markedSelection]
    if (content) expectedSpoilers.splice(activeIndex, 0, raw)

    if (
      markdown.slice(from, to) === raw &&
      from + delimiter.length <= start &&
      end <= contentEnd &&
      sameSequence(originalSpoilers, expectedSpoilers)
    ) {
      const unwrapped = markdown.slice(0, from) + content + markdown.slice(to)
      if (
        !sameSequence(
          markedSelection,
          spoilers(markdownParser.lexer(unwrapped))
        )
      )
        return

      return {
        from,
        to,
        text: content,
        selectionStart: start - delimiter.length,
        active: true
      }
    }
  }

  const wrapped = delimiter + selected + delimiter
  const markedWrap = delimiter + marker + selected + delimiter
  const proposedSpoilers = spoilers(
    markdownParser.lexer(before + markedWrap + after)
  )
  const added = proposedSpoilers.indexOf(markedWrap)
  if (added === -1) return

  // A wrap must create exactly one spoiler and preserve all existing spoilers.
  proposedSpoilers.splice(added, 1)
  if (!sameSequence(originalSpoilers, proposedSpoilers)) return

  const wrappedSpoilers = [...proposedSpoilers]
  if (selected) wrappedSpoilers.splice(added, 0, wrapped)
  const wrappedTokens = markdownParser.lexer(before + wrapped + after)
  if (!sameSequence(wrappedSpoilers, spoilers(wrappedTokens))) return
  const currentLine =
    before.slice(before.lastIndexOf('\n') + 1) + after.split('\n', 1)[0]
  // Empty biographies and blank lines can gain a paragraph when starting a spoiler.
  if (
    (selected || currentLine.trim()) &&
    !sameSequence(blockStructure(originalTokens), blockStructure(wrappedTokens))
  )
    return

  return {
    from: start,
    to: end,
    text: wrapped,
    selectionStart: start + delimiter.length,
    active: false
  }
}
