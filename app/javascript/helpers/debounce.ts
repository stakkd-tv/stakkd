export function debounce (fn: () => void, delay: number) {
  let timer: number | null = null
  return function debouncer (...args: unknown[]) {
    if (timer) clearTimeout(timer)
    timer = setTimeout(() => {
      timer = null
      fn.apply(this, args)
    }, delay)
  }
}
