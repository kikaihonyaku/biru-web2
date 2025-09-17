import React from "react";
import { Link, NavLink } from "react-router-dom";
import { Box, Button, Typography, AppBar, Toolbar } from "@mui/material";
import { useAuth } from "../../contexts/AuthContext";

export default function Header() {
  const { user, logout } = useAuth();
  
  const navStyle = ({ isActive }) => ({
    fontWeight: isActive ? "700" : "400",
    textDecoration: "none",
    marginRight: "1rem",
    color: isActive ? 'white' : 'rgba(255, 255, 255, 0.7)',
  });

  const handleLogout = async () => {
    await logout();
  };

  return (
    <AppBar position="static" elevation={1} sx={{ bgcolor: 'primary.main', borderBottom: '1px solid #ddd' }}>
      <Toolbar variant="dense" sx={{ minHeight: '45px' }}>
        <Link to="/" style={{ textDecoration: "none", fontWeight: 700, marginRight: "1.5rem", color: 'white' }}>
          <img src="/cocosmo-logo.png" alt="CoCoスモ" style={{ height: '32px', width: 'auto', marginTop: '7px' }} />
        </Link>
        
        <Box sx={{ flexGrow: 1, display: 'flex' }}>
          <NavLink to="/" style={navStyle} end>Home</NavLink>
          <NavLink to="/properties" style={navStyle}>Properties</NavLink>
          <NavLink to="/map" style={navStyle}>物件情報</NavLink>
          <NavLink to="/about" style={navStyle}>About</NavLink>
        </Box>

        {user && (
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
            <Typography variant="body2" sx={{ color: 'white' }}>
              {user.name} ({user.auth_provider === 'google' ? 'Google' : user.code})
            </Typography>
            <Button
              variant="outlined"
              size="small"
              onClick={handleLogout}
              sx={{ 
                minWidth: 'auto',
                color: 'white',
                borderColor: 'white',
                '&:hover': {
                  borderColor: 'white',
                  bgcolor: 'rgba(255, 255, 255, 0.1)'
                }
              }}
            >
              ログアウト
            </Button>
          </Box>
        )}
      </Toolbar>
    </AppBar>
  );
}