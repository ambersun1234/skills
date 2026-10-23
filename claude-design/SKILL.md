---
name: claude-design
description: Use BEFORE any UI/UX design work: a Claude Design canvas or design Artifact, mockups, boards, approval comments on a design, walking through teammates' design comments, or sharing a design link. Covers starting from real product screenshots, flow arrows, section/board codes, red pins, annotations, existing product components, approval records, and sharing before handover. Also load the company design skill (`<company>-design`) if one exists.
---

# Claude Design canvas

## Sharing a design link
- Share every canvas per the org's policy before handing over the link; a company skill names who gets Owner and what General access is. Prefer General access over one-by-one invites.
- The Artifact tool can't change sharing: use the **Share** dialog in the UI (roles: Owner / Editor / Commenter / Viewer; Owner manages access), via Claude in Chrome, screen lock first.
- Reopen the dialog to confirm, and say so at handover. If it can't be done, say so and list it as open; never hand over a link as if shared.

## Start from the real screens, draw the flow
- Screenshot every existing screen the flow touches in the dev/staging environment (and existing emails, for a notification), and draw the change on top. Don't invent a new look.
- Draw how a user moves between screens: which control they click, and under what condition they land where (success, a validation error, a conflict, a record in a given state). Connect boards with arrows labelled with the action or condition.
- After drawing, run one UX review (flow completeness, feedback, error recovery, consistency, copy, accessibility) and fix what it finds.
- After every publish, however small, open the changed board in Chrome (screen lock first, per `screen-recording-skill`) before reporting it done. Shrinking a dialog can expose the screenshot's own dialog behind it.

## Reviews and approvals
- **Record an approval only after the user explicitly approves** ("approved", "approve", 核准). "Looks fine" or similar is not an approval; ask before recording. Never add or update an approval record on your own judgement.
- **Record each approval as a comment on every board of the section** (one per board): section and board, the publish's `Version N`, who approved, and the date. Pin it at the board's top-right edge, never over the design. Add it through the canvas Comment UI in Chrome (screen lock first, per `screen-recording-skill`) and confirm it shows.
- **A board changed after approval** needs the user's explicit approval again. Only then add two stacked replies on its approval thread: a new approval line with the new `Version N`, then what changed since the last approved version. Never replace the original.
- **Before replying on an approval thread, confirm the thread visually.** Open the thread at the board's top-right corner, screenshot it, and check its first comment is the `✅ Approved` record for that exact board (section, code, title). Never reply into a thread found by text search or guesswork; a wrong reply can't be deleted, only edited into a "wrong place" note. If the check fails, stop and say so.
- **Walking through teammates' comments, on "next":** show the next comment verbatim and where it sits (section, board, pinned element), then offer options with a recommendation. Don't change the design before the user answers.
- Approval and version records (`✅ Approved … Version N …`, `✏️ Changed since Version N …`) are in English.
- Review one section at a time. Don't raise other sections unless it's a major mistake; note it for later.

## Layout
- One section per feature.
- A one-letter code per section, boards numbered under it (`S1`, `S2`, `S4b`), in every section and board title. Notes and links use the codes.
- The canvas title carries the parent issue's number; each section title, its own issue's number.
- Main boards run left to right in number order, uninterrupted. A supplementary board (variants or states, e.g. `S4b`) sits directly above or below its board, labelled (`↑ states of S4`), never in the row.
- A demo board with fake entries is fine when it's the clearest way to show every state.
- Use the same sample data across one flow.
- No overview (`O`) section.

## Annotations
- As plain canvas text (not sticky notes), right next to what they explain, with line breaks.
- Keep claims exact; no "only" unless true.
- Red numbered pins on every board, flow diagrams included: in flow order across the section, unique per section, readable size, and each note line starts with its pin (`⑤ …`). Turn pins off where a board is reused.
- Pins are annotation: never build them into the product unless told to.
- Refer to another board by its direct artboard link, not just its name.
- Mention interactions a static frame can't show (hover, what a click opens).

## Design judgement
- Copy: short and complete. No examples that make a statement sound partial. Side remarks at the bottom as a `>` quote. Cut what the reader doesn't need.
- Don't invent distinctions the user can't feel: two backend actions that look the same get the same word.
- A small, consistent set of status marks. Every row gets one (a blank row looks broken). A finished state never spins. Red only for something still wrong.
- Tabs only for real categories; a message about the whole operation sits outside any tab.
- Stay close to the existing UI: overlays match native alignment and style (measure, don't eyeball), no decoration the product doesn't use (underlines, spinners in cells).
- Always draw the product's existing components (find them in its frontend components directory or UI library), with their real look and wording. A control with no matching component is called out in the note as new.
- Show interactions in place: a tooltip next to its element, with a pointer, in the hovered state.
- A dialog fits its content. A smaller dialog must not let the screenshot's own dialog show through: use a clean page plus a drawn dim layer.
