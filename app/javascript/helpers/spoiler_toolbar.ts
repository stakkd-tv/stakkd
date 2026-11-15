import type EasyMDE from 'easymde'
import { spoilerEdit } from './spoiler_selection'

function rangeTouchesCode(editor: EasyMDE, start: number, end: number) {
  const { codemirror } = editor
  const from = codemirror.posFromIndex(start)
  const to = codemirror.posFromIndex(end)

  for (let line = from.line; line <= to.line; line++) {
    const startCh = line === from.line ? from.ch : 0
    const endCh = line === to.line ? to.ch : codemirror.getLine(line).length
    // GFM wraps the Markdown state. A fence can contain blank lines or tokens
    // from a language mode, so check the state entering the line as well.
    // @ts-expect-error -- CodeMirror accepts precise, which its types omit.
    if (line > 0 && codemirror.getStateAfter(line - 1, true).base.fencedEndRE) {
      return true
    }

    for (const token of codemirror.getLineTokens(line, true)) {
      const types = token.type?.split(' ')
      if (!types?.includes('comment')) continue
      if (start === end) {
        const afterClosingBackticks =
          startCh === token.end &&
          types.includes('formatting-code') &&
          !token.state.base.code
        const onOpeningFence =
          token.start === startCh && types.includes('formatting-code-block')
        if (
          (token.start < startCh || onOpeningFence) &&
          token.end >= startCh &&
          !afterClosingBackticks
        ) {
          return true
        }
      } else if (token.start < endCh && token.end > startCh) {
        return true
      }
    }
  }

  return false
}

function selectionEdit(editor: EasyMDE) {
  const { codemirror } = editor
  const start = codemirror.indexFromPos(codemirror.getCursor('from'))
  const end = codemirror.indexFromPos(codemirror.getCursor('to'))
  if (rangeTouchesCode(editor, start, end)) return

  return spoilerEdit(codemirror.getValue(), start, end)
}

function toggleSpoiler(editor: EasyMDE) {
  const edit = selectionEdit(editor)
  if (!edit) return

  const { codemirror } = editor
  const selectedLength = codemirror.getSelection().length
  codemirror.operation(() => {
    codemirror.replaceRange(
      edit.text,
      codemirror.posFromIndex(edit.from),
      codemirror.posFromIndex(edit.to)
    )
    codemirror.setSelection(
      codemirror.posFromIndex(edit.selectionStart),
      codemirror.posFromIndex(edit.selectionStart + selectedLength)
    )
  })
  codemirror.focus()
}

export const spoilerToolbarButton = {
  name: 'spoiler',
  action: toggleSpoiler,
  className: 'fa fa-eye-slash',
  title: 'Spoiler',
  attributes: { 'aria-pressed': 'false' }
}

export function trackSpoilerToolbarState(editor: EasyMDE) {
  const button = editor.codemirror
    .getWrapperElement()
    .parentElement?.querySelector(
      `.editor-toolbar button.${spoilerToolbarButton.name}`
    )
  if (!button) return

  // Run after EasyMDE updates the active state of its built-in buttons.
  const update = () => {
    const edit = selectionEdit(editor)
    const active = edit?.active ?? false
    button.setAttribute('aria-disabled', String(!edit))
    button.classList.toggle('active', active)
    button.setAttribute('aria-pressed', String(active))
  }
  editor.codemirror.on('cursorActivity', update)
  update()
}
