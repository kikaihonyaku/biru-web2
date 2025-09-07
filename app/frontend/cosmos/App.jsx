import React from "react";
import { Link, NavLink, Outlet, useLocation } from "react-router-dom";
import { Box, Button, Typography, AppBar, Toolbar } from "@mui/material";
import { useAuth } from "./contexts/AuthContext";

export default function App() {
  const location = useLocation();
  const isMapSystem = location.pathname === '/map';
  const { user, logout } = useAuth();
  
  const navStyle = ({ isActive }) => ({
    fontWeight: isActive ? "700" : "400",
    textDecoration: "none",
    marginRight: "1rem",
    color: isActive ? '#1976d2' : '#666',
  });

  const handleLogout = async () => {
    await logout();
  };

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
      <AppBar position="static" elevation={1} sx={{ bgcolor: 'white', borderBottom: '1px solid #ddd' }}>
        <Toolbar>
          <Link to="/" style={{ textDecoration: "none", fontWeight: 700, marginRight: "2rem", color: '#1976d2' }}>
            COSMOS
          </Link>
          
          <Box sx={{ flexGrow: 1, display: 'flex' }}>
            <NavLink to="/" style={navStyle} end>Home</NavLink>
            <NavLink to="/properties" style={navStyle}>Properties</NavLink>
            <NavLink to="/map" style={navStyle}>地図システム</NavLink>
            <NavLink to="/about" style={navStyle}>About</NavLink>
          </Box>

          {user && (
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
              <Typography variant="body2" color="textSecondary">
                {user.name} ({user.auth_provider === 'google' ? 'Google' : user.code})
              </Typography>
              <Button
                variant="outlined"
                size="small"
                onClick={handleLogout}
                sx={{ minWidth: 'auto' }}
              >
                ログアウト
              </Button>
            </Box>
          )}
        </Toolbar>
      </AppBar>

      <main style={{ padding: "1.25rem" }}>
        <Outlet />
      </main>

      <footer style={{ padding: "1rem", borderTop: "1px solid #eee", color: "#666" }}>
        © {new Date().getFullYear()} COSMOS
      </footer>
    </div>
  );
}
