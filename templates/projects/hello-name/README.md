# AiVectra Hello Name

Minimal AiVectra app template for package-based projects.

Desktop targets expose AiVectra's generic application menu descriptors through
their native menu equivalent where available. The default menu includes About
and Settings. Settings is delivered to the app as a deterministic
`command/settings` event so app preferences stay in AiLang state.

After creating a project from this template, restore packages and run:

```bash
ailang package restore
ailang run .
```
