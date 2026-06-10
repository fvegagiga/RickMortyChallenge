---
name: enrich-us
description: Analyze and enhance user stories with complete, implementation-ready technical detail from direct ticket input or Jira.
author: Fernando Vega
version: 1.0.0
---
# enrich-us Skill

Use it when this workflow is required in the project.

## Instructions

Please analyze and enrich the ticket: $ARGUMENTS.

Follow these steps:

1. Determine the ticket input source:
   - **Direct input mode (default when ticket text is provided):** Use the ticket content shared by the user in the prompt/chat.
   - **Jira mode (optional):** If the user provides a Jira id/key, or asks to use Jira (including references like "the one in progress"), use Jira MCP to fetch the ticket details.
2. Act as a product expert with technical knowledge.
3. Understand the problem described in the ticket.
4. Decide whether or not the User Story is completely detailed according to product best practices. Validate that it includes:
   - Full functionality description
   - Comprehensive list of fields to update
   - Required endpoints structure and URLs
   - Files/modules to modify according to architecture and best practices
   - Definition of done (implementation and delivery steps)
   - Documentation and unit test updates
   - Non-functional requirements (security, performance, observability, etc.)
5. If the story lacks enough technical detail for autonomous implementation, provide an improved version that is clearer, more specific, and concise, aligned with step 4. Use project technical context from `@documentation`. Return the result in markdown.
6. Output format must always include:
   - `## Original`
   - `## Enhanced`
7. Persist output (Direct input mode only):
   - When **not** using Jira (i.e., Direct input mode), save the generated output to `docs/current-task/task-definition.md`.
   - Create the file if it does not exist; overwrite it completely if a previous version exists.
   - The file content must be the full output from step 6 (the `## Original` and `## Enhanced` sections).
   - This step does not apply in Jira mode.
8. Jira write-back is optional and only applies in Jira mode:
   - Update the Jira ticket by appending the enhanced content after the original content, with clear `h2` sections `[original]` and `[enhanced]` and readable formatting (lists/code snippets when useful).
   - If ticket status is `To refine`, move it to `Pending refinement validation`.

## Notes

- Do not require Jira when the user already provided full ticket content directly.
- If input is ambiguous (for example, user gives a short reference without content), ask whether to resolve via Jira or request the full ticket text.
- In Direct input mode, the canonical output location is `docs/current-task/task-definition.md` (created if missing, overwritten if present).
