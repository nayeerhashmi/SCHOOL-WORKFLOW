"use client";
import { useState } from "react";
import { createSupabaseBrowserClient } from "@/lib/supabase/browser";
export default function SignOutButton(){const[busy,setBusy]=useState(false);async function signOut(){setBusy(true);const{error}=await createSupabaseBrowserClient().auth.signOut();if(error){setBusy(false);window.alert("Sign out failed. Please try again.");return;}window.location.assign("/login");}return <button onClick={signOut} disabled={busy} style={{border:"1px solid #d0d7e2",borderRadius:8,padding:"9px 12px",background:"white",cursor:"pointer"}}>{busy?"Signing out…":"Sign out"}</button>}
