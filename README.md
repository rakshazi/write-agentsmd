# write-AGENTSmd skill

> a story will be published to [rakshazi.me/blog/](https://rakshazi.me/blog/) later,
> because at the moment this file is created, I still extensively work on the skill based on my projects.

"AGENTS.md is essential for coding agents to comprehensively understand the codebase of your specific project..."
yada-yada.

Look, AGENTS.md can save you time on prompting - instead of stating a lot of stuff and conventions in each prompt
(and I was poked multiple times by readers of [Learn How To Prompt Already](https://rakshazi.me/blog/learn-how-to-prompt-already/) that "design prompts" can be simplified by using AGENTS.md),
you can prepare such file once and it will be picked automatically by your harness.

Sounds good? Yup, thought it doesn't "magically" make your agent smarter or aware about your codebase.

Also, [research shows](./references/evidence.md) that generated AGENTS.md are pointless _at best_,
so you should always write it manually.

Will you, though? Yeah, I guessed that.

So, here is the skill for you - auto-magically write AGENTS.md, it even comes with some bash checks for scary stuff,
like secrets and whatnot, yay!

Jokes aside: skill is useful to write a *draft* or *maintain* existing files, but relying on it alone is not the best idea.

## Install

Clone it into your agent's skills directory.

Claude Code:

```bash
git clone https://github.com/rakshazi/write-agentsmd.git ~/.claude/skills/write-agentsmd
```

omp:

```bash
git clone https://github.com/rakshazi/write-agentsmd.git ~/.omp/agent/skills/write-agentsmd
```

## Use

Just tell your agent something like this:

- "there's no AGENTS.md in this repo and every agent session starts by rediscovering the build. can you set one up properly?"
- "monorepo: go services plus a react app. the agent keeps running the frontend tests from the root and breaking stuff. i want instructions scoped to each subtree"
- (what I actually use) "/skill:write-agentsmd"

See [evals/evals.json](./evals/evals.json) in case you need more examples (why, though?).
