import js from '@eslint/js';
import * as pluginImport from 'eslint-plugin-import';
import pluginPrettier from 'eslint-plugin-prettier';
import tseslint from 'typescript-eslint';

export default [
    js.configs.recommended,
    ...tseslint.configs.recommendedTypeChecked,
    {
        languageOptions: {
            parserOptions: {
                project: './tsconfig.json',
            },
        },
    },
    {
        plugins: {
            import: pluginImport,
            prettier: pluginPrettier,
        },
        settings: {
            'import/parsers': {
                '@typescript-eslint/parser': ['.ts', '.tsx'],
            },
            'import/resolver': {
                typescript: {
                    alwaysTryTypes: true,
                    project: './tsconfig.json',
                },
            },
        },
        rules: {
            'semi-style': 'error',
            'no-octal-escape': 'error',
            quotes: ['error', 'single', { allowTemplateLiterals: true }],
            'object-shorthand': 'off',
            'func-style': ['error', 'declaration', { allowArrowFunctions: true }],
            'max-classes-per-file': 'off',
            'no-var': 'off',
            'prefer-const': 'off',
            'no-useless-escape': 'off',
            '@typescript-eslint/no-unsafe-call': 'off',
            '@typescript-eslint/no-explicit-any': 'off',
            '@typescript-eslint/no-var-requires': 'off',
            '@typescript-eslint/no-inferrable-types': 'off',
            '@typescript-eslint/no-floating-promises': 'off',
            '@typescript-eslint/no-unsafe-assignment': 'off',
            "@typescript-eslint/no-unsafe-member-access": 'off',
            '@typescript-eslint/explicit-module-boundary-types': 'off',
            '@typescript-eslint/no-unused-vars': [
                'error',
                {
                    vars: 'all',
                    args: 'after-used',
                    ignoreRestSiblings: false,
                    argsIgnorePattern: '^_',
                },
            ],
            'import/prefer-default-export': 'off',
            'import/order': [
                'error',
                {
                    pathGroups: [
                        { pattern: '#/**', group: 'internal' },
                        { pattern: '!/**', group: 'parent' },
                    ],
                    groups: ['builtin', 'external', 'internal', 'parent', 'index', 'sibling'],
                    'newlines-between': 'always',
                    alphabetize: {
                        order: 'asc',
                        caseInsensitive: true,
                    },
                },
            ],
            'no-restricted-imports': [
                'error',
                {
                    patterns: ['./*', '../*'],
                },
            ],
            'prettier/prettier': 'error',
        },
    },
    {
        ignores: ['jest.config.js', 'node_modules', 'tsup.config.ts', 'eslint.config.mjs'],
    },
];
