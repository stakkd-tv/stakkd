import globals from 'globals'
import tsParser from '@typescript-eslint/parser'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import js from '@eslint/js'
import { FlatCompat } from '@eslint/eslintrc'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)
const compat = new FlatCompat({
  baseDirectory: __dirname,
  recommendedConfig: js.configs.recommended,
  allConfig: js.configs.all
})

export default [
  ...compat.extends('standard'),
  {
    languageOptions: {
      globals: {
        ...globals.browser
      },

      ecmaVersion: 'latest',
      sourceType: 'module'
    },

    rules: {}
  },
  ...compat
    .extends('standard', 'plugin:@typescript-eslint/recommended')
    .map((config) => ({
      ...config,
      files: ['**/*.ts']
    })),
  {
    files: ['**/*.ts'],

    languageOptions: {
      parser: tsParser
    }
  }
]
