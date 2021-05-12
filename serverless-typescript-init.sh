#!/bin/bash

set -e

yarn init -y
yarn add serverless

rm package.json

npx sls create --template aws-nodejs-typescript

echo "node_modules" > .gitignore

yarn add --dev eslint-config-airbnb-base
npx install-peerdeps --dev eslint-config-airbnb-base --yarn
yarn add --dev \
    eslint-config-prettier \
    eslint-plugin-prettier \
    @typescript-eslint/parser \
    @typescript-eslint/eslint-plugin \
    eslint-import-resolver-typescript \
    prettier-plugin-sh

echo "{}" >.prettierrc
jq '.semi = true' .prettierrc >.prettierrc.tmp && mv .prettierrc.tmp .prettierrc
jq '.trailingComma = "all"' .prettierrc >.prettierrc.tmp && mv .prettierrc.tmp .prettierrc
jq '.singleQuote = true' .prettierrc >.prettierrc.tmp && mv .prettierrc.tmp .prettierrc
jq '.printWidth = 120' .prettierrc >.prettierrc.tmp && mv .prettierrc.tmp .prettierrc
jq '.tabWidth = 4' .prettierrc >.prettierrc.tmp && mv .prettierrc.tmp .prettierrc
jq '.plugins[0] = "prettier-plugin-sh"' .prettierrc >.prettierrc.tmp && mv .prettierrc.tmp .prettierrc

echo "{}" >.eslintrc
jq '.parser = "@typescript-eslint/parser"' .eslintrc >.eslintrc.tmp && mv .eslintrc.tmp .eslintrc
jq '.parserOptions.project = "./tsconfig.eslint.json"' .eslintrc >.eslintrc.tmp && mv .eslintrc.tmp .eslintrc
jq '.extends[0] = "airbnb-base"' .eslintrc >.eslintrc.tmp && mv .eslintrc.tmp .eslintrc
jq '.extends[1] = "plugin:@typescript-eslint/recommended"' .eslintrc >.eslintrc.tmp && mv .eslintrc.tmp .eslintrc
jq '.extends[2] = "prettier"' .eslintrc >.eslintrc.tmp && mv .eslintrc.tmp .eslintrc
jq '.plugins[0] = "@typescript-eslint"' .eslintrc >.eslintrc.tmp && mv .eslintrc.tmp .eslintrc
jq '.plugins[1] = "prettier"' .eslintrc >.eslintrc.tmp && mv .eslintrc.tmp .eslintrc
jq '.rules."@typescript-eslint/no-floating-promises" = "error"' .eslintrc >.eslintrc.tmp && mv .eslintrc.tmp .eslintrc
jq '.rules."import/extensions" = "off"' .eslintrc >.eslintrc.tmp && mv .eslintrc.tmp .eslintrc
jq '.rules."import/prefer-default-export" = "off"' .eslintrc >.eslintrc.tmp && mv .eslintrc.tmp .eslintrc
jq '.settings."import/resolver".typescript.alwaysTryTypes = true' .eslintrc >.eslintrc.tmp && mv .eslintrc.tmp .eslintrc
jq '.settings."import/resolver".typescript.paths = "./tsconfig.json"' .eslintrc >.eslintrc.tmp && mv .eslintrc.tmp .eslintrc

echo "{}" >tsconfig.eslint.json
jq '.extends = "./tsconfig.json"' tsconfig.eslint.json >tsconfig.eslint.json.tmp && mv tsconfig.eslint.json.tmp tsconfig.eslint.json

echo "webpack.config.js" >>.eslintignore
echo "commitlint.config.js" >>.eslintignore
echo ".lintstagedrc" >>.prettierignore
echo "yarn.lock" >>.prettierignore

yarn add --dev lint-staged
echo "{}" >.lintstagedrc
jq '."*"[0] = "npx prettier --write"' .lintstagedrc >.lintstagedrc.tmp && mv .lintstagedrc.tmp .lintstagedrc
jq '."*"[1] = "npx prettier -c"' .lintstagedrc >.lintstagedrc.tmp && mv .lintstagedrc.tmp .lintstagedrc
jq '."*.{js,jsx,ts,tsx}"[0] = "npx eslint --fix"' .lintstagedrc >.lintstagedrc.tmp && mv .lintstagedrc.tmp .lintstagedrc
jq '."*.{js,jsx,ts,tsx}"[1] = "npx eslint"' .lintstagedrc >.lintstagedrc.tmp && mv .lintstagedrc.tmp .lintstagedrc

yarn add --dev husky
npx husky install
npx husky add .husky/pre-commit "npx lint-staged"

yarn add --dev @commitlint/{config-conventional,cli}
echo "module.exports = {extends: ['@commitlint/config-conventional']}" >commitlint.config.js
npx husky add .husky/commit-msg "npx --no-install commitlint --edit $1"

git add --all
git commit -m "chore: initialize project with asinkxcoswt/project-init/main/serverless-typescript-init.sh"