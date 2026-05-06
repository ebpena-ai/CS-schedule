# Carrystar Schedule — Go-Live Checklist

## Step 1 — Create your Supabase project (5 min)

1. Go to **https://supabase.com** → Sign in → **New Project**
2. Name: `carrystar-schedule` | Region: US East (or closest to you)
3. Wait ~2 min for the project to provision

## Step 2 — Run the database schema (2 min)

1. In Supabase → **SQL Editor** → **New Query**
2. Open `supabase_setup.sql` (in this folder), paste the entire contents, click **Run**
3. You should see "Success. No rows returned."

## Step 3 — Create user accounts (2 min)

1. In Supabase → **Authentication** → **Users** → **Add User**
2. Add one account each for: **Eduardo**, **Jose**, and anyone else who needs edit access
3. They'll use these email + password credentials to log in on the site

## Step 4 — Paste credentials into index.html (1 min)

1. In Supabase → **Project Settings** → **API**
2. Copy **Project URL** (looks like `https://xyzxyz.supabase.co`)
3. Copy **anon public** key (long `eyJ...` string)
4. Open `index.html` — near the top of the `<script>` block, find:

```javascript
const SUPABASE_URL      = '';  // paste your Project URL
const SUPABASE_ANON_KEY = '';  // paste your anon public key
```

5. Paste your two values between the quotes and save the file

## Step 5 — Push to GitHub (1 min)

```bash
git add index.html supabase_setup.sql SETUP_GUIDE.md
git commit -m "Add Supabase integration + live auth"
git push
```

## Step 6 — Enable GitHub Pages (2 min)

1. Go to your repo on GitHub → **Settings** → **Pages**
2. Source: **Deploy from branch** | Branch: **main** | Folder: **/ (root)**
3. Click **Save** — your live URL will appear (usually within 1–2 min):
   `https://YOUR-USERNAME.github.io/YOUR-REPO-NAME/`

---

## How it works once live

| Who | What they see |
|-----|---------------|
| Anyone with the link | Full schedule, read-only. No login needed. |
| Logged-in users (Jose, Eduardo) | Full editing access. Changes sync live to all viewers. |

- When someone is logged out, all edit controls are grayed out and a banner says "View-only mode."
- When Jose logs in, the banner disappears and editing is fully enabled.
- If two people are on the site at the same time, changes appear live within ~1 second.
- The browser still caches locally, so the site loads instantly even on slow connections.

---

## Troubleshooting

**"Supabase is not configured"** → You haven't pasted the URL/key yet (Step 4).

**"Invalid login credentials"** → The email/password doesn't match what you created in Authentication → Users.

**Changes not syncing live** → Check that both tables are enabled under Database → Replication in Supabase dashboard.
