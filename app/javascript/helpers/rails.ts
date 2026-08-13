export type RailsEnv = 'development' | 'test' | 'production'

export function getRailsEnv(): RailsEnv {
  return (
    (document.querySelector<HTMLElement>('#rails-env')
      ?.textContent as RailsEnv) || 'development'
  )
}
