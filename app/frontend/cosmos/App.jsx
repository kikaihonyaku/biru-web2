import React from "react";
import { Link, NavLink, Outlet } from "react-router-dom";

export default function App() {
  const navStyle = ({ isActive }) => ({
    fontWeight: isActive ? "700" : "400",
    textDecoration: "none",
    marginRight: "1rem",
  });

  return (
    <div style={{ fontFamily: "system-ui, -apple-system, Segoe UI, Roboto, sans-serif" }}>
      <header style={{ padding: "1rem", borderBottom: "1px solid #ddd" }}>
        <Link to="/" style={{ textDecoration: "none", fontWeight: 700, marginRight: "2rem" }}>
          COSMOS
        </Link>
        <NavLink to="/" style={navStyle} end>Home</NavLink>
        <NavLink to="/properties" style={navStyle}>Properties</NavLink>
        <NavLink to="/about" style={navStyle}>About</NavLink>
      </header>

      <main style={{ padding: "1.25rem" }}>
        <Outlet />
      </main>

      <footer style={{ padding: "1rem", borderTop: "1px solid #eee", color: "#666" }}>
        © {new Date().getFullYear()} COSMOS
      </footer>
    </div>
  );
}
