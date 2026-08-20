# Drive Better - Project Workspace

Welcome to the **Drive Better** repository! This workspace contains both the Flutter mobile application and the Cloudflare Workers backend proxy.

## Project Structure

*   **[drive_better](file:///d:/Developments/Drive%20Better/drive_better/)**: The main Flutter mobile application (Android-first).
    *   For full details on architecture, state management, routes, database, design tokens, and local setup, see **[drive_better/AGENTS.md](file:///d:/Developments/Drive%20Better/drive_better/AGENTS.md)**.
*   **[backend](file:///d:/Developments/Drive%20Better/backend/)**: Cloudflare Workers proxy backend.
    *   Holds the Anthropic API keys and acts as a gateway for the Flutter app.
    *   For deployment guidelines, see **[backend/DEPLOY.md](file:///d:/Developments/Drive%20Better/backend/DEPLOY.md)**.
*   **[Driving Theory Book 2022.pdf](file:///d:/Developments/Drive%20Better/Driving Theory Book 2022.pdf)**: Reference theory book used for extracting question banks.
*   **[drive_better_questions_sheet.csv](file:///d:/Developments/Drive%20Better/drive_better_questions_sheet.csv)**: Local database questions source.

## Token Saving & Optimization Guidelines

To keep context window sizes and token counts minimal, please follow these guidelines when using AI agents:
1.  **Ignore Build Folders**: Ensure `.dart_tool/`, `build/`, and `node_modules/` are not parsed or indexed. They are excluded via the root `.gitignore`.
2.  **Avoid Parsing Binary Assets**: The PDF file `Driving Theory Book 2022.pdf` is large (18.5 MB) and should not be read into the context window of your agent.
3.  **Clean up Metadata**: All macOS metadata files (`._*`) have been removed from the repository. Ensure any new file transfers do not reintroduce these hidden files.

## Running the App

To build and run the app, refer to the step-by-step instructions in **[drive_better/AGENTS.md](file:///d:/Developments/Drive%20Better/drive_better/AGENTS.md)**.
