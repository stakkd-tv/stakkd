import sanitizeHtml from 'sanitize-html'

export function sanitize (html: string): string {
  const allowedAttributes = sanitizeHtml.defaults.allowedAttributes
  allowedAttributes.div = ['align']
  allowedAttributes.p = ['align']
  allowedAttributes.img = allowedAttributes.img.concat(['align'])
  allowedAttributes.source = allowedAttributes.img.concat(['media'])
  allowedAttributes.span = ['class']
  const options = {
    allowedTags: sanitizeHtml.defaults.allowedTags.concat(['center', 'img', 'picture', 'source']),
    allowedAttributes,
    allowedClasses: {
      span: ['spoiler']
    }
  }
  return sanitizeHtml(html, options)
}
