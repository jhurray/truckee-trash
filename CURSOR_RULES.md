# Cursor Usage Guidelines

When working in VS Code with the Cursor extension, follow these rules to maintain project consistency:

1. **Type Checking** – Keep TypeScript strict mode enabled. Fix any type errors before committing.
2. **Imports** – Use relative imports within the `pages`, `components`, and `lib` directories.
3. **Testing** – Use the built-in test task or run `npm test` in the terminal before pushing changes.
4. **iOS Development** – Generate the project with `tuist generate` each time dependencies change.
5. **Documentation** – Update the appropriate README if your change affects setup or usage.

