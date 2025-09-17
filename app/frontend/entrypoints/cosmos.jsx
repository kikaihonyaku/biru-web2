import React from "react";
import { createRoot } from "react-dom/client";
import { createBrowserRouter, RouterProvider } from "react-router-dom";
import { ThemeProvider } from "@mui/material/styles";
import { CssBaseline } from "@mui/material";
import muiTheme from "../cosmos/theme/muiTheme";
import { AuthProvider } from "../cosmos/contexts/AuthContext";
import PrivateRoute from "../cosmos/components/Auth/PrivateRoute";
import App from "../cosmos/App";
import Home from "../cosmos/pages/Home";
import About from "../cosmos/pages/About";
import Properties from "../cosmos/pages/Properties";
import MapSystem from "../cosmos/pages/MapSystem";
import PropertyDetail from "../cosmos/pages/PropertyDetail";
import NotFound from "../cosmos/pages/NotFound";

// ルータ定義（v7）
const router = createBrowserRouter([
  {
    path: "/",
    element: (
      <PrivateRoute>
        <App />
      </PrivateRoute>
    ),
    children: [
      { index: true, element: <Home /> },
      { path: "about", element: <About /> },
      { path: "properties", element: <Properties /> },
      { path: "property/:id", element: <PropertyDetail /> },
      { path: "map", element: <MapSystem /> },
      { path: "*", element: <NotFound /> },
    ],
  },
]);

const container = document.getElementById("root");
createRoot(container).render(
  <ThemeProvider theme={muiTheme}>
    <CssBaseline />
    <AuthProvider>
      <RouterProvider router={router} />
    </AuthProvider>
  </ThemeProvider>
);
