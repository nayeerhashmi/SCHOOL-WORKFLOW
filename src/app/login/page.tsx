"use client";

import Link from "next/link";
import { FormEvent, useState } from "react";
import { createSupabaseBrowserClient } from "@/lib/supabase/browser";

export default function LoginPage() {
  const [email, setEmail] = useState(""); const [password, setPassword] = useState(""); const [message, setMessage] = useState(""); const [busy, setBusy] = useState(false);
  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault(); setMessage(""); setBusy(true);
    try {
      const supabase = createSupabaseBrowserClient();
      const { error } = await supabase.auth.signInWithPassword({ email: email.trim(), password });
      if (error) throw error;
      const requested = new URLSearchParams(window.location.search).get("next");
      const destination = requested && requested.startsWith("/") && !requested.startsWith("//") ? requested : "/dashboard";
      window.location.assign(destination);
    } catch (error) { setMessage(error instanceof Error ? error.message : "Sign-in failed."); }
    finally { setBusy(false); }
  }
  return <main className="auth-shell"><aside className="auth-aside"><div className="brand">SCHOOL-WORKFLOW</div><div><h1>School records deserve better systems.</h1><p>A careful workspace for student data, school teams, and reliable record keeping.</p></div><small>Secure by design. Built for real school workflows.</small></aside><section className="auth-main"><div className="auth-card"><h2>Welcome back</h2><p className="subtle">Sign in with the email address linked to your school account.</p><form onSubmit={submit}><div className="field"><label htmlFor="email">Email address</label><input id="email" type="email" autoComplete="email" required value={email} onChange={e=>setEmail(e.target.value)} /></div><div className="field"><label htmlFor="password">Password</label><input id="password" type="password" autoComplete="current-password" required value={password} onChange={e=>setPassword(e.target.value)} /></div><button className="primary" disabled={busy}>{busy ? "Signing in…" : "Sign in"}</button></form>{message && <p role="alert" className="notice error">{message}</p>}<div className="link-row"><Link href="/forgot-password">Forgot password?</Link><Link href="/accept-invite">Have an invitation?</Link></div><p className="subtle" style={{marginTop:24}}>School access is invitation-only during the initial rollout.</p></div></section></main>;
}
