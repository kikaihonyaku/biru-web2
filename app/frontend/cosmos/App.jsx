import React from "react";
import { Outlet, useLocation } from "react-router-dom";
import Header from "./components/shared/Header";

export default function App() {
  const location = useLocation();
  const isMapSystem = location.pathname === '/map';

  // 地図システムページでは全画面レイアウト
  if (isMapSystem) {
    return (
      <div style={{ fontFamily: "system-ui, -apple-system, Segoe UI, Roboto, sans-serif" }}>
        <Outlet />
      </div>
    );
  }

  return (
    <div style={{ fontFamily: "system-ui, -apple-system, Segoe UI, Roboto, sans-serif" }}>
      <Header />

      <main style={{ padding: "1.25rem" }}>
        <Outlet />
      </main>

      <footer style={{ padding: "1rem", borderTop: "1px solid #eee", color: "#666" }}>
        © {new Date().getFullYear()} COSMOS
      </footer>
    </div>
  );
}
