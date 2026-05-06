# Carrystar Schedule — Path to a Shared Version

## TL;DR

The current schedule is a **static HTML file** hosted on GitHub Pages. Everyone who opens the URL gets their own private copy in their own browser (via `localStorage`). That's why your employee's edits don't show up on your screen — there's no shared database behind it.

To make edits permanent and visible to everyone, the page needs to read and write to a shared backend. There are three realistic paths, depending on how much engineering effort you want to invest now versus later.

| Path | Setup time | Cost | Best for |
|---|---|---|---|
| **A. Google Sheets backend** | 1 evening | Free | "Just make sharing work, this week" |
| **B. Supabase** *(recommended)* | 1–2 weekends | Free for current scale | The "in-house app" goal you described |
| **C. Custom backend (Node + DB on Render/Fly)** | 1–2 weeks | $5–10/mo | Full control, only worth it if you're already building other internal tools |

I'd recommend **Path B (Supabase)** because it's the cleanest evolution toward your stated goal of "an in-house app where admin sees everything and staff see their own hours." It gives you authentication and per-user roles out of the box, which neither A nor C provide cheaply.

---

## What changes when we add a shared backend

Today the page does this on load:

1. Read schedule data from `localStorage` (browser's local key-value store)
2. Render it
3. On every edit, save back to `localStorage`

That's why edits don't sync across browsers. With a shared backend, the flow becomes:

1. Read schedule data from the backend (over HTTP)
2. Render it
3. On every edit, save to the backend
4. *(With real-time sync)* When someone else edits, push the update to all open browsers

The HTML file itself doesn't need to be rewritten — only the `save()` and `load()` functions need to point at the backend instead of `localStorage`. Roughly 60 lines of JavaScript change.

---

## Path A — Google Sheets backend

**Setup:**

1. Create a Google Sheet with three tabs: `Roster`, `Schedules`, `Settings`.
2. Open Extensions → Apps Script. Paste a small script that exposes the sheet as a JSON API (`doGet` reads the sheet and returns JSON; `doPost` writes back).
3. Deploy the script as a "web app." You get a long URL.
4. Replace `localStorage.getItem` and `localStorage.setItem` calls in the HTML file with `fetch(scriptUrl)` and `fetch(scriptUrl, { method: 'POST', body: ... })`.

**Pros:** Free forever. Anyone on your Google Workspace can also view/edit the sheet directly as a backup. You get an audit trail of changes via Sheets' version history. No new accounts needed.

**Cons:** Apps Script is slow (1–3 seconds per request). No real-time updates — users have to refresh to see others' changes. No login system, so the URL needs to stay private. Apps Script has a daily quota (you're nowhere near it for this scale).

**When to choose this:** You want to stop the bleeding this week, you're already on Google Workspace, and you don't mind users hitting "refresh" to see each other's edits.

---

## Path B — Supabase *(recommended)*

**Setup:**

1. Sign up at [supabase.com](https://supabase.com) — free tier is 500 MB DB + 50,000 monthly active users (you'll use a fraction of either).
2. Create a project. Run a SQL script to create three tables: `departments`, `staff`, `schedule_cells`, plus a few helper tables.
3. In the HTML file, add a small script tag for the Supabase JS client.
4. Replace `localStorage` calls with Supabase queries. About 80 lines of JS change.
5. Add Supabase Auth — email/magic-link login. Two more tables: `users` and `user_roles` (admin / lead / staff).

**What you get:**

- **Real shared state.** Every browser sees the same schedule. Jose's edit on his laptop appears on your phone within 1 second.
- **Real-time sync** via Supabase's WebSocket subscriptions. No refresh button needed.
- **Login system.** No more "the URL is the password." Every user has their own account.
- **Per-role views.** Admins (you, Sergio) see everything. Leads (Jose, Jasmine, Adriana) see their teams. Staff see only their own hours. This is exactly what you described in the very first conversation.
- **A real database.** PostgreSQL. You can write SQL queries against it for any custom report or BI need.
- **Audit log.** Every change can be timestamped and attributed to a user.

**Cons:** Requires a Supabase account and one-time setup. Slightly more code than Sheets. Vendor lock-in is mild (data is plain Postgres, easy to export).

**Cost:** Free tier covers you indefinitely at this scale. If you outgrow it (millions of rows or thousands of users), it's $25/month.

**When to choose this:** You want this to evolve into an actual app that your operation depends on. This is the right path for that vision.

---

## Path C — Custom backend

**Setup:**

1. Write a small Node + Express server with a Postgres or SQLite database.
2. Deploy it to Render, Fly.io, or Railway (~$5–10/month).
3. Add login system (Auth0 or roll your own).
4. Same HTML changes as Path B.

**When to choose this:** Only if you already have other internal tools running on a server you own, and adding this to that infrastructure is cheaper than maintaining a separate Supabase account. For a single-tool use case, this is over-engineered.

---

## Migration plan if you pick Path B (Supabase)

**Phase 1 — Get a working shared version (1 weekend):**

1. Create Supabase project + tables.
2. Modify `save()` and `load()` in `index.html` to use Supabase. Keep everything else as-is.
3. One-time data import: paste the current `localStorage` blob into Supabase to seed the schedule.
4. Push the updated `index.html` to GitHub. Now everyone sees the same data.

**Phase 2 — Add login and roles (1 weekend):**

5. Enable Supabase Auth (magic-link email login is simplest).
6. Add a `users` table with role: `admin` | `lead` | `staff`.
7. Add row-level security policies in Supabase: staff can only `SELECT` their own rows; leads can read/write their team; admins can do everything.
8. Add a small login screen on top of the existing page.

**Phase 3 — Staff-facing view (1 weekend):**

9. When a `staff` user logs in, hide the Schedule and Reports tabs entirely. Show only their own week.
10. Add a "request shift change" button that creates a record for the lead/admin to approve.

After Phase 3, you have your in-house app.

---

## What I can do for you

I can write the Supabase schema, the JS changes to `index.html`, and the role-based access policies. I can also write the migration script that imports your current `localStorage` data into Supabase. Roughly a 4–6 hour pairing session if we do it together, or I write everything and your employee deploys it.

The decision I need from you to start:

1. **Path A (Sheets) or Path B (Supabase)?** I recommend B unless you specifically want to avoid creating a Supabase account.
2. **Who is your point person on the technical side?** The employee currently editing the HTML, or someone else?
3. **For the existing schedule data on your laptop** — do you want to keep it (we'll migrate it) or start fresh on the new backend?

---

## Important caveat about today's cleanup

I just removed the operational annotations (OVERLOADED, single-point-of-failure, client names, "TBD") from the **template** in `index.html`. If you've already used the page on any browser, that browser still has the **old version** cached in its `localStorage`. To see the cleaned text on those browsers, click the **"Reset to Template"** button in the toolbar (which wipes saved data and reloads defaults). Fresh visitors will see the cleaned version automatically.

Once you migrate to a shared backend, this concern goes away — there's only one source of truth.
