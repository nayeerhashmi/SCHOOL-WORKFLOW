import type { Metadata } from "next";
import "./globals.css";
export const metadata: Metadata = { title: "SCHOOL-WORKFLOW", description: "Reliable school records, reviewed imports, and secure school workflows." };
export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) { return <html lang="en"><body>{children}</body></html>; }
