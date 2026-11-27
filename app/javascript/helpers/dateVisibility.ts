type DateVisibilityControls = {
  input: HTMLInputElement
  showButton: HTMLButtonElement
  hideButton: HTMLButtonElement
  items: HTMLElement | null
  enabled?: boolean
}

export function applyDateVisibility(
  show: boolean,
  {
    input,
    showButton,
    hideButton,
    items,
    enabled = true
  }: DateVisibilityControls
) {
  input.value = String(!show)
  if (items) items.dataset.showDates = String(show && enabled)
  showButton.dataset.active = String(show)
  hideButton.dataset.active = String(!show)
  showButton.setAttribute('aria-pressed', String(show))
  hideButton.setAttribute('aria-pressed', String(!show))
}

export function updateDateVisibilityUrl(show: boolean) {
  const url = new URL(window.location.href)
  if (show) url.searchParams.delete('hide_dates')
  else url.searchParams.set('hide_dates', 'true')
  // This display preference belongs to the current listing. Preserve Turbo's
  // history state so Back/Forward can still restore results and filters.
  window.history.replaceState(window.history.state, '', url)
}

export function datesVisibleFromUrl() {
  return new URL(window.location.href).searchParams.get('hide_dates') !== 'true'
}
