import React from "react";
import { createRoot } from "react-dom/client";
import { createBrowserRouter, RouterProvider } from "react-router-dom";
import App from "../cosmos/App";
import Home from "../cosmos/pages/Home";
import About from "../cosmos/pages/About";
import Properties from "../cosmos/pages/Properties";
import MapSystem from "../cosmos/pages/MapSystem";
import NotFound from "../cosmos/pages/NotFound";

// ルータ定義（v7）
const router = createBrowserRouter([
  {
    path: "/",
    element: <App />,
    children: [
      { index: true, element: <Home /> },
      { path: "about", element: <About /> },
      { path: "properties", element: <Properties /> },
      { path: "map", element: <MapSystem /> },
      { path: "*", element: <NotFound /> },
    ],
  },
]);

const container = document.getElementById("root");
createRoot(container).render(<RouterProvider router={router} />);
